import {
  IsEmail,
  IsOptional,
  IsString,
  Matches,
  MaxLength,
  MinLength,
} from 'class-validator';

/**
 * Public business registration payload. Schema has no address/city/country fields.
 */
export class RegisterBusinessDto {
  @IsString()
  @MinLength(2)
  @MaxLength(200)
  businessName!: string;

  @IsOptional()
  @IsString()
  @MaxLength(50)
  businessPhone?: string;

  @IsOptional()
  @IsEmail()
  @MaxLength(320)
  businessEmail?: string;

  @IsString()
  @MinLength(2)
  @MaxLength(200)
  ownerName!: string;

  @IsEmail()
  @MaxLength(320)
  ownerEmail!: string;

  @IsString()
  @MinLength(12)
  @MaxLength(128)
  @Matches(/^(?=.*[A-Za-z])(?=.*\d).+$/, {
    message: 'password must include at least one letter and one number',
  })
  password!: string;
}
