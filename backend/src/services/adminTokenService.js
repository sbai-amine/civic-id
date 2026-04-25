import jwt from 'jsonwebtoken';
import { JWT_ADMIN_SECRET, ADMIN_JWT_EXPIRES } from '../config.js';

export const ADMIN_ISSUER = 'bridgeid-admin';
export const ADMIN_AUDIENCE = 'bridgeid-api-admin';

/**
 * Short-lived admin JWT (separate from citizen access/refresh and different secret).
 */
export function signAdminToken({ sub = 'admin-key' } = {}) {
  return jwt.sign(
    {
      typ: 'admin',
      sub: String(sub),
    },
    JWT_ADMIN_SECRET,
    { expiresIn: ADMIN_JWT_EXPIRES, issuer: ADMIN_ISSUER, audience: ADMIN_AUDIENCE },
  );
}

export function verifyAdminAccessToken(token) {
  return jwt.verify(token, JWT_ADMIN_SECRET, {
    issuer: ADMIN_ISSUER,
    audience: ADMIN_AUDIENCE,
  });
}
