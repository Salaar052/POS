import { MembershipRole } from '@prisma/client';

export type AccessTokenPayload = {
  sub: string;
  bid: string;
  role: MembershipRole;
};
