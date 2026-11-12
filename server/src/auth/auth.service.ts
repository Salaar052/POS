import { Injectable, UnauthorizedException } from '@nestjs/common';
import jwt from 'jsonwebtoken';
import {
  BusinessStatus,
  MembershipRole,
  MembershipStatus,
  RefreshTokenStatus,
  User,
  UserStatus,
} from '@prisma/client';
import { randomUUID } from 'node:crypto';
import { AuditService } from '../audit/audit.service';
import { normalizeEmail } from '../common/email/normalize-email';
import { VerifiedTenantContext } from '../common/tenant/tenant-context.types';
import { TenantAuthorizationPolicy } from '../common/tenant/tenant-authorization.policy';
import {
  assertJwtAccessSecretConfigured,
  loadAuthConfig,
} from '../config/auth.config';
import { BusinessesRepository } from '../businesses/businesses.repository';
import { MembershipsRepository } from '../businesses/memberships.repository';
import { PasswordHashingService } from '../security/password/password-hashing.service';
import { TokenHashService } from '../security/tokens/token-hash.service';
import { SessionsRepository } from '../sessions/sessions.repository';
import { UsersRepository } from '../users/users.repository';
import {
  INVALID_CREDENTIALS_MESSAGE,
  SESSION_INVALID_MESSAGE,
} from './auth-messages';
import {
  AuthMeResponse,
  AuthSessionResponse,
} from './dto/auth-session-response.dto';
import { LoginDto } from './dto/login.dto';
import { AccessTokenPayload } from './jwt-payload';
import { LoginRateLimitService } from './login-rate-limit.service';

const LOGIN_AUDIT = 'auth.login.success';
const LOGOUT_AUDIT = 'auth.logout';

@Injectable()
export class AuthService {
  private readonly config = loadAuthConfig();

  private accessTokenSecret(): string {
    assertJwtAccessSecretConfigured();
    return process.env.JWT_ACCESS_SECRET!.trim();
  }

  constructor(
    private readonly usersRepository: UsersRepository,
    private readonly membershipsRepository: MembershipsRepository,
    private readonly businessesRepository: BusinessesRepository,
    private readonly sessionsRepository: SessionsRepository,
    private readonly passwordHashing: PasswordHashingService,
    private readonly tokenHashing: TokenHashService,
    private readonly auditService: AuditService,
    private readonly loginRateLimit: LoginRateLimitService,
  ) {}

  async login(dto: LoginDto, clientKey: string): Promise<AuthSessionResponse> {
    await this.loginRateLimit.assertWithinLimit(clientKey);
    try {
      const credentials = await this.verifyLoginCredentials(dto);
      const session = await this.issueSession(credentials, LOGIN_AUDIT);
      await this.loginRateLimit.recordAttempt(clientKey);
      return session;
    } catch (error) {
      await this.loginRateLimit.recordAttempt(clientKey);
      throw error;
    }
  }

  async restoreSession(
    refreshToken: string,
    businessId: string,
  ): Promise<AuthSessionResponse> {
    const session = await this.resolveActiveRefreshToken(refreshToken);
    if (session.businessId !== businessId) {
      throw new UnauthorizedException(SESSION_INVALID_MESSAGE);
    }

    const user = await this.requireActiveUser(session.userId);
    const membership = await this.requireActiveMembership(
      session.userId,
      businessId,
    );
    const business = await this.requireActiveBusiness(businessId);

    await this.sessionsRepository.touchLastUsed(session.id);

    return this.buildSessionResponse(
      user,
      business,
      membership,
      refreshToken,
      this.signAccessToken(user.id, business.id, membership.role),
    );
  }

  async logout(refreshToken: string): Promise<{ serverRevoked: boolean }> {
    let serverRevoked = false;
    try {
      const session = await this.resolveActiveRefreshToken(refreshToken);
      await this.sessionsRepository.revokeById(session.id);
      await this.auditService.append({
        businessId: session.businessId ?? undefined,
        actorUserId: session.userId,
        eventType: LOGOUT_AUDIT,
        entityType: 'RefreshToken',
        entityId: session.id,
        metadata: { outcome: 'revoked' },
      });
      serverRevoked = true;
    } catch {
      // Caller still clears local credentials; do not claim server revocation.
    }
    return { serverRevoked };
  }

