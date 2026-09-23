import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PrismaService } from '../prisma/prisma.service.js';
import { StorageService } from '../storage/storage.service.js';
import { UpdateUserDto } from './dto/update-user.dto.js';
import { UpdatePasswordDto } from './dto/update-password.dto.js';
import bcrypt from 'bcrypt';

@Injectable()
export class UserService {
  constructor(
    private readonly prismaService: PrismaService,
    private readonly storageService: StorageService,
    private readonly configService: ConfigService,
  ) {}

  async getMe(userId: string) {
    const user = await this.prismaService.user.findUnique({
      where: { id: userId },
    });

    if (!user) {
      throw new NotFoundException('User not found');
    }

    return {
      userId: user.id,
      name: user.name,
      email: user.email,
      phone: user.phone,
      avatar: user.avatar,
      role: user.role,
      totalSaved: user.totalSaved,
      totalPortion: user.totalPortion,
    };
  }

  async updateMe(userId: string, dto: UpdateUserDto, avatarFile?: Express.Multer.File) {
    if (dto.email) {
      const existingUser = await this.prismaService.user.findUnique({
        where: { email: dto.email },
      });

      if (existingUser && existingUser.id !== userId) {
        throw new BadRequestException('Email already exists');
      }
    }

    let avatarUrl: string | undefined = undefined;

    if (avatarFile) {
      const bucketName = this.configService.get<string>('SUPABASE_USER_AVATAR_BUCKET')!;
      avatarUrl = await this.storageService.uploadFile(avatarFile, bucketName, userId);
    }

    const updatedUser = await this.prismaService.user.update({
      where: { id: userId },
      data: {
        ...dto,
        ...(avatarUrl !== undefined && { avatar: avatarUrl }),
      },
    });

    return {
      userId: updatedUser.id,
      name: updatedUser.name,
      email: updatedUser.email,
      phone: updatedUser.phone,
      avatar: updatedUser.avatar,
      updatedAt: updatedUser.updatedAt,
    };
  }

  async updateMyPassword(userId: string, dto: UpdatePasswordDto) {
    const user = await this.prismaService.user.findUnique({
      where: { id: userId },
    });

    if (!user) {
      throw new NotFoundException('User not found');
    }

    const isPasswordValid = await bcrypt.compare(dto.currentPassword, user.password);

    if (!isPasswordValid) {
      throw new BadRequestException('Invalid credentials');
    }

    const hashedPassword = await bcrypt.hash(dto.newPassword, 10);

    const updatedUser = await this.prismaService.user.update({
      where: { id: userId },
      data: { password: hashedPassword },
    });

    return {
      userId: updatedUser.id,
      updatedAt: updatedUser.updatedAt,
    };
  }
}
