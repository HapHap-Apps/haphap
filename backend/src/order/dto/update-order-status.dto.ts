import { IsEnum, IsNotEmpty } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export enum OrderActionStatus {
  ACCEPT = 'ACCEPT',
  REJECT = 'REJECT',
  READY = 'READY',
}

export class UpdateOrderStatusDto {
  @ApiProperty({ enum: OrderActionStatus })
  @IsNotEmpty()
  @IsEnum(OrderActionStatus)
  status!: OrderActionStatus;
}
