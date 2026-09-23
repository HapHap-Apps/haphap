import { Body, Controller, Get, Param, Patch, Query, UploadedFile, UseGuards, UseInterceptors } from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { MerchantService } from './merchant.service.js';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard.js';
import { RolesGuard } from '../common/guards/roles.guard.js';
import { Roles } from '../common/decorators/roles.decorator.js';
import { Role } from '../generated/prisma/enums.js';
import { CurrentUser } from '../common/decorators/current-user.decorator.js';
import { CurrentUserDto } from '../common/dto/current-user.dto.js';
import { GetMerchantsQueryDto } from './dto/get-merchants-query.dto.js';
import { UpdateMerchantDto } from './dto/update-merchant.dto.js';
import { ApiBearerAuth, ApiConsumes } from '@nestjs/swagger';

@Controller('merchants')
export class MerchantController {
  constructor(private readonly merchantService: MerchantService) {}

  @Get()
  async findAll(@Query() dto: GetMerchantsQueryDto) {
    return this.merchantService.findAll(dto);
  }

  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(Role.MERCHANT)
  @Get('me')
  async getMe(@CurrentUser() user: CurrentUserDto) {
    return this.merchantService.getMe(user.id);
  }

  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(Role.MERCHANT)
  @Patch('me')
  @UseInterceptors(FileInterceptor('avatar'))
  @ApiConsumes('multipart/form-data')
  async updateMe(
    @CurrentUser() user: CurrentUserDto,
    @Body() dto: UpdateMerchantDto,
    @UploadedFile() avatar?: Express.Multer.File,
  ) {
    return this.merchantService.updateMe(user.id, dto, avatar);
  }

  @Get(':merchantId')
  async findOne(@Param('merchantId') merchantId: string) {
    return this.merchantService.findOne(merchantId);
  }

  @Get(':merchantId/reviews')
  async findReviews(@Param('merchantId') merchantId: string) {
    return this.merchantService.findReviews(merchantId);
  }
}
