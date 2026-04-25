import dotenv from 'dotenv';

dotenv.config();

export const PORT = Number(process.env.PORT) || 3000;

export const DATABASE_URL = process.env.DATABASE_URL || '';

/** Symmetric key for access JWT. */
export const JWT_SECRET = process.env.JWT_SECRET || 'dev-only-access-secret-change-in-production';
/** Refresh tokens signed with a separate secret. */
export const JWT_REFRESH_SECRET =
  process.env.JWT_REFRESH_SECRET || 'dev-only-refresh-secret-change-in-production';

/**
 * Admin-only access tokens (separate from citizen JWT; different issuer/audience).
 * Must differ from JWT_SECRET in production.
 */
export const JWT_ADMIN_SECRET =
  process.env.JWT_ADMIN_SECRET || 'dev-only-admin-secret-change-in-production';

export const ACCESS_TOKEN_EXPIRES = process.env.ACCESS_TOKEN_EXPIRES || '15m';
export const REFRESH_TOKEN_EXPIRES = process.env.REFRESH_TOKEN_EXPIRES || '7d';
export const ADMIN_JWT_EXPIRES = process.env.ADMIN_JWT_EXPIRES || '1h';

export const BCRYPT_ROUNDS = Number(process.env.BCRYPT_ROUNDS) || 10;

/** Comma-separated national IDs of admin users (optional; or use admin API key / admin JWT). */
export const ADMIN_NATIONAL_IDS = (process.env.ADMIN_NATIONAL_IDS || '')
  .split(',')
  .map((s) => s.trim())
  .filter(Boolean);

/**
 * Global admin key (Bearer or X-Admin-Key). Can be exchanged for a short admin JWT
 * via POST /auth/admin/token.
 */
export const ADMIN_API_KEY = process.env.ADMIN_API_KEY || '';

/**
 * @deprecated Use agent API keys in database. Kept for one release of backward compatibility.
 */
export const AGENT_SYNC_SECRET = process.env.AGENT_SYNC_SECRET || '';

export const MAX_LOGIN_ATTEMPTS = Number(process.env.MAX_LOGIN_ATTEMPTS) || 5;
export const LOCKOUT_MINUTES = Number(process.env.LOCKOUT_MINUTES) || 15;

export const RATE_LIMIT_WINDOW_MS = Number(process.env.RATE_LIMIT_WINDOW_MS) || 15 * 60 * 1000;
export const RATE_LIMIT_MAX = Number(process.env.RATE_LIMIT_MAX) || 100;
export const LOGIN_RATE_LIMIT_MAX = Number(process.env.LOGIN_RATE_LIMIT_MAX) || 20;
export const ADMIN_TOKEN_RATE_LIMIT_MAX = Number(process.env.ADMIN_TOKEN_RATE_LIMIT_MAX) || 10;

/**
 * CORS: comma-separated allowed browser origins, e.g. `https://app.example.com,https://localhost:8090`
 * If empty / unset, all origins are allowed (suitable for local dev only).
 */
export const CORS_ALLOWED_ORIGINS = (process.env.CORS_ORIGINS || '')
  .split(',')
  .map((s) => s.trim())
  .filter(Boolean);

/**
 * `redis://` URL for distributed rate limits. If unset, in-memory stores are used.
 */
export const REDIS_URL = process.env.REDIS_URL || '';

/**
 * Accept v1 (unsigned) citizen service QR JSON during migration. Default off for production.
 * Enable only while devices still emit legacy payloads; pair with a coordinated app upgrade.
 */
export const ALLOW_LEGACY_QR_PAYLOAD = ['1', 'true', 'yes'].includes(
  String(process.env.ALLOW_LEGACY_QR_PAYLOAD || '')
    .trim()
    .toLowerCase(),
);

export const SIGNING_PRIVATE_KEY_PEM = process.env.SIGNING_PRIVATE_KEY_PEM || '';
export const SIGNING_PUBLIC_KEY_PEM = process.env.SIGNING_PUBLIC_KEY_PEM || '';
