import { HttpException, HttpStatus, Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { loadLoginRateLimitConfig } from './login-rate-limit.config';

export const LOGIN_RATE_LIMIT_MESSAGE =
  'Too many sign-in attempts. Try again later.';

@Injectable()
export class LoginRateLimitService {
  private readonly config = loadLoginRateLimitConfig();

  constructor(private readonly prisma: PrismaService) {}

  async assertWithinLimit(clientKey: string): Promise<void> {
    const now = new Date();
    const bucket = await this.prisma.loginRateLimitBucket.findUnique({
      where: { clientKey },
    });
    if (!bucket) {
      return;
    }
    const windowEnd = new Date(
      bucket.windowStartedAt.getTime() + this.config.windowSeconds * 1000,
    );
    if (now >= windowEnd) {
      return;
    }
    if (bucket.attemptCount >= this.config.maxAttempts) {
      throw new HttpException(
        LOGIN_RATE_LIMIT_MESSAGE,
        HttpStatus.TOO_MANY_REQUESTS,
      );
    }
  }

  /**
   * Records a login attempt (success or failure) against the shared bucket.
   */
  async recordAttempt(clientKey: string): Promise<void> {
    const now = new Date();
    const windowMs = this.config.windowSeconds * 1000;
    const existing = await this.prisma.loginRateLimitBucket.findUnique({
      where: { clientKey },
    });

    if (!existing) {
      await this.prisma.loginRateLimitBucket.create({
        data: {
          clientKey,
          windowStartedAt: now,
          attemptCount: 1,
        },
      });
      return;
    }

    const windowEnd = new Date(existing.windowStartedAt.getTime() + windowMs);
    if (now >= windowEnd) {
      await this.prisma.loginRateLimitBucket.update({
        where: { clientKey },
        data: {
          windowStartedAt: now,
          attemptCount: 1,
        },
      });
      return;
    }

    await this.prisma.loginRateLimitBucket.update({
      where: { clientKey },
      data: { attemptCount: existing.attemptCount + 1 },
    });
  }

  /** Test-only helper to reset a client bucket. */
  async resetClientForTests(clientKey: string): Promise<void> {
    await this.prisma.loginRateLimitBucket.deleteMany({ where: { clientKey } });
  }
}
