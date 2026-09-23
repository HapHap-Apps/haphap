import { Controller, Post, Body, UseGuards, Get, Param, Patch } from '@nestjs/common';
import { ApiBearerAuth } from '@nestjs/swagger';
import { OrderService } from './order.service.js';
import { CreateOrderDto } from './dto/create-order.dto.js';
import { UpdateOrderStatusDto } from './dto/update-order-status.dto.js';
import { ScanOrderDto } from './dto/scan-order.dto.js';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard.js';
import { RolesGuard } from '../common/guards/roles.guard.js';
import { Roles } from '../common/decorators/roles.decorator.js';
import { Role } from '../generated/prisma/enums.js';
import { CurrentUser } from '../common/decorators/current-user.decorator.js';
import { CurrentUserDto } from '../common/dto/current-user.dto.js';

@ApiBearerAuth()
@Controller('orders')
@UseGuards(JwtAuthGuard, RolesGuard)
export class OrderController {
  constructor(private readonly orderService: OrderService) {}

  @Post()
  @Roles(Role.CUSTOMER, Role.MERCHANT)
  async create(@CurrentUser() user: CurrentUserDto, @Body() dto: CreateOrderDto) {
    return await this.orderService.create(user.id, dto);
  }

  @Get('me')
  @Roles(Role.CUSTOMER, Role.MERCHANT)
  async findOrderMe(@CurrentUser() user: CurrentUserDto) {
    return await this.orderService.findOrderMe(user.id);
  }

  @Get('merchant')
  @Roles(Role.MERCHANT)
  async findOrderMerchant(@CurrentUser() user: CurrentUserDto) {
    return await this.orderService.findOrderMerchant(user.id);
  }

  @Get(':orderId')
  @Roles(Role.CUSTOMER, Role.MERCHANT)
  async findOrderById(@Param('orderId') orderId: string, @CurrentUser() user: CurrentUserDto) {
    return await this.orderService.findOrderById(orderId, user);
  }

  @Patch(':orderId/status')
  @Roles(Role.MERCHANT)
  async updateStatus(
    @Param('orderId') orderId: string,
    @CurrentUser() currentUser: CurrentUserDto,
    @Body() dto: UpdateOrderStatusDto,
  ) {
    return await this.orderService.updateStatus(orderId, currentUser.id, dto);
  }

  @Patch(':orderId/scan')
  @Roles(Role.MERCHANT)
  async scanOrder(
    @Param('orderId') orderId: string,
    @CurrentUser() currentUser: CurrentUserDto,
    @Body() dto: ScanOrderDto,
  ) {
    return await this.orderService.scanOrder(orderId, currentUser.id, dto.qrCode);
  }
}
