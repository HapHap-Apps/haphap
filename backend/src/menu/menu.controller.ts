import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  Post,
  UseGuards,
  UseInterceptors,
  UploadedFile,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { MenuService } from './menu.service.js';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard.js';
import { RolesGuard } from '../common/guards/roles.guard.js';
import { Roles } from '../common/decorators/roles.decorator.js';
import { Role } from '../generated/prisma/enums.js';
import { CurrentUser } from '../common/decorators/current-user.decorator.js';
import { CurrentUserDto } from '../common/dto/current-user.dto.js';
import { CreateMenuItemDto } from './dto/create-menu-item.dto.js';
import { UpdateMenuItemDto } from './dto/update-menu-item.dto.js';
import { ApiBearerAuth, ApiConsumes } from '@nestjs/swagger';

@ApiBearerAuth()
@Controller('menus')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(Role.MERCHANT)
export class MenuController {
  constructor(private readonly menuService: MenuService) {}

  @Get()
  async findAll(@CurrentUser() user: CurrentUserDto) {
    return this.menuService.findAll(user.id);
  }

  @Post()
  @UseInterceptors(FileInterceptor('image'))
  @ApiConsumes('multipart/form-data')
  async create(
    @CurrentUser() user: CurrentUserDto,
    @Body() dto: CreateMenuItemDto,
    @UploadedFile() image?: Express.Multer.File,
  ) {
    return this.menuService.create(user.id, dto, image);
  }

  @Get(':menuItemId')
  async findOne(@CurrentUser() user: CurrentUserDto, @Param('menuItemId') menuItemId: string) {
    return this.menuService.findOne(user.id, menuItemId);
  }

  @Patch(':menuItemId')
  async update(
    @CurrentUser() user: CurrentUserDto,
    @Param('menuItemId') menuItemId: string,
    @Body() dto: UpdateMenuItemDto,
  ) {
    return this.menuService.update(user.id, menuItemId, dto);
  }

  @Delete(':menuItemId')
  async remove(@CurrentUser() user: CurrentUserDto, @Param('menuItemId') menuItemId: string) {
    return this.menuService.remove(user.id, menuItemId);
  }

  // @Post(':menuItemId/image')
  // @UseInterceptors(FileInterceptor('file'))
  // @ApiConsumes('multipart/form-data')
  // async uploadImage(
  //   @CurrentUser() user: CurrentUserDto,
  //   @Param('menuItemId') menuItemId: string,
  //   @UploadedFile() file: Express.Multer.File,
  // ) {
  //   return this.menuService.uploadImage(user.id, menuItemId, file);
  // }
}
