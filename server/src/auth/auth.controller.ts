import {
  Body,
  Controller,
  Get,
  Headers,
  HttpCode,
  HttpStatus,
  Post,
  Req,
  UseGuards,
} from '@nestjs/common';
import type { Request } from 'express';
import { AuthService } from './auth.service';
import { JwtAuthGuard } from './jwt-auth.guard';
import { LoginDto } from './dto/login.dto';
import { RestoreSessionDto } from './dto/restore-session.dto';
import { LogoutDto } from './dto/logout.dto';
import { resolveLoginClientKey } from './login-client-id';
import { SESSION_INVALID_MESSAGE } from './auth-messages';
import { UnauthorizedException } from '@nestjs/common';

@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('login')
  @HttpCode(HttpStatus.OK)
  login(@Body() dto: LoginDto, @Req() request: Request) {
    return this.authService.login(dto, resolveLoginClientKey(request));
  }

  @Post('session/restore')
  @HttpCode(HttpStatus.OK)
  restoreSession(@Body() dto: RestoreSessionDto) {
    return this.authService.restoreSession(dto.refreshToken, dto.businessId);
  }

  @Post('logout')
  @HttpCode(HttpStatus.OK)
  logout(@Body() dto: LogoutDto) {
    return this.authService.logout(dto.refreshToken);
  }

  @Get('me')
  @UseGuards(JwtAuthGuard)
  me(@Headers('authorization') authorization?: string) {
    const token = this.extractBearer(authorization);
    return this.authService.getMeFromAccessToken(token);
  }

  private extractBearer(authorization?: string): string {
    if (!authorization?.startsWith('Bearer ')) {
      throw new UnauthorizedException(SESSION_INVALID_MESSAGE);
    }
    const token = authorization.slice('Bearer '.length).trim();
    if (!token) {
      throw new UnauthorizedException(SESSION_INVALID_MESSAGE);
    }
    return token;
  }
}
