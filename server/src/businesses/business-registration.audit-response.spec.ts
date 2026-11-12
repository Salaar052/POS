import { MembershipRole, MembershipStatus, UserStatus } from '@prisma/client';
import { AuditService } from '../audit/audit.service';
import { PrismaService } from '../prisma/prisma.service';
import { PasswordHashingService } from '../security/password/password-hashing.service';
import { BusinessRegistrationService } from './business-registration.service';
import { RegisterBusinessDto } from './dto/register-business.dto';

describe('BusinessRegistrationService audit and response safety', () => {
  const auditService = new AuditService({} as PrismaService);
  let passwordHashing: jest.Mocked<
    Pick<PasswordHashingService, 'hashPassword'>
  >;

  beforeEach(() => {
    passwordHashing = {
      hashPassword: jest.fn().mockResolvedValue('$argon2id$v=19$hash'),
    };
  });

  it('registration metadata passes real AuditService.prepareAppendData', () => {
    const data = auditService.prepareAppendData({
      businessId: 'business-1',
      actorUserId: 'user-1',
      eventType: 'business.registered',
      entityType: 'Business',
      entityId: 'business-1',
      metadata: { registrationChannel: 'public_api' },
    });
    expect(data.metadata).toEqual({ registrationChannel: 'public_api' });
  });

  it('rejects password fields in registration audit metadata', () => {
    expect(() =>
      auditService.prepareAppendData({
        eventType: 'business.registered',
        entityType: 'Business',
        metadata: { passwordHash: 'must-not-appear' },
      }),
    ).toThrow();
    expect(() =>
      auditService.prepareAppendData({
        eventType: 'business.registered',
        entityType: 'Business',
        metadata: { password: 'must-not-appear' },
      }),
    ).toThrow();
  });

  it('response omits password and passwordHash', async () => {
    const transactionHandlers = {
      business: {
        create: jest.fn().mockResolvedValue({
          id: 'business-1',
          name: 'Shop',
          phone: null,
          email: null,
          currencyCode: 'PKR',
          timezone: 'Asia/Karachi',
          status: 'ACTIVE',
          createdAt: new Date('2026-01-01T00:00:00.000Z'),
        }),
      },
      user: {
        create: jest.fn().mockResolvedValue({
          id: 'user-1',
          name: 'Owner',
          email: 'owner@example.com',
          status: UserStatus.PENDING_VERIFICATION,
          createdAt: new Date('2026-01-01T00:00:00.000Z'),
        }),
      },
      businessMembership: {
        create: jest.fn().mockResolvedValue({
          id: 'membership-1',
          role: MembershipRole.OWNER,
          status: MembershipStatus.ACTIVE,
        }),
      },
      auditLog: { create: jest.fn().mockResolvedValue({ id: 'audit-1' }) },
    };

    const prisma = {
      $transaction: jest.fn(
        (callback: (tx: typeof transactionHandlers) => unknown) =>
          Promise.resolve(callback(transactionHandlers)),
      ),
    } as unknown as PrismaService;

    const dto: RegisterBusinessDto = {
      businessName: 'Shop',
      ownerName: 'Owner',
      ownerEmail: 'owner@example.com',
      password: 'super-secret-pass-42',
    };

    const service = new BusinessRegistrationService(
      prisma,
      passwordHashing as unknown as PasswordHashingService,
      auditService,
    );

    const response = await service.register(dto);
    const serialized = JSON.stringify(response);
    const forbidden = ['password', 'passwordHash', '$argon2', dto.password];
    for (const needle of forbidden) {
      expect(serialized).not.toContain(needle);
    }
    expect(Object.keys(response.owner as object)).toEqual(
      expect.arrayContaining(['id', 'name', 'email', 'status', 'createdAt']),
    );
    expect((response.owner as { password?: string }).password).toBeUndefined();
  });
});
