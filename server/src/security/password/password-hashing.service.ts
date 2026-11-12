import { Injectable } from '@nestjs/common';
import * as argon2 from 'argon2';

@Injectable()
export class PasswordHashingService {
  async hashPassword(plainPassword: string): Promise<string> {
    this.assertPasswordInput(plainPassword);
    if (process.env.NODE_ENV === 'test') {
      return argon2.hash(plainPassword, {
        type: argon2.argon2id,
        memoryCost: 2 ** 10,
        timeCost: 1,
        parallelism: 1,
      });
    }
    return argon2.hash(plainPassword, { type: argon2.argon2id });
  }

  async verifyPassword(
    passwordHash: string,
    plainPassword: string,
  ): Promise<boolean> {
    this.assertPasswordInput(plainPassword);
    if (!passwordHash?.trim()) {
      return false;
    }
    try {
      return await argon2.verify(passwordHash, plainPassword);
    } catch {
      return false;
    }
  }

  private assertPasswordInput(plainPassword: string): void {
    if (!plainPassword || plainPassword.length === 0) {
      throw new Error('Password must not be empty');
    }
  }
}
