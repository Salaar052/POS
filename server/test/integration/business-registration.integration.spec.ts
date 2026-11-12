import './setup-integration-env';
import {
  ConflictException,
  InternalServerErrorException,
} from '@nestjs/common';
import { MembershipRole } from '@prisma/client';
import * as argon2 from 'argon2';
import { AuditService } from '../../src/audit/audit.service';
import { BusinessRegistrationService } from '../../src/businesses/business-registration.service';
import { RegisterBusinessDto } from '../../src/businesses/dto/register-business.dto';
import { PasswordHashingService } from '../../src/security/password/password-hashing.service';
import { PrismaService } from '../../src/prisma/prisma.service';
import {
  createIntegrationPrismaClient,
  readPublicBusinessCount,
  resetIntegrationData,
} from './integration-db';
import { resolveIntegrationTestDatabase } from './test-database.guard';

const guard = resolveIntegrationTestDatabase();
const describeIntegration = guard.ok ? describe : describe.skip;

describeIntegration(
  'BusinessRegistrationService (PostgreSQL integration)',
  () => {
    let prisma: PrismaService;
    let service: BusinessRegistrationService;
    let auditService: AuditService;
    let passwordService: PasswordHashingService;
    let applicationDatabaseUrl: string;
    let publicBusinessCountBefore = 0;

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
      const client = await createIntegrationPrismaClient();
      applicationDatabaseUrl = client.applicationDatabaseUrl;
      publicBusinessCountBefore = await readPublicBusinessCount(
        applicationDatabaseUrl,
      );
      prisma = client.prisma as unknown as PrismaService;
      auditService = new AuditService(prisma);
      passwordService = new PasswordHashingService();
      service = new BusinessRegistrationService(
        prisma,
        passwordService,
        auditService,
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
      service = new BusinessRegistrationService(
        prisma,
        passwordService,
        auditService,
      );
    });

    it('A. persists business, user, OWNER membership, audit; no device/session', async () => {
      const dto = baseDto();
      const response = await service.register(dto);

      expect(response.membership.role).toBe(MembershipRole.OWNER);
      const [
        businessCount,
        userCount,
        membershipCount,
        auditCount,
        deviceCount,
        tokenCount,
      ] = await Promise.all([
        prisma.business.count(),
        prisma.user.count(),
        prisma.businessMembership.count(),
        prisma.auditLog.count(),
        prisma.device.count(),
        prisma.refreshToken.count(),
      ]);
      expect(businessCount).toBe(1);
      expect(userCount).toBe(1);
      expect(membershipCount).toBe(1);
      expect(auditCount).toBe(1);
      expect(deviceCount).toBe(0);
      expect(tokenCount).toBe(0);

      const user = await prisma.user.findFirstOrThrow();
      expect(user.passwordHash).not.toBe(dto.password);
      expect(user.passwordHash.startsWith('$argon2id$')).toBe(true);
      await expect(
        argon2.verify(user.passwordHash, dto.password),
      ).resolves.toBe(true);

      const json = JSON.stringify(response);
      expect(json).not.toContain(dto.password);
      expect(json).not.toContain('passwordHash');
      expect(json).not.toContain('$argon2');
    });

    it('B. rejects duplicate email after normalization', async () => {
      const email = `dup-${Date.now()}@example.com`;
      const first: RegisterBusinessDto = {
        businessName: 'First Shop',
        ownerName: 'Owner One',
        ownerEmail: email,
        password: 'integration-pass-99',
      };
      const second: RegisterBusinessDto = {
        businessName: 'Second Shop',
        ownerName: 'Owner Two',
        ownerEmail: `  ${email.toUpperCase()}  `,
        password: 'integration-pass-99',
      };

      await service.register(first);
      await expect(service.register(second)).rejects.toBeInstanceOf(
        ConflictException,
      );

      expect(await prisma.user.count()).toBe(1);
      expect(await prisma.business.count()).toBe(1);
      expect(await prisma.businessMembership.count()).toBe(1);
      expect(await prisma.auditLog.count()).toBe(1);

      const survivingBusiness = await prisma.business.findFirstOrThrow();
      expect(survivingBusiness.name).toBe('First Shop');
    });

    it('C. rolls back when fault injected after user creation', async () => {
      const failingService = new BusinessRegistrationService(
        prisma,
        passwordService,
        auditService,
        {
          afterUserCreated: () => {
            throw new Error('integration fault after user');
          },
        },
      );

      await expect(failingService.register(baseDto())).rejects.toBeInstanceOf(
        InternalServerErrorException,
      );

      expect(await prisma.business.count()).toBe(0);
      expect(await prisma.user.count()).toBe(0);
      expect(await prisma.businessMembership.count()).toBe(0);
      expect(await prisma.auditLog.count()).toBe(0);
    });

    it('D. rolls back when fault injected after membership creation', async () => {
      const failingService = new BusinessRegistrationService(
        prisma,
        passwordService,
        auditService,
        {
          afterMembershipCreated: () => {
            throw new Error('integration fault after membership');
          },
        },
      );

      await expect(failingService.register(baseDto())).rejects.toBeInstanceOf(
        InternalServerErrorException,
      );

      expect(await prisma.business.count()).toBe(0);
      expect(await prisma.user.count()).toBe(0);
      expect(await prisma.businessMembership.count()).toBe(0);
      expect(await prisma.auditLog.count()).toBe(0);
    });

    it('E. concurrent duplicate registration leaves one successful set', async () => {
      const email = `race-${Date.now()}@example.com`;
      const dtoA: RegisterBusinessDto = {
        businessName: 'Race Shop A',
        ownerName: 'Race Owner',
        ownerEmail: email,
        password: 'integration-pass-99',
      };
      const dtoB: RegisterBusinessDto = {
        businessName: 'Race Shop B',
        ownerName: 'Race Owner',
        ownerEmail: email.toUpperCase(),
        password: 'integration-pass-99',
      };

      const results = await Promise.allSettled([
        service.register(dtoA),
        service.register(dtoB),
      ]);

      const fulfilled = results.filter((r) => r.status === 'fulfilled');
      const rejected = results.filter((r) => r.status === 'rejected');
      expect(fulfilled).toHaveLength(1);
      expect(rejected).toHaveLength(1);
      expect(
        rejected.some(
          (r) =>
            r.status === 'rejected' && r.reason instanceof ConflictException,
        ),
      ).toBe(true);

      expect(await prisma.user.count()).toBe(1);
      expect(await prisma.business.count()).toBe(1);
      expect(await prisma.businessMembership.count()).toBe(1);
      expect(await prisma.auditLog.count()).toBe(1);
    });
  },
);

if (!guard.ok) {
  console.warn(
    `[integration] Skipping PostgreSQL integration tests: ${guard.reason}`,
  );
}
