import { Injectable } from '@nestjs/common';
import { Prisma, User } from '@prisma/client';
import { normalizeEmail } from '../common/email/normalize-email';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class UsersRepository {
  constructor(private readonly prisma: PrismaService) {}

  findByNormalizedEmail(normalizedEmail: string): Promise<User | null> {
    return this.prisma.user.findUnique({
      where: { normalizedEmail },
    });
  }

  findById(id: string): Promise<User | null> {
    return this.prisma.user.findUnique({ where: { id } });
  }

  createWithNormalizedEmail(
    data: Omit<Prisma.UserCreateInput, 'normalizedEmail'> & { email: string },
  ): Promise<User> {
    const normalizedEmail = normalizeEmail(data.email);
    return this.prisma.user.create({
      data: {
        ...data,
        normalizedEmail,
      },
    });
  }
}
