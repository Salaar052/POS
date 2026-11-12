import {
  BusinessStatus,
  MembershipRole,
  MembershipStatus,
  UserStatus,
} from '@prisma/client';

export interface RegisteredBusinessResponse {
  id: string;
  name: string;
  phone: string | null;
  email: string | null;
  currencyCode: string;
  timezone: string;
  status: BusinessStatus;
  createdAt: string;
}

export interface RegisteredOwnerResponse {
  id: string;
  name: string;
  email: string;
  status: UserStatus;
  createdAt: string;
}

export interface RegisteredMembershipResponse {
  id: string;
  role: MembershipRole;
  status: MembershipStatus;
}

export interface RegisterBusinessResponse {
  business: RegisteredBusinessResponse;
  owner: RegisteredOwnerResponse;
  membership: RegisteredMembershipResponse;
}
