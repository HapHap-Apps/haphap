import { Body, Controller, Param, Post, UseGuards } from '@nestjs/common';
import { PaymentService } from './payment.service.js';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard.js';
import { RolesGuard } from '../common/guards/roles.guard.js';
import { Roles } from '../common/decorators/roles.decorator.js';
import { Role } from '../generated/prisma/enums.js';
import { CurrentUser } from '../common/decorators/current-user.decorator.js';
import { CurrentUserDto } from '../common/dto/current-user.dto.js';
import { MidtransWebhookDto } from './dto/midtrans-webhook.dto.js';
import { ApiBearerAuth } from '@nestjs/swagger';

@ApiBearerAuth()
@Controller('payments')
export class PaymentController {
  constructor(private readonly paymentService: PaymentService) {}

  @Post('webhook')
  async handleWebhook(@Body() dto: MidtransWebhookDto) {
    return this.paymentService.handleWebhook(dto);
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(Role.CUSTOMER, Role.MERCHANT)
  @Post(':orderId')
  async createPayment(@CurrentUser() user: CurrentUserDto, @Param('orderId') orderId: string) {
    return this.paymentService.createPayment(user.id, orderId);
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(Role.CUSTOMER, Role.MERCHANT)
  @Post(':orderId/verify')
  async verifyPayment(@CurrentUser() user: CurrentUserDto, @Param('orderId') orderId: string) {
    return this.paymentService.verifyPayment(user.id, orderId);
  }
}
