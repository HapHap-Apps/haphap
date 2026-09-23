import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PrismaService } from '../prisma/prisma.service.js';
import { StorageService } from '../storage/storage.service.js';
import { CreateApplicationDto } from './dto/create-application.dto.js';
import { UpdateApplicationDto } from './dto/update-application.dto.js';
import { ApplicationStatus, Role } from '../generated/prisma/enums.js';

@Injectable()
export class ApplicationService {
  constructor(
    private readonly configService: ConfigService,
    private readonly prismaService: PrismaService,
    private readonly storageService: StorageService,
  ) {}

  async findAll() {
    const applications = await this.prismaService.application.findMany({
      include: { user: true },
      orderBy: { createdAt: 'desc' },
    });

    return applications.map((a) => ({
      applicationId: a.id,
      userName: a.user.name,
      userEmail: a.user.email,
      userPhone: a.user.phone,
      merchantName: a.merchantName,
      merchantOwner: a.merchantOwner,
      status: a.status,
      address: a.address,
      latitude: a.latitude,
      longitude: a.longitude,
      description: a.description,
      openTime: a.openTime,
      closeTime: a.closeTime,
      phone: a.phone,
      avatar: a.avatar,
      categories: a.categories,
      bankType: a.bankType,
      bankAccount: a.bankAccount,
      bankHolder: a.bankHolder,
      document: a.document,
      rejectNote: a.rejectNote,
      reviewedAt: a.reviewedAt,
      createdAt: a.createdAt,
    }));
  }

  async findMyApplications(userId: string) {
    const applications = await this.prismaService.application.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' },
    });

    return applications.map((a) => ({
      applicationId: a.id,
      merchantName: a.merchantName,
      status: a.status,
      rejectNote: a.rejectNote,
      reviewedAt: a.reviewedAt,
      createdAt: a.createdAt,
    }));
  }

  async create(
    userId: string,
    dto: CreateApplicationDto,
    avatarFile: Express.Multer.File,
    documentFile: Express.Multer.File,
  ) {
    const activeApps = await this.prismaService.application.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' },
    });

    const hasPending = activeApps.some((a) => a.status === ApplicationStatus.PENDING);

    if (hasPending) {
      throw new BadRequestException('You already have a pending application');
    }

    const avatarBucketName = this.configService.get<string>('SUPABASE_APPLICATION_AVATAR_BUCKET')!;
    const avatarUrl = await this.storageService.uploadFile(avatarFile, avatarBucketName, userId);

    const documentBucketName = this.configService.get<string>('SUPABASE_APPLICATION_DOCUMENT_BUCKET')!;
    const documentUrl = await this.storageService.uploadFile(documentFile, documentBucketName, userId);

    const application = await this.prismaService.application.create({
      data: {
        ...dto,
        latitude: typeof dto.latitude === 'string' ? parseFloat(dto.latitude) : dto.latitude,
        longitude: typeof dto.longitude === 'string' ? parseFloat(dto.longitude) : dto.longitude,
        userId,
        avatar: avatarUrl,
        document: documentUrl,
      },
    });

    return {
      applicationId: application.id,
      merchantName: application.merchantName,
      merchantOwner: application.merchantOwner,
      status: application.status,
      address: application.address,
      latitude: application.latitude,
      longitude: application.longitude,
      description: application.description,
      openTime: application.openTime,
      closeTime: application.closeTime,
      phone: application.phone,
      avatar: application.avatar,
      categories: application.categories,
      bankType: application.bankType,
      bankAccount: application.bankAccount,
      bankHolder: application.bankHolder,
      document: application.document,
      createdAt: application.createdAt,
    };
  }

  async updateStatus(applicationId: string, dto: UpdateApplicationDto) {
    const application = await this.prismaService.application.findUnique({
      where: { id: applicationId },
    });

    if (!application) {
      throw new NotFoundException('Application not found');
    }

    if (application.status !== ApplicationStatus.PENDING) {
      throw new BadRequestException(`Application is already ${application.status}`);
    }

    let updatedApp;

    if (dto.status === ApplicationStatus.APPROVED) {
      const [updatedApplication, updatedMerchant, updatedUser] = await this.prismaService.$transaction([
        this.prismaService.application.update({
          where: { id: applicationId },
          data: { status: dto.status, reviewedAt: new Date() },
        }),

        this.prismaService.merchant.create({
          data: {
            userId: application.userId,
            merchantName: application.merchantName,
            address: application.address,
            latitude: application.latitude,
            longitude: application.longitude,
            description: application.description,
            openTime: application.openTime,
            closeTime: application.closeTime,
            phone: application.phone,
            avatar: application.avatar,
            categories: application.categories,
          },
        }),

        this.prismaService.user.update({
          where: { id: application.userId },
          data: { role: Role.MERCHANT },
        }),
      ]);

      updatedApp = updatedApplication;
    } else {
      updatedApp = await this.prismaService.application.update({
        where: { id: applicationId },
        data: {
          status: dto.status,
          rejectNote: dto.rejectNote,
          reviewedAt: new Date(),
        },
      });
    }

    return {
      applicationId: updatedApp.id,
      status: updatedApp.status,
      rejectNote: updatedApp.rejectNote,
      updatedAt: updatedApp.updatedAt,
    };
  }
}