  async getMeFromAccessToken(accessToken: string): Promise<AuthMeResponse> {
    const context = await this.verifyAccessToken(accessToken);
    const user = await this.requireActiveUser(context.userId);
    const business = await this.requireActiveBusiness(context.businessId);
    const membership = await this.requireActiveMembership(
      context.userId,
      context.businessId,
    );
    TenantAuthorizationPolicy.assertActiveMembership(membership.status);

    return {
      user: this.toUserSummary(user),
      business: this.toBusinessSummary(business),
      membership: this.toMembershipSummary(membership),
    };
  }

  async verifyAccessToken(accessToken: string): Promise<VerifiedTenantContext> {
    assertJwtAccessSecretConfigured();
    let payload: AccessTokenPayload;
    try {
      payload = jwt.verify(accessToken, this.accessTokenSecret(), {
        issuer: this.config.jwtIssuer,
        audience: this.config.jwtAudience,
      }) as AccessTokenPayload;
    } catch {
      throw new UnauthorizedException(SESSION_INVALID_MESSAGE);
    }

    if (!payload?.sub || !payload.bid || !payload.role) {
      throw new UnauthorizedException(SESSION_INVALID_MESSAGE);
    }

    const membership = await this.requireActiveMembership(
      payload.sub,
      payload.bid,
    );
    TenantAuthorizationPolicy.assertActiveMembership(membership.status);

    if (membership.role !== payload.role) {
      throw new UnauthorizedException(SESSION_INVALID_MESSAGE);
    }

    await this.requireActiveUser(payload.sub);
    await this.requireActiveBusiness(payload.bid);

    return {
      userId: payload.sub,
      businessId: payload.bid,
      membershipStatus: membership.status,
      membershipRole: membership.role,
    };
  }

  private async verifyLoginCredentials(dto: LoginDto): Promise<{
    user: User;
    businessId: string;
  }> {
    const normalizedEmail = normalizeEmail(dto.email);
    const user =
      await this.usersRepository.findByNormalizedEmail(normalizedEmail);
    if (!user) {
      throw new UnauthorizedException(INVALID_CREDENTIALS_MESSAGE);
    }

    const passwordValid = await this.passwordHashing.verifyPassword(
      user.passwordHash,
      dto.password,
    );
    if (!passwordValid) {
      throw new UnauthorizedException(INVALID_CREDENTIALS_MESSAGE);
    }

    if (user.status !== UserStatus.ACTIVE) {
      throw new UnauthorizedException(INVALID_CREDENTIALS_MESSAGE);
    }

    const membership = await this.membershipsRepository.findForUserAndBusiness(
      user.id,
      dto.businessId,
    );
    if (!membership || membership.status !== MembershipStatus.ACTIVE) {
      throw new UnauthorizedException(INVALID_CREDENTIALS_MESSAGE);
    }

    await this.requireActiveBusiness(dto.businessId);

    return { user, businessId: dto.businessId };
  }

  private async issueSession(
    credentials: { user: User; businessId: string },
    auditEvent: string,
  ): Promise<AuthSessionResponse> {
    const membership = await this.requireActiveMembership(
      credentials.user.id,
      credentials.businessId,
    );
    const business = await this.requireActiveBusiness(credentials.businessId);

    const refreshToken = this.tokenHashing.generateOpaqueToken();
    const tokenHash = this.tokenHashing.hashOpaqueToken(refreshToken);
    const familyId = randomUUID();
    const expiresAt = new Date(
      Date.now() + this.config.refreshTokenTtlDays * 24 * 60 * 60 * 1000,
    );

    await this.sessionsRepository.create({
      user: { connect: { id: credentials.user.id } },
      business: { connect: { id: credentials.businessId } },
      tokenHash,
      tokenFamilyId: familyId,
      expiresAt,
    });

    await this.auditService.append({
      businessId: credentials.businessId,
      actorUserId: credentials.user.id,
      eventType: auditEvent,
      entityType: 'User',
      entityId: credentials.user.id,
      metadata: { channel: 'password' },
    });

    const accessToken = this.signAccessToken(
      credentials.user.id,
      credentials.businessId,
      membership.role,
    );

    return this.buildSessionResponse(
      credentials.user,
      business,
      membership,
      refreshToken,
      accessToken,
    );
  }

