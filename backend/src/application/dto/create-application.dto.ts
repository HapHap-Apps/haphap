import { IsArray, IsEnum, IsNotEmpty, IsNumber, IsOptional, IsString, Matches } from 'class-validator';
import { Type, Transform } from 'class-transformer';
import { BankType, MerchantCategory } from '../../generated/prisma/enums.js';
import { ApiProperty } from '@nestjs/swagger';

export class CreateApplicationDto {
  @ApiProperty()
  @IsNotEmpty()
  @IsString()
  merchantName!: string;

  @ApiProperty()
  @IsNotEmpty()
  @IsString()
  merchantOwner!: string;

  @ApiProperty()
  @IsNotEmpty()
  @IsString()
  address!: string;

  @ApiProperty()
  @IsNotEmpty()
  @Type(() => Number)
  @IsNumber()
  latitude!: number;

  @ApiProperty()
  @IsNotEmpty()
  @Type(() => Number)
  @IsNumber()
  longitude!: number;

  @IsOptional()
  @IsString()
  description?: string;

  @ApiProperty()
  @IsNotEmpty()
  @Matches(/^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/)
  openTime!: string;

  @ApiProperty()
  @IsNotEmpty()
  @Matches(/^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/)
  closeTime!: string;

  @ApiProperty()
  @IsNotEmpty()
  @IsString()
  phone!: string;

  @ApiProperty({ enum: MerchantCategory, isArray: true })
  @IsNotEmpty()
  @Transform(({ value }) => (Array.isArray(value) ? value : [value]))
  @IsArray()
  @IsEnum(MerchantCategory, { each: true })
  categories!: MerchantCategory[];

  @ApiProperty({ enum: BankType })
  @IsNotEmpty()
  @IsEnum(BankType)
  bankType!: BankType;

  @ApiProperty()
  @IsNotEmpty()
  @IsString()
  bankAccount!: string;

  @ApiProperty()
  @IsNotEmpty()
  @IsString()
  bankHolder!: string;
}
