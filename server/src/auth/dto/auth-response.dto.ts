import { MembershipRole } from '@prisma/client';

export type AuthSessionUserDto = {
  id: string;
  name: string;
  email: string;
  status: string;
};

export type AuthBusinessDto = {
  id: string;
  name: string;
};

export type AuthTokenBundleDto = {
  accessToken: string;
  refreshToken: string;
  expiresIn: number;
  tokenType: 'Bearer';
  user: AuthSessionUserDto;
  business: AuthBusinessDto;
  membershipRole: MembershipRole;
};

export type AuthSessionSummaryDto = {
  user: AuthSessionUserDto;
  business: AuthBusinessDto;
  membershipRole: MembershipRole;
};
