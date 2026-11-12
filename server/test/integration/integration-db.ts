import { execSync } from 'node:child_process';
import { PrismaClient } from '@prisma/client';
import { INTEGRATION_SCHEMA_NAME } from './postgres-url';
import { resolveIntegrationTestDatabase } from './test-database.guard';

let integrationSchemaPrepared = false;

const REQUIRED_INTEGRATION_MIGRATIONS = [
  '20251110133000_identity_foundation',
  '20251111013000_auth_login_rate_limit',
] as const;

async function integrationSchemaMigrationsApplied(
  databaseUrl: string,
): Promise<boolean> {
  const probe = new PrismaClient({
    datasources: { db: { url: databaseUrl } },
  });
  try {
    await probe.$connect();
    for (const migrationName of REQUIRED_INTEGRATION_MIGRATIONS) {
      const rows = await probe.$queryRaw<{ count: bigint }[]>`
        SELECT COUNT(*)::bigint AS count
        FROM "_prisma_migrations"
        WHERE migration_name = ${migrationName}
          AND finished_at IS NOT NULL
      `;
      if (Number(rows[0]?.count ?? 0n) < 1) {
        return false;
      }
    }
    return true;
  } catch {
    return false;
  } finally {
    await probe.$disconnect();
  }
}

export async function createIntegrationPrismaClient(): Promise<{
  prisma: PrismaClient;
  testDatabaseUrl: string;
  applicationDatabaseUrl: string;
}> {
  const guard = resolveIntegrationTestDatabase();
  if (!guard.ok || !guard.testDatabaseUrl) {
    throw new Error(guard.reason ?? 'Integration database guard failed');
  }

  const applicationDatabaseUrl = process.env.DATABASE_URL?.trim();
  if (!applicationDatabaseUrl) {
    throw new Error('DATABASE_URL is required to verify public schema safety');
  }

  if (!integrationSchemaPrepared) {
    const bootstrap = new PrismaClient({
      datasources: { db: { url: guard.testDatabaseUrl } },
    });
    await bootstrap.$connect();
    await bootstrap.$executeRawUnsafe(
      `CREATE SCHEMA IF NOT EXISTS "${INTEGRATION_SCHEMA_NAME}";`,
    );
    await bootstrap.$disconnect();

    const migrationsApplied = await integrationSchemaMigrationsApplied(
      guard.testDatabaseUrl,
    );
    if (!migrationsApplied) {
      execSync('npx prisma migrate deploy', {
        cwd: process.cwd(),
        env: {
          ...process.env,
          DATABASE_URL: guard.testDatabaseUrl,
          PRISMA_MIGRATE_ADVISORY_LOCK_TIMEOUT: '120000',
        },
        stdio: 'pipe',
      });
    }
    integrationSchemaPrepared = true;
  }

  const prisma = new PrismaClient({
    datasources: {
      db: { url: guard.testDatabaseUrl },
    },
  });
  await prisma.$connect();
  return {
    prisma,
    testDatabaseUrl: guard.testDatabaseUrl,
    applicationDatabaseUrl,
  };
}

export async function resetIntegrationData(
  prisma: PrismaClient,
): Promise<void> {
  await prisma.$executeRawUnsafe(
    `TRUNCATE TABLE "${INTEGRATION_SCHEMA_NAME}"."LoginRateLimitBucket", "${INTEGRATION_SCHEMA_NAME}"."AuditLog", "${INTEGRATION_SCHEMA_NAME}"."RefreshToken", "${INTEGRATION_SCHEMA_NAME}"."Device", "${INTEGRATION_SCHEMA_NAME}"."BusinessMembership", "${INTEGRATION_SCHEMA_NAME}"."User", "${INTEGRATION_SCHEMA_NAME}"."Business" RESTART IDENTITY CASCADE;`,
  );
}

export async function readPublicBusinessCount(
  applicationDatabaseUrl: string,
): Promise<number> {
  const publicClient = new PrismaClient({
    datasources: { db: { url: applicationDatabaseUrl } },
  });
  try {
    await publicClient.$connect();
    return publicClient.business.count();
  } finally {
    await publicClient.$disconnect();
  }
}
