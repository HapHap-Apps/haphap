import { Injectable, NotFoundException, BadRequestException, ForbiddenException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service.js';
import { MidtransService } from './midtrans.service.js';
import { OrderStatus, PaymentStatus } from '../generated/prisma/enums.js';
import { MidtransWebhookDto } from './dto/midtrans-webhook.dto.js';

@Injectable()
export class PaymentService {
  constructor(
    private readonly midtransService: MidtransService,
    private readonly prismaService: PrismaService,
  ) {}

  private resolveStatus(transactionStatus: string, fraudStatus: string) {
    switch (transactionStatus) {
      case 'capture':
      case 'settlement':
        return fraudStatus === 'accept' || !fraudStatus
          ? { paymentStatus: PaymentStatus.SUCCESS, orderStatus: OrderStatus.PROCESSING }
          : { paymentStatus: PaymentStatus.FAILED, orderStatus: OrderStatus.CANCELLED };
      case 'cancel':
      case 'deny':
      case 'failure':
        return { paymentStatus: PaymentStatus.FAILED, orderStatus: OrderStatus.CANCELLED };
      case 'expire':
        return { paymentStatus: PaymentStatus.EXPIRED, orderStatus: OrderStatus.CANCELLED };
      default:
        return { paymentStatus: PaymentStatus.PENDING, orderStatus: OrderStatus.PENDING };
    }
  }

  async createPayment(userId: string, orderId: string) {
    const order = await this.prismaService.order.findUnique({
      where: { id: orderId },
      include: { user: true },
    });

    if (!order) {
      throw new NotFoundException('Order not found');
    }

    if (order.userId !== userId) {
      throw new ForbiddenException('Access denied');
    }

    if (order.status !== OrderStatus.PENDING) {
      throw new BadRequestException(`Order is already ${order.status}`);
    }

    const payment = await this.prismaService.payment.upsert({
      where: { orderId },
      create: {
        order: { connect: { id: orderId } },
        status: PaymentStatus.PENDING,
        amount: order.totalAmount,
      },
      update: {
        status: PaymentStatus.PENDING,
        transactionId: null,
        snapToken: null,
        redirectUrl: null,
      },
    });

    const { token, redirectUrl } = await this.midtransService.createTransaction({
      orderId,
      grossAmount: order.totalAmount,
      customerName: order.user.name,
      customerEmail: order.user.email,
      customerPhone: order.user.phone,
    });

    const updatedPayment = await this.prismaService.payment.update({
      where: { id: payment.id },
      data: { snapToken: token, redirectUrl },
    });

    return {
      paymentId: updatedPayment.id,
      orderId: updatedPayment.orderId,
      status: updatedPayment.status,
      amount: updatedPayment.amount,
      snapToken: updatedPayment.snapToken,
      redirectUrl: updatedPayment.redirectUrl,
      createdAt: updatedPayment.createdAt,
    };
  }

  async handleWebhook(dto: MidtransWebhookDto) {
    const isWebhookValid = await this.midtransService.verifyWebhookSignature(dto);

    if (!isWebhookValid) {
      throw new BadRequestException('Invalid webhook');
    }

    const { order_id, transaction_id, transaction_status, fraud_status } = dto;
    const { paymentStatus, orderStatus } = this.resolveStatus(transaction_status, fraud_status);

    const payment = await this.prismaService.payment.findUnique({
      where: { orderId: order_id },
    });

    if (!payment) {
      throw new NotFoundException('Payment not found');
    }

    await this.prismaService.$transaction([
      this.prismaService.payment.update({
        where: { id: payment.id },
        data: { status: paymentStatus, transactionId: transaction_id },
      }),

      this.prismaService.order.update({
        where: { id: order_id },
        data: {
          status: orderStatus,
          ...(orderStatus === OrderStatus.PROCESSING && { paidAt: new Date() }),
        },
      }),
    ]);

    return { received: true };
  }

  async verifyPayment(userId: string, orderId: string) {
    const order = await this.prismaService.order.findUnique({
      where: { id: orderId },
    });

    if (!order) {
      throw new NotFoundException('Order not found');
    }

    if (order.userId !== userId) {
      throw new ForbiddenException('Access denied');
    }

    return {
      orderId: order.id,
      status: order.status,
      totalAmount: order.totalAmount,
      paidAt: order.paidAt,
    };
  }
}
