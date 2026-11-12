import { Prisma } from '@prisma/client';

const FORBIDDEN_KEY_PATTERN =
  /(password|passwd|secret|token|refresh|access|bearer|credential|apikey|api_key)/i;

export class AuditMetadataPolicyError extends Error {
  constructor(message: string) {
    super(message);
    this.name = 'AuditMetadataPolicyError';
  }
}

export function assertAuditMetadataSafe(metadata: Prisma.InputJsonValue): void {
  if (metadata === null || typeof metadata !== 'object') {
    return;
  }
  if (Array.isArray(metadata)) {
    for (const item of metadata) {
      assertAuditMetadataSafe(item as Prisma.InputJsonValue);
    }
    return;
  }
  for (const [key, value] of Object.entries(metadata)) {
    if (FORBIDDEN_KEY_PATTERN.test(key)) {
      throw new AuditMetadataPolicyError(
        `Audit metadata key "${key}" is not allowed`,
      );
    }
    if (value !== null && typeof value === 'object') {
      assertAuditMetadataSafe(value as Prisma.InputJsonValue);
    }
  }
}
