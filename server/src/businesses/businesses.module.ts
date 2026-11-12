import { Module } from '@nestjs/common';
import { AuditModule } from '../audit/audit.module';
import { SecurityModule } from '../security/security.module';
import { BusinessRegistrationController } from './business-registration.controller';
import { BusinessRegistrationService } from './business-registration.service';
import { BusinessesRepository } from './businesses.repository';
import { MembershipsRepository } from './memberships.repository';

@Module({
  imports: [SecurityModule, AuditModule],
  controllers: [BusinessRegistrationController],
  providers: [
    BusinessesRepository,
    MembershipsRepository,
    BusinessRegistrationService,
  ],
  exports: [
    BusinessesRepository,
    MembershipsRepository,
    BusinessRegistrationService,
  ],
})
export class BusinessesModule {}
