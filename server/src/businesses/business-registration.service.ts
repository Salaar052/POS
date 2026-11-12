import { Inject, Injectable, Optional } from '@nestjs/common';
import {
  MembershipRole,
  MembershipStatus,
  Prisma,
  UserStatus,
} from '@prisma/client';
import { AuditService } from '../audit/audit.service';
import type { BusinessRegistrationTestHooks } from './business-registration.test-hooks';
import { REGISTRATION_TEST_HOOKS } from './business-registration.test-hooks';
import { mapRegistrationPersistenceError } from './registration-prisma-errors';
import { normalizeEmail } from '../common/email/normalize-email';
import { PrismaService } from '../prisma/prisma.service';
import { PasswordHashingService } from '../security/password/password-hashing.service';
import { RegisterBusinessDto } from './dto/register-business.dto';
import { RegisterBusinessResponse } from './dto/register-business-response.dto';

const REGISTRATION_AUDIT_EVENT = 'business.registered';

@Injectable()
export class BusinessRegistrationService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly passwordHashing: PasswordHashingService,
    private readonly auditService: AuditService,
    @Optional()
    @Inject(REGISTRATION_TEST_HOOKS)
    private readonly testHooks?: BusinessRegistrationTestHooks,
  ) {}

  async register(dto: RegisterBusinessDto): Promise<RegisterBusinessResponse> {
    const ownerEmailDisplay = dto.ownerEmail.trim();
    const normalizedOwnerEmail = normalizeEmail(dto.ownerEmail);
    const passwordHash = await this.passwordHashing.hashPassword(dto.password);

    try {
      const result = await this.prisma.$transaction(async (tx) => {
        const business = await tx.business.create({
          data: {
            name: dto.businessName.trim(),
            phone: dto.businessPhone?.trim() || undefined,
            email: dto.businessEmail?.trim() || undefined,
          },
        });

        const user = await tx.user.create({
          data: {
            name: dto.ownerName.trim(),
            email: ownerEmailDisplay,
            normalizedEmail: normalizedOwnerEmail,
            passwordHash,
            status: UserStatus.PENDING_VERIFICATION,
          },
        });

        await this.testHooks?.afterUserCreated?.(tx);

        const membership = await tx.businessMembership.create({
          data: {
            businessId: business.id,
            userId: user.id,
            role: MembershipRole.OWNER,
            status: MembershipStatus.ACTIVE,
          },
        });

        await this.testHooks?.afterMembershipCreated?.(tx);

        const auditData = this.auditService.prepareAppendData({
          businessId: business.id,
          actorUserId: user.id,
          eventType: REGISTRATION_AUDIT_EVENT,
          entityType: 'Business',
          entityId: business.id,
          metadata: {
            registrationChannel: 'public_api',
          },
        });

        await tx.auditLog.create({ data: auditData });

        return { business, user, membership };
      });

      return this.toResponse(result);
    } catch (error) {
      mapRegistrationPersistenceError(error);
    }
  }

  private toResponse(result: {
    business: Prisma.BusinessGetPayload<object>;
    user: Prisma.UserGetPayload<object>;
    membership: Prisma.BusinessMembershipGetPayload<object>;
  }): RegisterBusinessResponse {
    return {
      business: {
        id: result.business.id,
        name: result.business.name,
        phone: result.business.phone,
        email: result.business.email,
        currencyCode: result.business.currencyCode,
        timezone: result.business.timezone,
        status: result.business.status,
        createdAt: result.business.createdAt.toISOString(),
      },
      owner: {
        id: result.user.id,
        name: result.user.name,
        email: result.user.email,
        status: result.user.status,
        createdAt: result.user.createdAt.toISOString(),
      },
      membership: {
        id: result.membership.id,
        role: result.membership.role,
        status: result.membership.status,
      },
    };
  }
}
