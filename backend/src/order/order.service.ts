import { BadRequestException, ForbiddenException, Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service.js';
import { CreateOrderDto } from './dto/create-order.dto.js';
import { UpdateOrderStatusDto, OrderActionStatus } from './dto/update-order-status.dto.js';
import { CurrentUserDto } from '../common/dto/current-user.dto.js';
import { Role, OrderStatus } from '../generated/prisma/enums.js';
import { Prisma } from '../generated/prisma/client.js';
import { QrCodeUtil } from '../common/utils/qrcode.util.js';

@Injectable()
export class OrderService {
  constructor(private readonly prismaService: PrismaService) {}

  async create(userId: string, dto: CreateOrderDto) {
    const order = await this.prismaService.$transaction(async (prisma) => {
      let totalAmount = 0;
      let totalOriginal = 0;
      const orderItemsData: Prisma.OrderItemCreateManyOrderInput[] = [];

      for (const item of dto.orderItems) {
        const surplusItem = await prisma.surplusItem.findUnique({
          where: { id: item.surplusItemId },
          include: { menuItem: true },
        });

        if (!surplusItem || !surplusItem.isActive) {
          throw new BadRequestException(`Surplus item not found`);
        }

        if (surplusItem.merchantId !== dto.merchantId) {
          throw new ForbiddenException('Access denied');
        }

        if (surplusItem.stock < item.quantity) {
          throw new BadRequestException(`Surplus item insufficient stock`);
        }

        await prisma.surplusItem.update({
          where: { id: surplusItem.id },
          data: { stock: surplusItem.stock - item.quantity },
        });

        totalAmount += surplusItem.discountPrice * item.quantity;
        totalOriginal += surplusItem.originalPrice * item.quantity;

        orderItemsData.push({
          surplusItemId: surplusItem.id,
          name: surplusItem.menuItem.name,
          quantity: item.quantity,
          discountPrice: surplusItem.discountPrice,
          originalPrice: surplusItem.originalPrice,
        });
      }

      const expiredAt = new Date();
      expiredAt.setMinutes(expiredAt.getMinutes() + 15);

      const createdOrder = await prisma.order.create({
        data: {
          userId,
          merchantId: dto.merchantId,
          totalAmount,
          totalOriginal,
          notes: dto.notes,
          expiredAt,
          orderItems: { createMany: { data: orderItemsData } },
        },
        include: { orderItems: true },
      });

      return createdOrder;
    });

    return {
      orderId: order.id,
      status: order.status,
      totalAmount: order.totalAmount,
      totalOriginal: order.totalOriginal,
      expiredAt: order.expiredAt,
      createdAt: order.createdAt,
    };
  }

  async findOrderById(orderId: string, currentUser: CurrentUserDto) {
    const order = await this.prismaService.order.findUnique({
      where: { id: orderId },
      include: {
        merchant: true,
        user: true,
        orderItems: true,
        payment: true,
      },
    });

    if (!order) {
      throw new NotFoundException('Order not found');
    }

    const isCustomer = order.userId === currentUser.id;
    const isMerchant = currentUser.role === Role.MERCHANT && order.merchant?.userId === currentUser.id;

    if (!isCustomer && !isMerchant) {
      throw new ForbiddenException('Access denied');
    }

    return order;
  }

  async findOrderMe(userId: string) {
    return this.prismaService.order.findMany({
      where: { userId },
      include: {
        merchant: true,
        orderItems: true,
        review: true,
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  async findOrderMerchant(userId: string) {
    const merchant = await this.prismaService.merchant.findUnique({
      where: { userId },
    });

    if (!merchant) {
      throw new NotFoundException('Merchant profile not found for this user');
    }

    return this.prismaService.order.findMany({
      where: { merchantId: merchant.id },
      include: {
        user: true,
        orderItems: true,
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  async updateStatus(orderId: string, userId: string, dto: UpdateOrderStatusDto) {
    const order = await this.prismaService.order.findUnique({
      where: { id: orderId },
      include: { merchant: true },
    });

    if (!order) {
      throw new NotFoundException('Order not found');
    }

    if (order.merchant.userId !== userId) {
      throw new ForbiddenException('Access denied');
    }

    let updatedOrder;

    if (dto.status === OrderActionStatus.ACCEPT) {
      if (order.status !== OrderStatus.PROCESSING) {
        throw new BadRequestException(`Order is already ${order.status}`);
      }

      updatedOrder = await this.prismaService.order.update({
        where: { id: orderId },
        data: { status: OrderStatus.READY },
        include: { orderItems: true },
      });
    } else if (dto.status === OrderActionStatus.REJECT) {
      if (order.status !== OrderStatus.PROCESSING) {
        throw new BadRequestException(`Order is already ${order.status}`);
      }

      updatedOrder = await this.prismaService.order.update({
        where: { id: orderId },
        data: { status: OrderStatus.CANCELLED },
        include: { orderItems: true },
      });
    }

    if (dto.status === OrderActionStatus.READY) {
      if (order.status !== OrderStatus.READY) {
        throw new BadRequestException(`Order is already ${order.status}`);
      }

      if (order.qrCode) {
        throw new BadRequestException('QR code already exists');
      }

      const qrCode = await QrCodeUtil.generateToken(orderId);
      updatedOrder = await this.prismaService.order.update({
        where: { id: orderId },
        data: { qrCode },
        include: { orderItems: true },
      });
    }

    return updatedOrder;
  }

  async scanOrder(orderId: string, userId: string, qrCode: string) {
    const order = await this.prismaService.order.findUnique({
      where: { id: orderId },
      include: { merchant: true, orderItems: true },
    });

    if (!order) {
      throw new NotFoundException('Order not found');
    }

    if (order.merchant.userId !== userId) {
      throw new ForbiddenException('Access denied');
    }

    if (order.status !== OrderStatus.READY) {
      throw new BadRequestException(`Order is already ${order.status}`);
    }

    if (!QrCodeUtil.validateToken(qrCode, orderId)) {
      throw new BadRequestException('QR code not found');
    }

    const totalQuantity = order.orderItems.reduce((sum, item) => sum + item.quantity, 0);

    const [updatedOrder] = await this.prismaService.$transaction([
      this.prismaService.order.update({
        where: { id: orderId },
        data: {
          status: OrderStatus.COMPLETED,
          paidAt: new Date(),
        },
        include: { orderItems: true },
      }),

      this.prismaService.user.update({
        where: { id: order.userId },
        data: {
          totalSaved: { increment: order.totalOriginal - order.totalAmount },
          totalPortion: { increment: totalQuantity },
        },
      }),

      this.prismaService.merchant.update({
        where: { id: order.merchantId },
        data: {
          totalRevenue: { increment: order.totalAmount },
          totalPortion: { increment: totalQuantity },
        },
      }),
    ]);

    return updatedOrder;
  }
}
