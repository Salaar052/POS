import {
  BusinessStatus,
  MembershipRole,
  MembershipStatus,
  UserStatus,
} from '@prisma/client';

export type AuthUserSummary = {
  id: string;
  name: string;
  email: string;
  status: UserStatus;
};

export type AuthBusinessSummary = {
  id: string;
  name: string;
  status: BusinessStatus;
};

export type AuthMembershipSummary = {
  id: string;
  role: MembershipRole;
  status: MembershipStatus;
};

export type AuthSessionResponse = {
  accessToken: string;
  refreshToken: string;
  accessTokenExpiresInSeconds: number;
  user: AuthUserSummary;
  business: AuthBusinessSummary;
  membership: AuthMembershipSummary;
};

export type AuthMeResponse = {
  user: AuthUserSummary;
  business: AuthBusinessSummary;
  membership: AuthMembershipSummary;
};
