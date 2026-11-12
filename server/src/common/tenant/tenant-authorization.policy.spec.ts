import { DeviceStatus, MembershipRole, MembershipStatus } from '@prisma/client';
import {
  TenantAuthorizationError,
  TenantAuthorizationPolicy,
} from './tenant-authorization.policy';
import { VerifiedTenantContext } from './tenant-context.types';

describe('TenantAuthorizationPolicy', () => {
  const baseContext: VerifiedTenantContext = {
    userId: 'user-1',
    businessId: 'business-1',
    membershipRole: MembershipRole.OWNER,
    membershipStatus: MembershipStatus.ACTIVE,
    deviceId: 'device-1',
    deviceStatus: DeviceStatus.ACTIVE,
  };

  it('rejects mismatched client businessId', () => {
    expect(() =>
      TenantAuthorizationPolicy.rejectClientSuppliedBusinessId(
        'business-evil',
        'business-1',
      ),
    ).toThrow(TenantAuthorizationError);
  });

  it('requires active membership', () => {
    expect(() =>
      TenantAuthorizationPolicy.assertActiveMembership(
        MembershipStatus.SUSPENDED,
      ),
    ).toThrow(TenantAuthorizationError);
  });

  it('rejects revoked devices independently of membership', () => {
    expect(() =>
      TenantAuthorizationPolicy.assertDeviceEligible(DeviceStatus.REVOKED),
    ).toThrow(/revoked/i);
  });

  it('scopes resource access to verified business context', () => {
    expect(() =>
      TenantAuthorizationPolicy.assertBusinessScopedAccess(
        baseContext,
        'business-2',
      ),
    ).toThrow(/different business/);
  });
});
