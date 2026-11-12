export const INTEGRATION_SCHEMA_NAME = 'pakpos_integration_test';

export interface ParsedPostgresUrl {
  host: string;
  database: string;
  schema: string;
}

export function parsePostgresConnectionUrl(
  connectionUrl: string,
): ParsedPostgresUrl {
  const normalized = connectionUrl.replace(/^postgresql:\/\//, 'http://');
  const parsed = new URL(normalized);
  const database = decodeURIComponent(parsed.pathname.replace(/^\//, ''));
  const schema = parsed.searchParams.get('schema') ?? 'public';
  return { host: parsed.host, database, schema };
}

export function appendIntegrationSchema(connectionUrl: string): string {
  if (connectionUrl.includes('schema=')) {
    throw new Error(
      'DATABASE_URL must not already set schema= when deriving TEST_DATABASE_URL',
    );
  }
  const separator = connectionUrl.includes('?') ? '&' : '?';
  return `${connectionUrl}${separator}schema=${INTEGRATION_SCHEMA_NAME}`;
}
