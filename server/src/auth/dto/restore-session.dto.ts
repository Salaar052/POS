import { IsString, IsUUID, MinLength } from 'class-validator';

export class RestoreSessionDto {
  @IsString()
  @MinLength(32)
  refreshToken!: string;

  @IsUUID('4')
  businessId!: string;
}
