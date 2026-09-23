import { IsNotEmpty, IsString } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class MidtransWebhookDto {
  @ApiProperty()
  @IsNotEmpty()
  @IsString()
  order_id!: string;

  @ApiProperty()
  @IsNotEmpty()
  @IsString()
  transaction_id!: string;

  @ApiProperty()
  @IsNotEmpty()
  @IsString()
  transaction_status!: string;

  @ApiProperty()
  @IsNotEmpty()
  @IsString()
  fraud_status!: string;

  @ApiProperty()
  @IsNotEmpty()
  @IsString()
  status_code!: string;

  @ApiProperty()
  @IsNotEmpty()
  @IsString()
  gross_amount!: string;

  @ApiProperty()
  @IsNotEmpty()
  @IsString()
  signature_key!: string;
}
