import { IsNotEmpty, IsNumber, IsOptional, IsString, IsUUID, Max, Min } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateReviewDto {
  @ApiProperty()
  @IsNotEmpty()
  @IsUUID()
  orderId!: string;

  @ApiProperty()
  @IsNotEmpty()
  @IsUUID()
  merchantId!: string;

  @ApiProperty()
  @IsNotEmpty()
  @IsNumber()
  @Min(1)
  @Max(5)
  rating!: number;

  @ApiProperty()
  @IsOptional()
  @IsString()
  comment?: string;
}
