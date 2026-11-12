import { config } from 'dotenv';
import { resolve } from 'node:path';
import { deriveNeonIntegrationTestUrlFromApp } from './test-database.guard';

config({ path: resolve(process.cwd(), '.env'), override: true });

if (
  !process.env.TEST_DATABASE_URL?.trim() &&
  process.env.DATABASE_URL?.trim()
) {
  try {
    process.env.TEST_DATABASE_URL = deriveNeonIntegrationTestUrlFromApp();
  } catch {
    // TEST_DATABASE_URL must be set explicitly for non-Neon/local targets.
  }
}
