import { readFileSync } from 'node:fs';
import { join } from 'node:path';

describe('identity Prisma schema (static checks)', () => {
  const migrationSql = readFileSync(
    join(
      __dirname,
      '../../prisma/migrations/20251110133000_identity_foundation/migration.sql',
    ),
    'utf8',
  );

  it('enforces normalized email uniqueness', () => {
    expect(migrationSql).toContain(
      'CREATE UNIQUE INDEX "User_normalizedEmail_key"',
    );
  });

  it('enforces business membership uniqueness', () => {
    expect(migrationSql).toContain(
      'CREATE UNIQUE INDEX "BusinessMembership_businessId_userId_key"',
    );
  });

  it('uses restrictive deletes on business-owned relations', () => {
    expect(migrationSql).toContain('ON DELETE RESTRICT');
    expect(migrationSql).not.toContain('ON DELETE CASCADE');
  });

  it('includes append-only audit triggers', () => {
    expect(migrationSql).toContain('audit_log_no_update');
    expect(migrationSql).toContain('audit_log_no_delete');
  });
});
