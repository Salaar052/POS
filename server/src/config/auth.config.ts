export interface AuthConfig {
  jwtAccessTtlSeconds: number;
  refreshTokenTtlDays: number;
  jwtIssuer: string;
  jwtAudience: string;
}

const DEFAULTS: AuthConfig = {
  jwtAccessTtlSeconds: 900,
  refreshTokenTtlDays: 30,
  jwtIssuer: 'pak-pos-api',
  jwtAudience: 'pak-pos-clients',
};

/**
 * Validates future JWT/session settings without requiring secrets at boot.
 * Access-token signing secrets are validated when auth endpoints are added.
 */
export function loadAuthConfig(
  env: NodeJS.ProcessEnv = process.env,
): AuthConfig {
  const jwtAccessTtlSeconds = parsePositiveInt(
    env.JWT_ACCESS_TTL_SECONDS,
    DEFAULTS.jwtAccessTtlSeconds,
    'JWT_ACCESS_TTL_SECONDS',
  );
  const refreshTokenTtlDays = parsePositiveInt(
    env.REFRESH_TOKEN_TTL_DAYS,
    DEFAULTS.refreshTokenTtlDays,
    'REFRESH_TOKEN_TTL_DAYS',
  );

  return {
    jwtAccessTtlSeconds,
    refreshTokenTtlDays,
    jwtIssuer: env.JWT_ISSUER?.trim() || DEFAULTS.jwtIssuer,
    jwtAudience: env.JWT_AUDIENCE?.trim() || DEFAULTS.jwtAudience,
  };
}

export function assertJwtAccessSecretConfigured(
  env: NodeJS.ProcessEnv = process.env,
): void {
  const secret = env.JWT_ACCESS_SECRET?.trim();
  if (!secret || secret.length < 32) {
    throw new Error(
      'JWT_ACCESS_SECRET must be set and at least 32 characters before issuing tokens',
    );
  }
}

function parsePositiveInt(
  raw: string | undefined,
  fallback: number,
  name: string,
): number {
  if (raw === undefined || raw === '') {
    return fallback;
  }
  const value = Number.parseInt(raw, 10);
  if (!Number.isFinite(value) || value <= 0) {
    throw new Error(`${name} must be a positive integer`);
  }
  return value;
}
