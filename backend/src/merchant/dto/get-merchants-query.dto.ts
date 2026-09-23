import { IsArray, IsEnum, IsOptional, IsString } from 'class-validator';
import { Transform } from 'class-transformer';
import { MerchantCategory } from '../../generated/prisma/enums.js';
import { ApiProperty } from '@nestjs/swagger';

export class GetMerchantsQueryDto {
  @ApiProperty()
  @IsOptional()
  @IsString()
  search?: string;

  @ApiProperty({ enum: MerchantCategory, isArray: true })
  @IsOptional()
  @Transform(({ value }) => (Array.isArray(value) ? value : [value]))
  @IsArray()
  @IsEnum(MerchantCategory, { each: true })
  categories?: MerchantCategory[];
}
