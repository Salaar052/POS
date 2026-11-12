import {
  ConflictException,
  InternalServerErrorException,
} from '@nestjs/common';
import { PrismaClientKnownRequestError } from '@prisma/client/runtime/library';
import {
  isDuplicateNormalizedEmailError,
  mapRegistrationPersistenceError,
} from './registration-prisma-errors';

function p2002(target: string | string[], modelName = 'User') {
  return new PrismaClientKnownRequestError('Unique constraint', {
    code: 'P2002',
    clientVersion: '6.19.2',
    meta: { modelName, target },
  });
}

describe('registration-prisma-errors', () => {
  it('detects normalizedEmail unique violations (array target)', () => {
    expect(isDuplicateNormalizedEmailError(p2002(['normalizedEmail']))).toBe(
      true,
    );
  });

  it('detects normalizedEmail unique violations (string target)', () => {
    expect(
      isDuplicateNormalizedEmailError(p2002('User_normalizedEmail_key')),
    ).toBe(true);
  });

  it('rejects unrelated P2002 targets', () => {
    expect(isDuplicateNormalizedEmailError(p2002(['tokenHash']))).toBe(false);
    expect(
      isDuplicateNormalizedEmailError(p2002(['businessId', 'userId'])),
    ).toBe(false);
  });

  it('maps duplicate email to conflict response', () => {
    expect(() =>
      mapRegistrationPersistenceError(p2002(['normalizedEmail'])),
    ).toThrow(ConflictException);
  });

  it('maps unrelated unique violations to generic internal error', () => {
    expect(() =>
      mapRegistrationPersistenceError(p2002(['tokenHash'], 'RefreshToken')),
    ).toThrow(InternalServerErrorException);
  });

  it('does not leak prisma meta in thrown messages', () => {
    try {
      mapRegistrationPersistenceError(p2002(['normalizedEmail']));
    } catch (error) {
      expect(error).toBeInstanceOf(ConflictException);
      expect((error as ConflictException).message).not.toContain('P2002');
      expect((error as ConflictException).message).not.toContain('User');
    }
  });
});
