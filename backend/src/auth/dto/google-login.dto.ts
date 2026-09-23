import { IsNotEmpty, IsString } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class GoogleLoginDto {
  @ApiProperty()
  @IsNotEmpty()
  @IsString()
  idToken!: string;
}
