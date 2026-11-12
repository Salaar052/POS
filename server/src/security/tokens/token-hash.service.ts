import { createHash, randomBytes, timingSafeEqual } from 'node:crypto';
import { Injectable } from '@nestjs/common';

@Injectable()
export class TokenHashService {
  /**
   * Deterministic SHA-256 digest for opaque refresh token lookup.
   * Raw tokens must never be persisted.
   */
  hashOpaqueToken(rawToken: string): string {
    if (!rawToken?.trim()) {
      throw new Error('Token must not be empty');
    }
    return createHash('sha256').update(rawToken, 'utf8').digest('hex');
  }

  generateOpaqueToken(): string {
    return randomBytes(32).toString('base64url');
  }

  tokensMatch(rawToken: string, storedHash: string): boolean {
    const computed = this.hashOpaqueToken(rawToken);
    const a = Buffer.from(computed, 'utf8');
    const b = Buffer.from(storedHash, 'utf8');
    if (a.length !== b.length) {
      return false;
    }
    return timingSafeEqual(a, b);
  }
}
