import { IsInt, IsNotEmpty, IsUUID, Min } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateSurplusDto {
  @ApiProperty()
  @IsNotEmpty()
  @IsUUID()
  menuItemId!: string;

  @ApiProperty()
  @IsNotEmpty()
  @IsInt()
  @Min(1)
  discountPrice!: number;

  @ApiProperty()
  @IsNotEmpty()
  @IsInt()
  @Min(1)
  stock!: number;
}
