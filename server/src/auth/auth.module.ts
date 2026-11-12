import { Module } from '@nestjs/common';
import { AuditModule } from '../audit/audit.module';
import { BusinessesModule } from '../businesses/businesses.module';
import { SecurityModule } from '../security/security.module';
import { SessionsModule } from '../sessions/sessions.module';
import { UsersModule } from '../users/users.module';
import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';
import { JwtAuthGuard } from './jwt-auth.guard';
import { LoginRateLimitService } from './login-rate-limit.service';

@Module({
  imports: [
    SecurityModule,
    UsersModule,
    SessionsModule,
    BusinessesModule,
    AuditModule,
  ],
  controllers: [AuthController],
  providers: [AuthService, JwtAuthGuard, LoginRateLimitService],
  exports: [AuthService, JwtAuthGuard],
})
export class AuthModule {}
