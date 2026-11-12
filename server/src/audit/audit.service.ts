import { Injectable } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { assertAuditMetadataSafe } from './audit-metadata.policy';

export interface CreateAuditLogInput {
  businessId?: string | null;
  actorUserId?: string | null;
  deviceId?: string | null;
  eventType: string;
  entityType: string;
  entityId?: string | null;
  metadata?: Prisma.InputJsonValue;
}

@Injectable()
export class AuditService {
  constructor(private readonly prisma: PrismaService) {}

  validateMetadata(metadata: Prisma.InputJsonValue = {}): void {
    assertAuditMetadataSafe(metadata);
  }

  prepareAppendData(
    input: CreateAuditLogInput,
  ): Prisma.AuditLogUncheckedCreateInput {
    const metadata = input.metadata ?? {};
    assertAuditMetadataSafe(metadata);
    return {
      businessId: input.businessId ?? undefined,
      actorUserId: input.actorUserId ?? undefined,
      deviceId: input.deviceId ?? undefined,
      eventType: input.eventType,
      entityType: input.entityType,
      entityId: input.entityId ?? undefined,
      metadata: metadata,
    };
  }

  async append(input: CreateAuditLogInput): Promise<void> {
    await this.prisma.auditLog.create({
      data: this.prepareAppendData(input),
    });
  }
}
