import { assertJwtAccessSecretConfigured, loadAuthConfig } from './auth.config';

describe('auth.config', () => {
  it('loads defaults when env vars are absent', () => {
    const config = loadAuthConfig({});
    expect(config.jwtAccessTtlSeconds).toBe(900);
    expect(config.refreshTokenTtlDays).toBe(30);
  });

  it('rejects invalid ttl values', () => {
    expect(() => loadAuthConfig({ JWT_ACCESS_TTL_SECONDS: '0' })).toThrow(
      /JWT_ACCESS_TTL_SECONDS/,
    );
  });

  it('requires a strong JWT secret before token issuance', () => {
    expect(() =>
      assertJwtAccessSecretConfigured({ JWT_ACCESS_SECRET: 'short' }),
    ).toThrow(/32 characters/);
  });
});
