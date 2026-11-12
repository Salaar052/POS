import { AuditService } from './audit.service';
import { PrismaService } from '../prisma/prisma.service';

describe('AuditService', () => {
  const prisma = {
    auditLog: {
      create: jest.fn(),
      update: jest.fn(),
      delete: jest.fn(),
    },
  } as unknown as PrismaService;

  const service = new AuditService(prisma);

  it('does not expose update or delete APIs', () => {
    expect((service as { update?: unknown }).update).toBeUndefined();
    expect((service as { delete?: unknown }).delete).toBeUndefined();
    expect(typeof service.append).toBe('function');
    expect(typeof service.prepareAppendData).toBe('function');
  });

  it('rejects sensitive metadata keys before persistence', () => {
    expect(() =>
      service.prepareAppendData({
        eventType: 'test',
        entityType: 'Business',
        metadata: { refreshToken: 'nope' },
      }),
    ).toThrow();
  });
});
