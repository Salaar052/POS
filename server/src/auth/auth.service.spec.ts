import { UnauthorizedException } from '@nestjs/common';
import {
  BusinessStatus,
  MembershipRole,
  MembershipStatus,
  RefreshTokenStatus,
  UserStatus,
} from '@prisma/client';
import { AuthService } from './auth.service';
import { AuditService } from '../audit/audit.service';
import { BusinessesRepository } from '../businesses/businesses.repository';
import { MembershipsRepository } from '../businesses/memberships.repository';
import { PasswordHashingService } from '../security/password/password-hashing.service';
import { TokenHashService } from '../security/tokens/token-hash.service';
import { SessionsRepository } from '../sessions/sessions.repository';
import { UsersRepository } from '../users/users.repository';
import { INVALID_CREDENTIALS_MESSAGE } from './auth-messages';
import { LoginRateLimitService } from './login-rate-limit.service';

const businessId = '11111111-1111-4111-8111-111111111111';
const userId = '22222222-2222-4222-8222-222222222222';
const membershipId = '33333333-3333-4333-8333-333333333333';

describe('AuthService', () => {
  const originalSecret = process.env.JWT_ACCESS_SECRET;

  beforeAll(() => {
    process.env.JWT_ACCESS_SECRET =
      'unit-test-jwt-secret-at-least-32-characters-long';
  });

  afterAll(() => {
    process.env.JWT_ACCESS_SECRET = originalSecret;
  });

  let service: AuthService;
  let usersRepository: jest.Mocked<
    Pick<UsersRepository, 'findByNormalizedEmail' | 'findById'>
  >;
  let membershipsRepository: jest.Mocked<
    Pick<MembershipsRepository, 'findForUserAndBusiness'>
  >;
  let businessesRepository: jest.Mocked<Pick<BusinessesRepository, 'findById'>>;
  let sessionsRepository: jest.Mocked<
    Pick<
      SessionsRepository,
      'create' | 'findByTokenHash' | 'revokeById' | 'touchLastUsed'
    >
  >;
  let passwordHashing: jest.Mocked<
    Pick<PasswordHashingService, 'verifyPassword'>
  >;
  let tokenHashing: TokenHashService;
  let auditService: jest.Mocked<Pick<AuditService, 'append'>>;
  let loginRateLimit: jest.Mocked<
    Pick<LoginRateLimitService, 'assertWithinLimit' | 'recordAttempt'>
  >;

  beforeEach(() => {
    usersRepository = {
      findByNormalizedEmail: jest.fn(),
      findById: jest.fn(),
    };
    membershipsRepository = {
      findForUserAndBusiness: jest.fn(),
    };
    businessesRepository = {
      findById: jest.fn(),
    };
    sessionsRepository = {
      create: jest.fn(),
      findByTokenHash: jest.fn(),
      revokeById: jest.fn(),
      touchLastUsed: jest.fn(),
    };
    passwordHashing = {
      verifyPassword: jest.fn(),
    };
    tokenHashing = new TokenHashService();
    auditService = { append: jest.fn() };
    loginRateLimit = {
      assertWithinLimit: jest.fn().mockResolvedValue(undefined),
      recordAttempt: jest.fn().mockResolvedValue(undefined),
    };
    service = new AuthService(
      usersRepository as unknown as UsersRepository,
      membershipsRepository as unknown as MembershipsRepository,
      businessesRepository as unknown as BusinessesRepository,
      sessionsRepository as unknown as SessionsRepository,
      passwordHashing as unknown as PasswordHashingService,
      tokenHashing,
      auditService as unknown as AuditService,
      loginRateLimit as unknown as LoginRateLimitService,
    );
  });

  const testClientKey = 'unit-test-client';

  const activeUser = {
    id: userId,
    name: 'Owner',
    email: 'owner@example.com',
    normalizedEmail: 'owner@example.com',
    passwordHash: 'hash',
    status: UserStatus.ACTIVE,
    emailVerifiedAt: new Date(),
    createdAt: new Date(),
    updatedAt: new Date(),
  };

  const activeMembership = {
    id: membershipId,
    businessId,
    userId,
    role: MembershipRole.OWNER,
    status: MembershipStatus.ACTIVE,
    createdAt: new Date(),
    updatedAt: new Date(),
  };

  const activeBusiness = {
    id: businessId,
    name: 'Shop',
    legalName: null,
    phone: null,
    email: null,
    currencyCode: 'PKR',
    timezone: 'Asia/Karachi',
    status: BusinessStatus.ACTIVE,
    createdAt: new Date(),
    updatedAt: new Date(),
  };

  it('rejects unknown email with generic message', async () => {
    usersRepository.findByNormalizedEmail.mockResolvedValue(null);
    await expect(
      service.login(
        {
          email: 'missing@example.com',
          password: 'password-123',
          businessId,
        },
        testClientKey,
      ),
    ).rejects.toThrow(new UnauthorizedException(INVALID_CREDENTIALS_MESSAGE));
  });

  it('rejects pending verification users on login', async () => {
    usersRepository.findByNormalizedEmail.mockResolvedValue({
      ...activeUser,
      status: UserStatus.PENDING_VERIFICATION,
    });
    passwordHashing.verifyPassword.mockResolvedValue(true);
    membershipsRepository.findForUserAndBusiness.mockResolvedValue(
      activeMembership,
    );
    businessesRepository.findById.mockResolvedValue(activeBusiness);
    await expect(
      service.login(
        {
          email: activeUser.email,
          password: 'password-123',
          businessId,
        },
        testClientKey,
      ),
    ).rejects.toThrow(new UnauthorizedException(INVALID_CREDENTIALS_MESSAGE));
  });

  it('issues access and refresh tokens on successful login', async () => {
    usersRepository.findByNormalizedEmail.mockResolvedValue(activeUser);
    passwordHashing.verifyPassword.mockResolvedValue(true);
    membershipsRepository.findForUserAndBusiness.mockResolvedValue(
      activeMembership,
    );
    businessesRepository.findById.mockResolvedValue(activeBusiness);
    sessionsRepository.create.mockResolvedValue({
      id: '44444444-4444-4444-8444-444444444444',
      userId,
      businessId,
      deviceId: null,
      tokenHash: 'hash',
      tokenFamilyId: 'family',
      status: RefreshTokenStatus.ACTIVE,
      expiresAt: new Date(Date.now() + 60_000),
      revokedAt: null,
      replacedByTokenId: null,
      createdAt: new Date(),
      lastUsedAt: null,
    });

    const session = await service.login(
      {
        email: activeUser.email,
        password: 'password-123',
        businessId,
      },
      testClientKey,
    );

    expect(session.refreshToken.length).toBeGreaterThan(32);
    expect(session.accessToken).toBeDefined();
    expect(session.user.status).toBe(UserStatus.ACTIVE);
    expect(sessionsRepository.create).toHaveBeenCalled();
    expect(auditService.append).toHaveBeenCalled();
  });

  it('rejects restore when refresh token is bound to another business', async () => {
    const raw = tokenHashing.generateOpaqueToken();
    const tokenHash = tokenHashing.hashOpaqueToken(raw);
    sessionsRepository.findByTokenHash.mockResolvedValue({
      id: 'session-id',
      userId,
      businessId,
      deviceId: null,
      tokenHash,
      tokenFamilyId: 'family',
      status: RefreshTokenStatus.ACTIVE,
      expiresAt: new Date(Date.now() + 60_000),
      revokedAt: null,
      replacedByTokenId: null,
      createdAt: new Date(),
      lastUsedAt: null,
    });
    await expect(
      service.restoreSession(raw, 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa'),
    ).rejects.toThrow(UnauthorizedException);
  });
});
