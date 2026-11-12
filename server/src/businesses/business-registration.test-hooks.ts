import { Prisma } from '@prisma/client';

/**
 * Test-only hooks for integration fault injection. Not registered in production.
 */
export interface BusinessRegistrationTestHooks {
  afterUserCreated?(tx: Prisma.TransactionClient): void | Promise<void>;
  afterMembershipCreated?(tx: Prisma.TransactionClient): void | Promise<void>;
}

export const REGISTRATION_TEST_HOOKS = Symbol('REGISTRATION_TEST_HOOKS');
