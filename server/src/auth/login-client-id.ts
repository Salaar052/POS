import { createHash } from 'node:crypto';
import type { Request } from 'express';

/**
 * Derives a stable client bucket key for login rate limiting.
 *
 * Uses `req.socket.remoteAddress` unless TRUST_PROXY_HOPS is set to a positive
 * integer (then Express `req.ip` is used after `trust proxy` is configured).
 * Does not read X-Forwarded-For directly.
 */
export function resolveLoginClientKey(request: Request): string {
  const trustHops = process.env.TRUST_PROXY_HOPS?.trim();
  const useProxyIp =
    trustHops !== undefined &&
    trustHops !== '' &&
    Number.parseInt(trustHops, 10) > 0;

  const raw = useProxyIp
    ? request.ip || request.socket.remoteAddress || 'unknown'
    : request.socket.remoteAddress || 'unknown';

  return createHash('sha256')
    .update(`pakpos-login-rate:${raw}`, 'utf8')
    .digest('hex');
}
