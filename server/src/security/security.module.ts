import { Module } from '@nestjs/common';
import { PasswordModule } from './password/password.module';
import { TokenModule } from './tokens/token.module';

@Module({
  imports: [PasswordModule, TokenModule],
  exports: [PasswordModule, TokenModule],
})
export class SecurityModule {}
