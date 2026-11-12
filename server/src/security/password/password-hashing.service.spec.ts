import { PasswordHashingService } from './password-hashing.service';

describe('PasswordHashingService', () => {
  const service = new PasswordHashingService();
  let sharedHash: string;

  beforeAll(async () => {
    sharedHash = await service.hashPassword('phase-4-3-test-password');
  });

  it('hashes password to a non-plaintext value', async () => {
    const hash = await service.hashPassword('correct-horse-battery-staple');
    expect(hash).not.toContain('correct-horse-battery-staple');
    expect(hash.startsWith('$argon2')).toBe(true);
  });

  it('verifies the correct password', async () => {
    await expect(
      service.verifyPassword(sharedHash, 'phase-4-3-test-password'),
    ).resolves.toBe(true);
  });

  it('rejects a wrong password', async () => {
    await expect(
      service.verifyPassword(sharedHash, 'wrong-password'),
    ).resolves.toBe(false);
  });

  it('rejects empty password input', async () => {
    await expect(service.hashPassword('')).rejects.toThrow(
      'Password must not be empty',
    );
  });
});
