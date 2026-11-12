import { Injectable } from '@nestjs/common';
import { BusinessMembership, MembershipStatus, Prisma } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class MembershipsRepository {
  constructor(private readonly prisma: PrismaService) {}

  findForUserAndBusiness(
    userId: string,
    businessId: string,
  ): Promise<BusinessMembership | null> {
    return this.prisma.businessMembership.findUnique({
      where: { businessId_userId: { businessId, userId } },
    });
  }

  findActiveForUser(userId: string): Promise<BusinessMembership[]> {
    return this.prisma.businessMembership.findMany({
      where: { userId, status: MembershipStatus.ACTIVE },
    });
  }

  create(
    data: Prisma.BusinessMembershipCreateInput,
  ): Promise<BusinessMembership> {
    return this.prisma.businessMembership.create({ data });
  }
}
