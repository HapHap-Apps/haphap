import { Body, Controller, Get, Param, Patch, Post, UseGuards } from '@nestjs/common';
import { SurplusService } from './surplus.service.js';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard.js';
import { RolesGuard } from '../common/guards/roles.guard.js';
import { Roles } from '../common/decorators/roles.decorator.js';
import { Role } from '../generated/prisma/enums.js';
import { CurrentUser } from '../common/decorators/current-user.decorator.js';
import { CurrentUserDto } from '../common/dto/current-user.dto.js';
import { CreateSurplusDto } from './dto/create-surplus.dto.js';
import { UpdateSurplusDto } from './dto/update-surplus.dto.js';
import { ApiBearerAuth } from '@nestjs/swagger';

@ApiBearerAuth()
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(Role.MERCHANT)
@Controller('surplus')
export class SurplusController {
  constructor(private readonly surplusService: SurplusService) {}

  @Get()
  async findAll(@CurrentUser() user: CurrentUserDto) {
    return this.surplusService.findAll(user.id);
  }

  @Post()
  async create(@CurrentUser() user: CurrentUserDto, @Body() dto: CreateSurplusDto) {
    return this.surplusService.create(user.id, dto);
  }

  @Patch(':surplusItemId')
  async update(
    @CurrentUser() user: CurrentUserDto,
    @Param('surplusItemId') surplusItemId: string,
    @Body() dto: UpdateSurplusDto,
  ) {
    return this.surplusService.update(user.id, surplusItemId, dto);
  }
}
