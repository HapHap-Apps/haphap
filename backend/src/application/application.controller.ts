import {
  BadRequestException,
  Body,
  Controller,
  Get,
  Param,
  Patch,
  Post,
  UploadedFiles,
  UseGuards,
  UseInterceptors,
} from '@nestjs/common';
import { FileFieldsInterceptor } from '@nestjs/platform-express';
import { ApplicationService } from './application.service.js';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard.js';
import { RolesGuard } from '../common/guards/roles.guard.js';
import { Roles } from '../common/decorators/roles.decorator.js';
import { Role } from '../generated/prisma/enums.js';
import { CurrentUser } from '../common/decorators/current-user.decorator.js';
import { CurrentUserDto } from '../common/dto/current-user.dto.js';
import { CreateApplicationDto } from './dto/create-application.dto.js';
import { UpdateApplicationDto } from './dto/update-application.dto.js';
import { ApiBearerAuth, ApiConsumes } from '@nestjs/swagger';

@ApiBearerAuth()
@Controller('applications')
@UseGuards(JwtAuthGuard, RolesGuard)
export class ApplicationController {
  constructor(private readonly applicationService: ApplicationService) {}

  @Get()
  @Roles(Role.ADMIN)
  async findAll() {
    return this.applicationService.findAll();
  }

  @Post()
  @Roles(Role.CUSTOMER)
  @UseInterceptors(
    FileFieldsInterceptor([
      { name: 'avatar', maxCount: 1 },
      { name: 'document', maxCount: 1 },
    ]),
  )
  @ApiConsumes('multipart/form-data')
  async create(
    @CurrentUser() user: CurrentUserDto,
    @Body() dto: CreateApplicationDto,
    @UploadedFiles() files: { avatar: Express.Multer.File[]; document: Express.Multer.File[] },
  ) {
    if (!files?.avatar || files.avatar.length === 0) {
      throw new BadRequestException('Avatar file is required');
    }

    if (!files?.document || files.document.length === 0) {
      throw new BadRequestException('Document file is required');
    }

    return this.applicationService.create(user.id, dto, files.avatar[0], files.document[0]);
  }

  @Get('me')
  @Roles(Role.CUSTOMER, Role.MERCHANT)
  async findMyApplications(@CurrentUser() user: CurrentUserDto) {
    return this.applicationService.findMyApplications(user.id);
  }

  @Patch(':applicationId/status')
  @Roles(Role.ADMIN)
  async updateStatus(@Param('applicationId') applicationId: string, @Body() dto: UpdateApplicationDto) {
    return this.applicationService.updateStatus(applicationId, dto);
  }
}
