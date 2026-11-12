import { DeviceStatus, MembershipRole, MembershipStatus } from '@prisma/client';

/**
 * Server-derived tenant context populated only after authentication
 * and membership verification (never from raw client businessId alone).
 */
export interface VerifiedTenantContext {
  userId: string;
  businessId: string;
  membershipRole: MembershipRole;
  membershipStatus: MembershipStatus;
  deviceId?: string;
  deviceStatus?: DeviceStatus;
}
