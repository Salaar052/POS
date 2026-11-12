import {
  ConflictException,
  InternalServerErrorException,
} from '@nestjs/common';
import { PrismaClientKnownRequestError } from '@prisma/client/runtime/library';

const DUPLICATE_EMAIL_MESSAGE =
  'An account with this email is already registered';

/**
 * Returns true when P2002 refers to User.normalizedEmail (Prisma 6 meta.target).
 */
export function isDuplicateNormalizedEmailError(
  error: PrismaClientKnownRequestError,
): boolean {
  if (error.code !== 'P2002') {
    return false;
  }
  const target = error.meta?.target;
  if (target === undefined || target === null) {
    return false;
  }
  const fields = Array.isArray(target)
    ? target.map((field) => String(field))
    : [typeof target === 'string' ? target : ''];
  return fields.some(
    (field) =>
      field === 'normalizedEmail' || String(field).includes('normalizedEmail'),
  );
}

export function mapRegistrationPersistenceError(error: unknown): never {
  if (error instanceof ConflictException) {
    throw error;
  }
  if (
    error instanceof PrismaClientKnownRequestError &&
    isDuplicateNormalizedEmailError(error)
  ) {
    throw new ConflictException(DUPLICATE_EMAIL_MESSAGE);
  }
  throw new InternalServerErrorException('Registration failed');
}
