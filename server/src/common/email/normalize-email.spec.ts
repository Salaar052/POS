import { normalizeEmail } from './normalize-email';

describe('normalizeEmail', () => {
  it('trims and lowercases', () => {
    expect(normalizeEmail('  Owner@Example.COM ')).toBe('owner@example.com');
  });

  it('rejects empty values', () => {
    expect(() => normalizeEmail('   ')).toThrow(/empty/);
  });
});
