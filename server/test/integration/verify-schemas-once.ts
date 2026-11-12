import { config } from 'dotenv';
import { PrismaClient } from '@prisma/client';
import { deriveNeonIntegrationTestUrlFromApp } from './test-database.guard';
import { parsePostgresConnectionUrl } from './postgres-url';

config({ path: `${process.cwd()}/.env`, override: true });

async function main() {
  const appParsed = parsePostgresConnectionUrl(process.env.DATABASE_URL ?? '');
  console.log('neonHost:', appParsed.host);
  console.log('database:', appParsed.database);
  console.log('appSchema:', appParsed.schema);

  const publicClient = new PrismaClient();
  await publicClient.$connect();
  console.log('publicBusinessCount:', await publicClient.business.count());
  await publicClient.$disconnect();

  const testUrl =
    process.env.TEST_DATABASE_URL?.trim() ??
    deriveNeonIntegrationTestUrlFromApp();
  const testParsed = parsePostgresConnectionUrl(testUrl);
  console.log('integrationSchema:', testParsed.schema);

  const testClient = new PrismaClient({
    datasources: { db: { url: testUrl } },
  });
  await testClient.$connect();
  const migrations = await testClient.$queryRaw<
    { migration_name: string }[]
  >`SELECT migration_name FROM "_prisma_migrations" ORDER BY finished_at DESC LIMIT 3`;
  console.log(
    'integrationMigrationHistory:',
    migrations.map((m) => m.migration_name),
  );
  console.log('integrationBusinessCount:', await testClient.business.count());
  await testClient.$disconnect();
}

void main();
