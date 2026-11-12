import { Module } from '@nestjs/common';
import { AuditModule } from '../audit/audit.module';
import { BusinessesModule } from '../businesses/businesses.module';
import { DevicesModule } from '../devices/devices.module';
import { SecurityModule } from '../security/security.module';
import { SessionsModule } from '../sessions/sessions.module';
import { UsersModule } from '../users/users.module';

/**
 * Aggregates identity, tenancy, session, and audit modules for future APIs.
 * No HTTP controllers are registered in Phase 4.3.
 */
@Module({
  imports: [
    SecurityModule,
    BusinessesModule,
    UsersModule,
    DevicesModule,
    SessionsModule,
    AuditModule,
  ],
  exports: [
    SecurityModule,
    BusinessesModule,
    UsersModule,
    DevicesModule,
    SessionsModule,
    AuditModule,
  ],
})
export class IdentityModule {}
