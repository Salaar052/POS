import { Injectable } from '@nestjs/common';
import { Business, BusinessStatus, Prisma } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class BusinessesRepository {
  constructor(private readonly prisma: PrismaService) {}

  findById(id: string): Promise<Business | null> {
    return this.prisma.business.findUnique({ where: { id } });
  }

  findManyByStatus(status: BusinessStatus): Promise<Business[]> {
    return this.prisma.business.findMany({ where: { status } });
  }

  create(data: Prisma.BusinessCreateInput): Promise<Business> {
    return this.prisma.business.create({ data });
  }
}
