import { Body, Controller, Post, UseGuards } from '@nestjs/common';
import { ReviewService } from './review.service.js';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard.js';
import { RolesGuard } from '../common/guards/roles.guard.js';
import { Roles } from '../common/decorators/roles.decorator.js';
import { Role } from '../generated/prisma/enums.js';
import { CurrentUser } from '../common/decorators/current-user.decorator.js';
import { CurrentUserDto } from '../common/dto/current-user.dto.js';
import { CreateReviewDto } from './dto/create-review.dto.js';
import { ApiBearerAuth } from '@nestjs/swagger';

@ApiBearerAuth()
@Controller('reviews')
@UseGuards(JwtAuthGuard, RolesGuard)
export class ReviewController {
  constructor(private readonly reviewService: ReviewService) {}

  @Post()
  @Roles(Role.CUSTOMER, Role.MERCHANT)
  async create(@CurrentUser() user: CurrentUserDto, @Body() dto: CreateReviewDto) {
    return this.reviewService.create(user.id, dto);
  }
}
