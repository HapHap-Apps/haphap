import { Injectable, NotFoundException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PrismaService } from '../prisma/prisma.service.js';
import { StorageService } from '../storage/storage.service.js';
import { GetMerchantsQueryDto } from './dto/get-merchants-query.dto.js';
import { UpdateMerchantDto } from './dto/update-merchant.dto.js';

@Injectable()
export class MerchantService {
  constructor(
    private readonly prismaService: PrismaService,
    private readonly storageService: StorageService,
    private readonly configService: ConfigService,
  ) {}

  async findAll(dto: GetMerchantsQueryDto) {
    const merchants = await this.prismaService.merchant.findMany({
      where: {
        merchantName: dto.search ? { contains: dto.search, mode: 'insensitive' } : undefined,
        categories: dto.categories && dto.categories.length > 0 ? { hasSome: dto.categories } : undefined,
      },
    });

    return merchants.map((merchant) => ({
      merchantId: merchant.id,
      merchantName: merchant.merchantName,
      address: merchant.address,
      description: merchant.description,
      openTime: merchant.openTime,
      closeTime: merchant.closeTime,
      avatar: merchant.avatar,
      categories: merchant.categories,
      rating: merchant.rating,
    }));
  }

  async findOne(merchantId: string) {
    const merchant = await this.prismaService.merchant.findUnique({
      where: { id: merchantId },
      include: {
        surplusItems: {
          where: { isActive: true },
          include: { menuItem: true },
        },
      },
    });

    if (!merchant) {
      throw new NotFoundException('Merchant not found');
    }

    return {
      merchantId: merchant.id,
      merchantName: merchant.merchantName,
      address: merchant.address,
      latitude: merchant.latitude,
      longitude: merchant.longitude,
      description: merchant.description,
      openTime: merchant.openTime,
      closeTime: merchant.closeTime,
      phone: merchant.phone,
      avatar: merchant.avatar,
      categories: merchant.categories,
      rating: merchant.rating,
      surplusItems: merchant.surplusItems.map((surplusItem) => ({
        surplusItemId: surplusItem.id,
        name: surplusItem.menuItem.name,
        description: surplusItem.menuItem.description,
        image: surplusItem.menuItem.image,
        discountPrice: surplusItem.discountPrice,
        originalPrice: surplusItem.originalPrice,
        stock: surplusItem.stock,
      })),
    };
  }

  async getMe(userId: string) {
    const merchant = await this.prismaService.merchant.findUnique({
      where: { userId },
    });

    if (!merchant) {
      throw new NotFoundException('Merchant profile not found for this user');
    }

    return {
      merchantId: merchant.id,
      merchantName: merchant.merchantName,
      address: merchant.address,
      latitude: merchant.latitude,
      longitude: merchant.longitude,
      description: merchant.description,
      openTime: merchant.openTime,
      closeTime: merchant.closeTime,
      phone: merchant.phone,
      avatar: merchant.avatar,
      categories: merchant.categories,
      rating: merchant.rating,
      totalRevenue: merchant.totalRevenue,
      totalPortion: merchant.totalPortion,
    };
  }

  async updateMe(userId: string, dto: UpdateMerchantDto, avatarFile?: Express.Multer.File) {
    const merchant = await this.prismaService.merchant.findUnique({
      where: { userId },
    });

    if (!merchant) {
      throw new NotFoundException('Merchant profile not found for this user');
    }

    let avatarUrl: string | undefined = undefined;

    if (avatarFile) {
      const bucketName = this.configService.get<string>('SUPABASE_MERCHANT_AVATAR_BUCKET')!;
      avatarUrl = await this.storageService.uploadFile(avatarFile, bucketName, merchant.id);
    }

    const updatedMerchant = await this.prismaService.merchant.update({
      where: { userId },
      data: {
        ...dto,
        ...(avatarUrl !== undefined && { avatar: avatarUrl }),
      },
    });

    return {
      merchantId: updatedMerchant.id,
      merchantName: updatedMerchant.merchantName,
      address: updatedMerchant.address,
      description: updatedMerchant.description,
      openTime: updatedMerchant.openTime,
      closeTime: updatedMerchant.closeTime,
      phone: updatedMerchant.phone,
      avatar: updatedMerchant.avatar,
      categories: updatedMerchant.categories,
      updatedAt: updatedMerchant.updatedAt,
    };
  }

  async findReviews(merchantId: string) {
    const reviews = await this.prismaService.review.findMany({
      where: { merchantId },
      include: {
        user: {
          select: {
            name: true,
            avatar: true,
          },
        },
      },
    });

    return reviews.map((review) => ({
      reviewId: review.id,
      rating: review.rating,
      comment: review.comment,
      createdAt: review.createdAt,
      customerName: review.user.name,
      customerAvatar: review.user.avatar,
    }));
  }
}
