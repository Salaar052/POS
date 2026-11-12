import { TokenHashService } from './token-hash.service';

describe('TokenHashService', () => {
  const service = new TokenHashService();

  it('produces deterministic hashes for lookup', () => {
    const raw = 'opaque-refresh-token-example';
    const first = service.hashOpaqueToken(raw);
    const second = service.hashOpaqueToken(raw);
    expect(first).toBe(second);
    expect(first).not.toBe(raw);
    expect(first).toMatch(/^[a-f0-9]{64}$/);
  });

  it('compares tokens in constant time', () => {
    const raw = service.generateOpaqueToken();
    const hash = service.hashOpaqueToken(raw);
    expect(service.tokensMatch(raw, hash)).toBe(true);
    expect(service.tokensMatch(raw + 'x', hash)).toBe(false);
  });

  it('rejects empty token input', () => {
    expect(() => service.hashOpaqueToken('')).toThrow(
      'Token must not be empty',
    );
  });
});
