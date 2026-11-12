import {
  ConflictException,
  InternalServerErrorException,
} from '@nestjs/common';
import {
  BusinessStatus,
  MembershipRole,
  MembershipStatus,
  UserStatus,
} from '@prisma/client';
import { PrismaClientKnownRequestError } from '@prisma/client/runtime/library';
import { AuditService } from '../audit/audit.service';
import { PrismaService } from '../prisma/prisma.service';
import { PasswordHashingService } from '../security/password/password-hashing.service';
import { BusinessRegistrationService } from './business-registration.service';
import { RegisterBusinessDto } from './dto/register-business.dto';

describe('BusinessRegistrationService', () => {
  const baseDto: RegisterBusinessDto = {
    businessName: 'Karachi Electronics',
    ownerName: 'Ali Owner',
    ownerEmail: 'Owner@Example.COM',
    password: 'secure-password-42',
  };

  let service: BusinessRegistrationService;
  let passwordHashing: jest.Mocked<
    Pick<PasswordHashingService, 'hashPassword'>
  >;
  let auditService: jest.Mocked<Pick<AuditService, 'prepareAppendData'>>;
  let transactionHandlers: {
    business: { create: jest.Mock };
    user: { create: jest.Mock };
    businessMembership: { create: jest.Mock };
    auditLog: { create: jest.Mock };
    device: { create: jest.Mock };
    refreshToken: { create: jest.Mock };
  };

  beforeEach(() => {
    passwordHashing = {
      hashPassword: jest
        .fn()
        .mockResolvedValue('$argon2id$v=19$not-a-real-hash'),
    };
    auditService = {
      prepareAppendData: jest.fn().mockReturnValue({
        eventType: 'business.registered',
        entityType: 'Business',
        metadata: {},
      }),
    };

    transactionHandlers = {
      business: {
        create: jest.fn().mockResolvedValue({
          id: 'business-1',
          name: baseDto.businessName,
          phone: null,
          email: null,
          currencyCode: 'PKR',
          timezone: 'Asia/Karachi',
          status: BusinessStatus.ACTIVE,
          createdAt: new Date('2026-01-01T00:00:00.000Z'),
        }),
      },
      user: {
        create: jest.fn().mockResolvedValue({
          id: 'user-1',
          name: baseDto.ownerName,
          email: 'Owner@Example.COM',
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
      device: { create: jest.fn() },
      refreshToken: { create: jest.fn() },
    };

    const prisma = {
      $transaction: jest.fn(
        (callback: (tx: typeof transactionHandlers) => unknown) =>
          Promise.resolve(callback(transactionHandlers)),
      ),
    } as unknown as PrismaService;

    service = new BusinessRegistrationService(
      prisma,
      passwordHashing as unknown as PasswordHashingService,
      auditService as unknown as AuditService,
    );
  });

  it('registers business, owner, OWNER membership, and audit atomically', async () => {
    const response = await service.register(baseDto);

    expect(passwordHashing.hashPassword).toHaveBeenCalledWith(baseDto.password);
    expect(transactionHandlers.business.create).toHaveBeenCalledTimes(1);
    expect(transactionHandlers.user.create).toHaveBeenCalledWith({
      data: {
        name: baseDto.ownerName,
        email: 'Owner@Example.COM',
        normalizedEmail: 'owner@example.com',
        passwordHash: '$argon2id$v=19$not-a-real-hash',
        status: UserStatus.PENDING_VERIFICATION,
      },
    });
    expect(transactionHandlers.businessMembership.create).toHaveBeenCalledWith({
      data: {
        businessId: 'business-1',
        userId: 'user-1',
        role: MembershipRole.OWNER,
        status: MembershipStatus.ACTIVE,
      },
    });
    expect(transactionHandlers.auditLog.create).toHaveBeenCalledTimes(1);
    expect(transactionHandlers.device.create).not.toHaveBeenCalled();
    expect(transactionHandlers.refreshToken.create).not.toHaveBeenCalled();
    expect(response.owner.email).toBe('Owner@Example.COM');
    expect(JSON.stringify(response)).not.toContain(baseDto.password);
    expect(JSON.stringify(response)).not.toContain('argon2');
  });

  it('maps duplicate normalized email to conflict response', async () => {
    const prismaError = new PrismaClientKnownRequestError('duplicate', {
      code: 'P2002',
      clientVersion: '6.19.2',
      meta: { modelName: 'User', target: ['normalizedEmail'] },
    });
    transactionHandlers.user.create.mockRejectedValue(prismaError);

    await expect(service.register(baseDto)).rejects.toBeInstanceOf(
      ConflictException,
    );
    expect(transactionHandlers.auditLog.create).not.toHaveBeenCalled();
  });

  it('rolls back when audit creation fails', async () => {
    transactionHandlers.auditLog.create.mockRejectedValue(
      new Error('audit failed'),
    );

    await expect(service.register(baseDto)).rejects.toBeInstanceOf(
      InternalServerErrorException,
    );
  });
});
