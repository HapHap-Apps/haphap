import { IsNotEmpty, IsString } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class ScanOrderDto {
  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  qrCode: string;
}
