import { Body, Controller, HttpCode, HttpStatus, Post } from '@nestjs/common';
import { BusinessRegistrationService } from './business-registration.service';
import { RegisterBusinessDto } from './dto/register-business.dto';
import { RegisterBusinessResponse } from './dto/register-business-response.dto';

@Controller('businesses')
export class BusinessRegistrationController {
  constructor(
    private readonly businessRegistrationService: BusinessRegistrationService,
  ) {}

  @Post('register')
  @HttpCode(HttpStatus.CREATED)
  register(
    @Body() dto: RegisterBusinessDto,
  ): Promise<RegisterBusinessResponse> {
    return this.businessRegistrationService.register(dto);
  }
}
