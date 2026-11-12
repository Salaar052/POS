import {
  assertAuditMetadataSafe,
  AuditMetadataPolicyError,
} from './audit-metadata.policy';

describe('assertAuditMetadataSafe', () => {
  it('allows benign metadata', () => {
    expect(() =>
      assertAuditMetadataSafe({
        action: 'device.updated',
        field: 'deviceName',
      }),
    ).not.toThrow();
  });

  it('rejects sensitive metadata keys', () => {
    expect(() =>
      assertAuditMetadataSafe({ refreshToken: 'must-not-appear' }),
    ).toThrow(AuditMetadataPolicyError);
    expect(() =>
      assertAuditMetadataSafe({ nested: { passwordHash: 'x' } }),
    ).toThrow(AuditMetadataPolicyError);
  });
});