  private buildSessionResponse(
    user: User,
    business: Awaited<ReturnType<BusinessesRepository['findById']>>,
    membership: Awaited<
      ReturnType<MembershipsRepository['findForUserAndBusiness']>
    >,
    refreshToken: string,
    accessToken: string,
  ): AuthSessionResponse {
    if (!business || !membership) {
      throw new UnauthorizedException(SESSION_INVALID_MESSAGE);
    }
    return {
      accessToken,
      refreshToken,
      accessTokenExpiresInSeconds: this.config.jwtAccessTtlSeconds,
      user: this.toUserSummary(user),
      business: this.toBusinessSummary(business),
      membership: this.toMembershipSummary(membership),
    };
  }

  private signAccessToken(
    userId: string,
    businessId: string,
    role: MembershipRole,
  ): string {
    assertJwtAccessSecretConfigured();
    const payload: AccessTokenPayload = {
      sub: userId,
      bid: businessId,
      role,
    };
    return jwt.sign(payload, this.accessTokenSecret(), {
      expiresIn: this.config.jwtAccessTtlSeconds,
      issuer: this.config.jwtIssuer,
      audience: this.config.jwtAudience,
    });
  }

  private async resolveActiveRefreshToken(refreshToken: string) {
    let tokenHash: string;
    try {
      tokenHash = this.tokenHashing.hashOpaqueToken(refreshToken);
    } catch {
      throw new UnauthorizedException(SESSION_INVALID_MESSAGE);
    }

    const session = await this.sessionsRepository.findByTokenHash(tokenHash);
    if (!session) {
      throw new UnauthorizedException(SESSION_INVALID_MESSAGE);
    }
    if (session.status !== RefreshTokenStatus.ACTIVE) {
      throw new UnauthorizedException(SESSION_INVALID_MESSAGE);
    }
    if (session.expiresAt.getTime() <= Date.now()) {
      await this.sessionsRepository.revokeById(session.id);
      throw new UnauthorizedException(SESSION_INVALID_MESSAGE);
    }
    if (!session.businessId) {
      throw new UnauthorizedException(SESSION_INVALID_MESSAGE);
    }

    return session;
  }

  private async requireActiveUser(userId: string): Promise<User> {
    const user = await this.usersRepository.findById(userId);
    if (!user || user.status !== UserStatus.ACTIVE) {
      throw new UnauthorizedException(SESSION_INVALID_MESSAGE);
    }
    return user;
  }

  private async requireActiveMembership(userId: string, businessId: string) {
    const membership = await this.membershipsRepository.findForUserAndBusiness(
      userId,
      businessId,
    );
    if (!membership) {
      throw new UnauthorizedException(SESSION_INVALID_MESSAGE);
    }
    TenantAuthorizationPolicy.assertActiveMembership(membership.status);
    return membership;
  }

  private async requireActiveBusiness(businessId: string) {
    const business = await this.businessesRepository.findById(businessId);
    if (!business || business.status !== BusinessStatus.ACTIVE) {
      throw new UnauthorizedException(INVALID_CREDENTIALS_MESSAGE);
    }
    return business;
  }

  private toUserSummary(user: User) {
    return {
      id: user.id,
      name: user.name,
      email: user.email,
      status: user.status,
    };
  }

  private toBusinessSummary(
    business: NonNullable<
      Awaited<ReturnType<BusinessesRepository['findById']>>
    >,
  ) {
    return {
      id: business.id,
      name: business.name,
      status: business.status,
    };
  }

  private toMembershipSummary(
    membership: NonNullable<
      Awaited<ReturnType<MembershipsRepository['findForUserAndBusiness']>>
    >,
  ) {
    return {
      id: membership.id,
      role: membership.role,
      status: membership.status,
    };
  }
}
