import { Injectable } from '@nestjs/common';
import { Prisma, RefreshToken, RefreshTokenStatus } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class SessionsRepository {
  constructor(private readonly prisma: PrismaService) {}

  findByTokenHash(tokenHash: string): Promise<RefreshToken | null> {
    return this.prisma.refreshToken.findUnique({ where: { tokenHash } });
  }

  findActiveByFamily(tokenFamilyId: string): Promise<RefreshToken[]> {
    return this.prisma.refreshToken.findMany({
      where: { tokenFamilyId, status: RefreshTokenStatus.ACTIVE },
    });
  }

  create(data: Prisma.RefreshTokenCreateInput): Promise<RefreshToken> {
    return this.prisma.refreshToken.create({ data });
  }

  update(
    id: string,
    data: Prisma.RefreshTokenUpdateInput,
  ): Promise<RefreshToken> {
    return this.prisma.refreshToken.update({ where: { id }, data });
  }

  revokeById(id: string, revokedAt: Date = new Date()): Promise<RefreshToken> {
    return this.prisma.refreshToken.update({
      where: { id },
      data: {
        status: RefreshTokenStatus.REVOKED,
        revokedAt,
      },
    });
  }

  touchLastUsed(
    id: string,
    lastUsedAt: Date = new Date(),
  ): Promise<RefreshToken> {
    return this.prisma.refreshToken.update({
      where: { id },
      data: { lastUsedAt },
    });
  }
}
