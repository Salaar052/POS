import {
  appendIntegrationSchema,
  INTEGRATION_SCHEMA_NAME,
  parsePostgresConnectionUrl,
} from './postgres-url';

export interface TestDatabaseGuardResult {
  ok: boolean;
  testDatabaseUrl?: string;
  reason?: string;
}

const LOCAL_TEST_DB_PATTERN = /(test|_test|integration)/i;

/**
 * Requires TEST_DATABASE_URL and enforces schema/host/database isolation rules.
 */
export function resolveIntegrationTestDatabase(): TestDatabaseGuardResult {
  const testUrl = process.env.TEST_DATABASE_URL?.trim();
  if (!testUrl) {
    return {
      ok: false,
      reason:
        'TEST_DATABASE_URL is not set. Integration tests require an isolated PostgreSQL target.',
    };
  }

  const appUrl = process.env.DATABASE_URL?.trim();
  if (!appUrl) {
    return {
      ok: false,
      reason:
        'DATABASE_URL is not set; cannot verify integration target against the application database.',
    };
  }

  if (testUrl === appUrl) {
    return {
      ok: false,
      reason: 'TEST_DATABASE_URL must not be identical to DATABASE_URL.',
    };
  }

  let testParsed: ReturnType<typeof parsePostgresConnectionUrl>;
  let appParsed: ReturnType<typeof parsePostgresConnectionUrl>;
  try {
    testParsed = parsePostgresConnectionUrl(testUrl);
    appParsed = parsePostgresConnectionUrl(appUrl);
  } catch {
    return {
      ok: false,
      reason:
        'DATABASE_URL or TEST_DATABASE_URL is not a valid PostgreSQL URL.',
    };
  }

  if (testParsed.schema !== INTEGRATION_SCHEMA_NAME) {
    return {
      ok: false,
      reason: `TEST_DATABASE_URL must use schema=${INTEGRATION_SCHEMA_NAME}.`,
    };
  }

  if (appParsed.schema === INTEGRATION_SCHEMA_NAME) {
    return {
      ok: false,
      reason:
        'DATABASE_URL must not use the integration schema; use the application schema (public).',
    };
  }

  if (appParsed.schema !== 'public') {
    return {
      ok: false,
      reason:
        'DATABASE_URL must target the public application schema unless explicitly documented.',
    };
  }

  const isNeon = /neon\.tech/i.test(testUrl);
  if (isNeon) {
    if (
      testParsed.host !== appParsed.host ||
      testParsed.database !== appParsed.database
    ) {
      return {
        ok: false,
        reason:
          'Neon integration URLs must use the same verified host and database as DATABASE_URL with only the schema changed.',
      };
    }
    return { ok: true, testDatabaseUrl: testUrl };
  }

  const testNameMatches =
    LOCAL_TEST_DB_PATTERN.test(testParsed.database) ||
    LOCAL_TEST_DB_PATTERN.test(testUrl);
  if (!testNameMatches) {
    return {
      ok: false,
      reason:
        'Non-Neon integration databases must include test, _test, or integration in the database name.',
    };
  }

  return { ok: true, testDatabaseUrl: testUrl };
}

export function deriveNeonIntegrationTestUrlFromApp(): string {
  const appUrl = process.env.DATABASE_URL?.trim();
  if (!appUrl) {
    throw new Error('DATABASE_URL is not set');
  }
  return appendIntegrationSchema(appUrl);
}
