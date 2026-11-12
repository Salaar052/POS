import { INTEGRATION_SCHEMA_NAME } from './postgres-url';
import {
  deriveNeonIntegrationTestUrlFromApp,
  resolveIntegrationTestDatabase,
} from './test-database.guard';

describe('resolveIntegrationTestDatabase', () => {
  const originalEnv = process.env;

  beforeEach(() => {
    process.env = { ...originalEnv };
    delete process.env.TEST_DATABASE_URL;
    delete process.env.DATABASE_URL;
  });

  afterAll(() => {
    process.env = originalEnv;
  });

  it('fails closed when TEST_DATABASE_URL is missing', () => {
    process.env.DATABASE_URL =
      'postgresql://u:p@ep-example-pooler.us-east-2.aws.neon.tech/neondb?sslmode=require';
    const result = resolveIntegrationTestDatabase();
    expect(result.ok).toBe(false);
  });

  it('rejects when test URL equals DATABASE_URL', () => {
    const url =
      'postgresql://u:p@127.0.0.1:5432/pakpos_integration_test?schema=public';
    process.env.DATABASE_URL = url;
    process.env.TEST_DATABASE_URL = url;
    const result = resolveIntegrationTestDatabase();
    expect(result.ok).toBe(false);
  });

  it('accepts Neon POS dev with isolated integration schema', () => {
    process.env.DATABASE_URL =
      'postgresql://u:p@ep-still-sun-pooler.us-east-2.aws.neon.tech/neondb?sslmode=require';
    process.env.TEST_DATABASE_URL = deriveNeonIntegrationTestUrlFromApp();
    const result = resolveIntegrationTestDatabase();
    expect(result.ok).toBe(true);
    expect(process.env.TEST_DATABASE_URL).toContain(
      `schema=${INTEGRATION_SCHEMA_NAME}`,
    );
  });

  it('rejects Neon test URL with wrong schema', () => {
    process.env.DATABASE_URL =
      'postgresql://u:p@ep-still-sun-pooler.us-east-2.aws.neon.tech/neondb?sslmode=require';
    process.env.TEST_DATABASE_URL =
      'postgresql://u:p@ep-still-sun-pooler.us-east-2.aws.neon.tech/neondb?schema=public&sslmode=require';
    const result = resolveIntegrationTestDatabase();
    expect(result.ok).toBe(false);
  });

  it('accepts a local database with integration schema parameter', () => {
    process.env.DATABASE_URL = 'postgresql://u:p@127.0.0.1:5432/pakpos_dev';
    process.env.TEST_DATABASE_URL =
      'postgresql://u:p@127.0.0.1:5432/pakpos_integration_test?schema=pakpos_integration_test';
    const result = resolveIntegrationTestDatabase();
    expect(result.ok).toBe(true);
  });
});
