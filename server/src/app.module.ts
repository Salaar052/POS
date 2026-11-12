import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { AuthModule } from './auth/auth.module';
import { IdentityModule } from './identity/identity.module';
import { PrismaModule } from './prisma/prisma.module';

@Module({
  imports: [PrismaModule, IdentityModule, AuthModule],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
