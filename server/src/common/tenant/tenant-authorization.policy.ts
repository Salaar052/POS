import { DeviceStatus, MembershipStatus } from '@prisma/client';
import { VerifiedTenantContext } from './tenant-context.types';

export class TenantAuthorizationError extends Error {
  constructor(message: string) {
    super(message);
    this.name = 'TenantAuthorizationError';
  }
}

/**
 * Pure policy helpers for future guards and services.
 * Does not read HTTP headers or request bodies for business identity.
 */
export class TenantAuthorizationPolicy {
  /**
   * Rejects trusting a client-supplied business identifier for authorization.
   */
  static rejectClientSuppliedBusinessId(
    clientBusinessId: string | undefined,
    trustedBusinessId: string,
  ): void {
    if (!clientBusinessId) {
      return;
    }
    if (clientBusinessId !== trustedBusinessId) {
      throw new TenantAuthorizationError(
        'Client-supplied businessId does not match verified tenant context',
      );
    }
  }

  static assertActiveMembership(
    membershipStatus: MembershipStatus,
    role?: string,
  ): void {
    if (membershipStatus !== MembershipStatus.ACTIVE) {
      throw new TenantAuthorizationError(
        `Membership is not active (status=${membershipStatus})`,
      );
    }
    if (role !== undefined && role.length === 0) {
      throw new TenantAuthorizationError('Membership role is missing');
    }
  }

  static assertDeviceEligible(deviceStatus: DeviceStatus): void {
    if (deviceStatus === DeviceStatus.REVOKED) {
      throw new TenantAuthorizationError('Device has been revoked');
    }
    if (deviceStatus === DeviceStatus.SUSPENDED) {
      throw new TenantAuthorizationError('Device is suspended');
    }
    if (deviceStatus !== DeviceStatus.ACTIVE) {
      throw new TenantAuthorizationError(
        `Device is not active (status=${deviceStatus})`,
      );
    }
  }

  static assertBusinessScopedAccess(
    context: VerifiedTenantContext,
    resourceBusinessId: string,
  ): void {
    if (context.businessId !== resourceBusinessId) {
      throw new TenantAuthorizationError(
        'Resource belongs to a different business',
      );
    }
    this.assertActiveMembership(context.membershipStatus);
    if (context.deviceId && context.deviceStatus) {
      this.assertDeviceEligible(context.deviceStatus);
    }
  }
}
