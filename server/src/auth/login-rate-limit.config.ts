export interface LoginRateLimitConfig {
  maxAttempts: number;
  windowSeconds: number;
}

const DEFAULTS: LoginRateLimitConfig = {
  maxAttempts: 20,
  windowSeconds: 900,
};

export function loadLoginRateLimitConfig(
  env: NodeJS.ProcessEnv = process.env,
): LoginRateLimitConfig {
  return {
    maxAttempts: parsePositiveInt(
      env.LOGIN_RATE_LIMIT_MAX_ATTEMPTS,
      DEFAULTS.maxAttempts,
      'LOGIN_RATE_LIMIT_MAX_ATTEMPTS',
    ),
    windowSeconds: parsePositiveInt(
      env.LOGIN_RATE_LIMIT_WINDOW_SECONDS,
      DEFAULTS.windowSeconds,
      'LOGIN_RATE_LIMIT_WINDOW_SECONDS',
    ),
  };
}

function parsePositiveInt(
  raw: string | undefined,
  fallback: number,
  name: string,
): number {
  if (raw === undefined || raw.trim() === '') {
    return fallback;
  }
  const value = Number.parseInt(raw, 10);
  if (!Number.isFinite(value) || value <= 0) {
    throw new Error(`${name} must be a positive integer`);
  }
  return value;
}
