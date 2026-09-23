import { IsArray, IsEnum, IsOptional, IsString, Matches } from 'class-validator';
import { Transform } from 'class-transformer';
import { MerchantCategory } from '../../generated/prisma/enums.js';
import { ApiProperty } from '@nestjs/swagger';

export class UpdateMerchantDto {
  @ApiProperty()
  @IsOptional()
  @IsString()
  merchantName?: string;

  @ApiProperty()
  @IsOptional()
  @IsString()
  address?: string;

  @ApiProperty()
  @IsOptional()
  @IsString()
  description?: string;

  @ApiProperty()
  @IsOptional()
  @Matches(/^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/)
  openTime?: string;

  @ApiProperty()
  @IsOptional()
  @Matches(/^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/)
  closeTime?: string;

  @ApiProperty()
  @IsOptional()
  @IsString()
  phone?: string;

  @ApiProperty({ enum: MerchantCategory, isArray: true })
  @IsOptional()
  @Transform(({ value }) => (Array.isArray(value) ? value : [value]))
  @IsArray()
  @IsEnum(MerchantCategory, { each: true })
  categories?: MerchantCategory[];
}
