import { Type } from 'class-transformer';
import { IsArray, IsInt, IsNotEmpty, IsOptional, IsString, IsUUID, Min, ValidateNested } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class OrderItemDto {
  @IsNotEmpty()
  @IsUUID()
  @ApiProperty()
  surplusItemId!: string;

  @IsNotEmpty()
  @IsInt()
  @Min(1)
  @ApiProperty()
  quantity!: number;
}

export class CreateOrderDto {
  @IsNotEmpty()
  @IsUUID()
  @ApiProperty()
  merchantId!: string;

  @IsOptional()
  @IsString()
  @ApiProperty()
  notes?: string;

  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => OrderItemDto)
  @ApiProperty()
  orderItems!: OrderItemDto[];
}
