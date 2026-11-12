import './setup-integration-env';
import { UnauthorizedException } from '@nestjs/common';
import { RefreshTokenStatus, UserStatus } from '@prisma/client';
import { AuthService } from '../../src/auth/auth.service';
import { BusinessRegistrationService } from '../../src/businesses/business-registration.service';
import { RegisterBusinessDto } from '../../src/businesses/dto/register-business.dto';
import { AuditService } from '../../src/audit/audit.service';
import { PasswordHashingService } from '../../src/security/password/password-hashing.service';
import { TokenHashService } from '../../src/security/tokens/token-hash.service';
import { UsersRepository } from '../../src/users/users.repository';
import { MembershipsRepository } from '../../src/businesses/memberships.repository';
import { BusinessesRepository } from '../../src/businesses/businesses.repository';
import { SessionsRepository } from '../../src/sessions/sessions.repository';
import { LoginRateLimitService } from '../../src/auth/login-rate-limit.service';
import { PrismaService } from '../../src/prisma/prisma.service';
import {
  createIntegrationPrismaClient,
  readPublicBusinessCount,
  resetIntegrationData,
} from './integration-db';
import { resolveIntegrationTestDatabase } from './test-database.guard';

const guard = resolveIntegrationTestDatabase();
const describeIntegration = guard.ok ? describe : describe.skip;

describeIntegration('AuthService (PostgreSQL integration)', () => {
  let prisma: PrismaService;
  let authService: AuthService;
  let registrationService: BusinessRegistrationService;
  let tokenHashing: TokenHashService;
  let applicationDatabaseUrl: string;
  let publicBusinessCountBefore = 0;
  const clientKey = 'integration-client-key';

  const baseDto = (): RegisterBusinessDto => ({
    businessName: `Shop ${Date.now()}`,
    ownerName: 'Integration Owner',
    ownerEmail: `owner-${Date.now()}@example.com`,
    password: 'integration-pass-99',
  });

  beforeAll(async () => {
    if (!guard.ok) {
      return;
    }
    process.env.JWT_ACCESS_SECRET =
      process.env.JWT_ACCESS_SECRET ??
      'integration-jwt-secret-at-least-32-characters-long';
    const client = await createIntegrationPrismaClient();
    applicationDatabaseUrl = client.applicationDatabaseUrl;
    publicBusinessCountBefore = await readPublicBusinessCount(
      applicationDatabaseUrl,
    );
    prisma = client.prisma as unknown as PrismaService;
    tokenHashing = new TokenHashService();
    const passwordService = new PasswordHashingService();
    const auditService = new AuditService(prisma);
    registrationService = new BusinessRegistrationService(
      prisma,
      passwordService,
      auditService,
    );
    authService = new AuthService(
      new UsersRepository(prisma),
      new MembershipsRepository(prisma),
      new BusinessesRepository(prisma),
      new SessionsRepository(prisma),
      passwordService,
      tokenHashing,
      auditService,
      new LoginRateLimitService(prisma),
    );
  }, 180_000);

  afterAll(async () => {
    if (applicationDatabaseUrl) {
      const publicBusinessCountAfter = await readPublicBusinessCount(
        applicationDatabaseUrl,
      );
      expect(publicBusinessCountAfter).toBe(publicBusinessCountBefore);
    }
    await prisma?.$disconnect();
  });

  beforeEach(async () => {
    await resetIntegrationData(prisma);
    await prisma.loginRateLimitBucket.deleteMany();
  });

  async function registerActiveOwner(): Promise<{
    businessId: string;
    email: string;
    password: string;
  }> {
    const dto = baseDto();
    const registered = await registrationService.register(dto);
    await prisma.user.update({
      where: { id: registered.owner.id },
      data: { status: UserStatus.ACTIVE, emailVerifiedAt: new Date() },
    });
    return {
      businessId: registered.business.id,
      email: dto.ownerEmail,
      password: dto.password,
    };
  }

  it('logs in and persists hashed refresh token', async () => {
    const { businessId, email, password } = await registerActiveOwner();
    const session = await authService.login(
      { email, password, businessId },
      clientKey,
    );

    expect(session.refreshToken).toBeDefined();
    expect(session.accessToken).toBeDefined();
    expect(JSON.stringify(session)).not.toContain(password);
    expect(JSON.stringify(session)).not.toContain('passwordHash');

    const tokenHash = tokenHashing.hashOpaqueToken(session.refreshToken);
    const row = await prisma.refreshToken.findUnique({ where: { tokenHash } });
    expect(row).not.toBeNull();
    expect(row!.businessId).toBe(businessId);
    expect(row!.status).toBe(RefreshTokenStatus.ACTIVE);
  });

  it('rejects invalid credentials without revealing account state', async () => {
    const { businessId, email } = await registerActiveOwner();
    await expect(
      authService.login(
        { email, password: 'wrong-password-99', businessId },
        clientKey,
      ),
    ).rejects.toBeInstanceOf(UnauthorizedException);
  });

  it('restores session for matching business and rejects mismatch', async () => {
    const { businessId, email, password } = await registerActiveOwner();
    const session = await authService.login(
      { email, password, businessId },
      clientKey,
    );

    const restored = await authService.restoreSession(
      session.refreshToken,
      businessId,
    );
    expect(restored.business.id).toBe(businessId);

    const otherBusinessId = 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa';
    await expect(
      authService.restoreSession(session.refreshToken, otherBusinessId),
    ).rejects.toBeInstanceOf(UnauthorizedException);
  });

  it('revokes refresh token on logout', async () => {
    const { businessId, email, password } = await registerActiveOwner();
    const session = await authService.login(
      { email, password, businessId },
      clientKey,
    );
    const tokenHash = tokenHashing.hashOpaqueToken(session.refreshToken);

    const logout = await authService.logout(session.refreshToken);
    expect(logout.serverRevoked).toBe(true);

    const row = await prisma.refreshToken.findUnique({ where: { tokenHash } });
    expect(row!.status).toBe(RefreshTokenStatus.REVOKED);

    await expect(
      authService.restoreSession(session.refreshToken, businessId),
    ).rejects.toBeInstanceOf(UnauthorizedException);
  });

  it('rejects expired refresh tokens', async () => {
    const { businessId, email, password } = await registerActiveOwner();
    const session = await authService.login(
      { email, password, businessId },
      clientKey,
    );
    const tokenHash = tokenHashing.hashOpaqueToken(session.refreshToken);
    await prisma.refreshToken.update({
      where: { tokenHash },
      data: { expiresAt: new Date(Date.now() - 60_000) },
    });

    await expect(
      authService.restoreSession(session.refreshToken, businessId),
    ).rejects.toBeInstanceOf(UnauthorizedException);
  });
});
