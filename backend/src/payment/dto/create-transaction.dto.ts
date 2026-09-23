import { IsEmail, IsInt, IsNotEmpty, IsString, IsUUID } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateTransactionDto {
  @ApiProperty()
  @IsNotEmpty()
  @IsUUID()
  orderId!: string;

  @ApiProperty()
  @IsNotEmpty()
  @IsInt()
  grossAmount!: number;

  @ApiProperty()
  @IsNotEmpty()
  @IsString()
  customerName!: string;

  @ApiProperty()
  @IsNotEmpty()
  @IsEmail()
  customerEmail!: string;

  @ApiProperty()
  @IsNotEmpty()
  @IsString()
  customerPhone!: string;
}
