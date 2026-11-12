import { Injectable } from '@nestjs/common';
import { Device, DeviceStatus, Prisma } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class DevicesRepository {
  constructor(private readonly prisma: PrismaService) {}

  findByBusinessAndIdentifierHash(
    businessId: string,
    deviceIdentifierHash: string,
  ): Promise<Device | null> {
    return this.prisma.device.findUnique({
      where: {
        businessId_deviceIdentifierHash: { businessId, deviceIdentifierHash },
      },
    });
  }

  findActiveForBusiness(businessId: string): Promise<Device[]> {
    return this.prisma.device.findMany({
      where: { businessId, status: DeviceStatus.ACTIVE },
    });
  }

  create(data: Prisma.DeviceCreateInput): Promise<Device> {
    return this.prisma.device.create({ data });
  }
}
