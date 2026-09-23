import { Injectable, NotFoundException, ForbiddenException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service.js';
import { CreateSurplusDto } from './dto/create-surplus.dto.js';
import { UpdateSurplusDto } from './dto/update-surplus.dto.js';

@Injectable()
export class SurplusService {
  constructor(private readonly prismaService: PrismaService) {}

  private async getMerchantIdByUserId(userId: string): Promise<string> {
    const merchant = await this.prismaService.merchant.findUnique({
      where: { userId },
    });

    if (!merchant) {
      throw new NotFoundException('Merchant profile not found for this user');
    }

    return merchant.id;
  }

  private async validateMenuOwner(menuItemId: string, merchantId: string) {
    const menuItem = await this.prismaService.menuItem.findUnique({
      where: { id: menuItemId },
    });

    if (!menuItem || !menuItem.isActive) {
      throw new NotFoundException('Menu item not found');
    }

    if (menuItem.merchantId !== merchantId) {
      throw new ForbiddenException('Access denied');
    }

    return menuItem;
  }

  private async validateSurplusOwner(surplusItemId: string, merchantId: string) {
    const surplusItem = await this.prismaService.surplusItem.findUnique({
      where: { id: surplusItemId },
    });

    if (!surplusItem) {
      throw new NotFoundException('Surplus item not found');
    }

    if (surplusItem.merchantId !== merchantId) {
      throw new ForbiddenException('Access denied');
    }

    return surplusItem;
  }

  async findAll(userId: string) {
    const merchantId = await this.getMerchantIdByUserId(userId);

    const items = await this.prismaService.surplusItem.findMany({
      where: { merchantId },
      include: { menuItem: true },
    });

    return items.map((item) => ({
      surplusItemId: item.id,
      name: item.menuItem.name,
      description: item.menuItem.description,
      image: item.menuItem.image,
      discountPrice: item.discountPrice,
      originalPrice: item.originalPrice,
      stock: item.stock,
      isActive: item.isActive,
      date: item.date,
    }));
  }

  async create(userId: string, dto: CreateSurplusDto) {
    const merchantId = await this.getMerchantIdByUserId(userId);
    const menuItem = await this.validateMenuOwner(dto.menuItemId, merchantId);

    const surplusItem = await this.prismaService.surplusItem.create({
      data: {
        ...dto,
        originalPrice: menuItem.originalPrice,
        date: new Date(),
        merchantId,
      },
      include: { menuItem: true },
    });

    return {
      surplusItemId: surplusItem.id,
      menuItemId: surplusItem.menuItemId,
      discountPrice: surplusItem.discountPrice,
      stock: surplusItem.stock,
      createdAt: surplusItem.createdAt,
    };
  }

  async update(userId: string, surplusItemId: string, dto: UpdateSurplusDto) {
    const merchantId = await this.getMerchantIdByUserId(userId);
    const surplusItem = await this.validateSurplusOwner(surplusItemId, merchantId);

    const updatedSurplusItem = await this.prismaService.surplusItem.update({
      where: { id: surplusItemId },
      data: dto,
    });

    return {
      surplusItemId: updatedSurplusItem.id,
      discountPrice: updatedSurplusItem.discountPrice,
      stock: updatedSurplusItem.stock,
      isActive: updatedSurplusItem.isActive,
      updatedAt: updatedSurplusItem.updatedAt,
    };
  }
}
