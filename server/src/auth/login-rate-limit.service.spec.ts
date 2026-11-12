import { HttpException, HttpStatus } from '@nestjs/common';
import {
  LoginRateLimitService,
  LOGIN_RATE_LIMIT_MESSAGE,
} from './login-rate-limit.service';
import { PrismaService } from '../prisma/prisma.service';

describe('LoginRateLimitService', () => {
  const clientKey = 'test-client-key';
  let service: LoginRateLimitService;
  let prisma: {
    loginRateLimitBucket: {
      findUnique: jest.Mock;
      create: jest.Mock;
      update: jest.Mock;
      deleteMany: jest.Mock;
    };
  };

  beforeEach(() => {
    process.env.LOGIN_RATE_LIMIT_MAX_ATTEMPTS = '3';
    process.env.LOGIN_RATE_LIMIT_WINDOW_SECONDS = '900';
    prisma = {
      loginRateLimitBucket: {
        findUnique: jest.fn(),
        create: jest.fn(),
        update: jest.fn(),
        deleteMany: jest.fn(),
      },
    };
    service = new LoginRateLimitService(prisma as unknown as PrismaService);
  });

  it('allows requests when bucket is under the limit', async () => {
    prisma.loginRateLimitBucket.findUnique.mockResolvedValue({
      clientKey,
      windowStartedAt: new Date(),
      attemptCount: 2,
    });
    await expect(service.assertWithinLimit(clientKey)).resolves.toBeUndefined();
  });

  it('rejects when bucket exceeded within the active window', async () => {
    prisma.loginRateLimitBucket.findUnique.mockResolvedValue({
      clientKey,
      windowStartedAt: new Date(),
      attemptCount: 3,
    });
    try {
      await service.assertWithinLimit(clientKey);
      throw new Error('expected rate limit rejection');
    } catch (error) {
      expect(error).toBeInstanceOf(HttpException);
      expect((error as HttpException).getStatus()).toBe(
        HttpStatus.TOO_MANY_REQUESTS,
      );
      expect((error as HttpException).message).toBe(LOGIN_RATE_LIMIT_MESSAGE);
    }
  });

  it('resets attempt count after window expires', async () => {
    const staleStart = new Date(Date.now() - 2 * 60 * 60 * 1000);
    prisma.loginRateLimitBucket.findUnique
      .mockResolvedValueOnce({
        clientKey,
        windowStartedAt: staleStart,
        attemptCount: 99,
      })
      .mockResolvedValueOnce(null);
    await expect(service.assertWithinLimit(clientKey)).resolves.toBeUndefined();
  });

  it('opens a new window after the previous window expires on recordAttempt', async () => {
    const staleStart = new Date(Date.now() - 2 * 60 * 60 * 1000);
    prisma.loginRateLimitBucket.findUnique.mockResolvedValue({
      clientKey,
      windowStartedAt: staleStart,
      attemptCount: 10,
    });
    prisma.loginRateLimitBucket.update.mockResolvedValue({});
    await service.recordAttempt(clientKey);
    expect(prisma.loginRateLimitBucket.update).toHaveBeenCalledWith({
      where: { clientKey },
      data: expect.objectContaining({ attemptCount: 1 }) as object,
    });
  });
});
