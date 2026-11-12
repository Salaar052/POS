import {
  CanActivate,
  ExecutionContext,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { Request } from 'express';
import { AuthService } from './auth.service';
import { SESSION_INVALID_MESSAGE } from './auth-messages';
import { VerifiedTenantContext } from '../common/tenant/tenant-context.types';

export const AUTH_TENANT_CONTEXT = 'pakposAuthTenantContext';

export type AuthenticatedRequest = Request & {
  [AUTH_TENANT_CONTEXT]?: VerifiedTenantContext;
};

@Injectable()
export class JwtAuthGuard implements CanActivate {
  constructor(private readonly authService: AuthService) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest<AuthenticatedRequest>();
    const header = request.headers.authorization;
    if (!header?.startsWith('Bearer ')) {
      throw new UnauthorizedException(SESSION_INVALID_MESSAGE);
    }
    const token = header.slice('Bearer '.length).trim();
    if (!token) {
      throw new UnauthorizedException(SESSION_INVALID_MESSAGE);
    }
    const tenant = await this.authService.verifyAccessToken(token);
    request[AUTH_TENANT_CONTEXT] = tenant;
    return true;
  }
}
