import { IsBoolean, IsInt, IsOptional, Min } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class UpdateSurplusDto {
  @ApiProperty()
  @IsOptional()
  @IsInt()
  @Min(1)
  discountPrice?: number;

  @ApiProperty()
  @IsOptional()
  @IsInt()
  @Min(1)
  stock?: number;

  @ApiProperty()
  @IsOptional()
  @IsBoolean()
  isActive?: boolean;
}
