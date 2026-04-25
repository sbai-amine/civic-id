import bcrypt from 'bcrypt';
import { query } from '../db/pool.js';
import {
  signAccessToken,
  createRefreshTokenForUser,
  verifyRefreshToken,
  findValidRefreshByJti,
  deleteRefreshByJti,
} from '../services/tokenService.js';
import { MAX_LOGIN_ATTEMPTS, LOCKOUT_MINUTES, ADMIN_API_KEY, ADMIN_JWT_EXPIRES } from '../config.js';
import { signAdminToken } from '../services/adminTokenService.js';
import { getPool } from '../db/pool.js';
import { ensureUserQrHmacKey } from '../repositories/userRepository.js';

/**
 * POST /login
 */
export async function login(req, res) {
  if (!getPool()) {
    return res.status(503).json({
      success: false,
      error: {
        code: 'DB_UNAVAILABLE',
        message: 'Set DATABASE_URL and run `npm run migrate` (see docker-compose.yml).',
      },
    });
  }
  return dbLogin(req, res);
}

async function dbLogin(req, res) {
  const { nationalID, PIN } = req.body ?? {};
  if (typeof nationalID !== 'string' || typeof PIN !== 'string') {
    return res.status(400).json({
      success: false,
      error: { code: 'VALIDATION_ERROR', message: 'Body must include string fields nationalID and PIN' },
    });
  }
  const id = nationalID.trim();
  const pin = PIN.trim();
  if (!id || !pin) {
    return res.status(400).json({
      success: false,
      error: { code: 'VALIDATION_ERROR', message: 'nationalID and PIN must not be empty' },
    });
  }

  const { rows: userRows } = await query('SELECT * FROM users WHERE national_id = $1', [id]);
  if (userRows.length === 0) {
    return res.status(401).json({
      success: false,
      error: { code: 'INVALID_CREDENTIALS', message: 'Invalid national ID or PIN' },
    });
  }
  const user = userRows[0];
  if (user.locked_until && new Date(user.locked_until) > new Date()) {
    return res.status(403).json({
      success: false,
      error: { code: 'ACCOUNT_LOCKED', message: 'Too many failed attempts. Try again later.' },
    });
  }
  const ok = await bcrypt.compare(pin, user.password_hash);
  if (!ok) {
    const nextFail = (user.failed_login_attempts || 0) + 1;
    let locked = null;
    if (nextFail >= MAX_LOGIN_ATTEMPTS) {
      locked = new Date(Date.now() + LOCKOUT_MINUTES * 60 * 1000);
    }
    await query(
      `UPDATE users SET failed_login_attempts = $1, locked_until = COALESCE($2, locked_until) WHERE id = $3`,
      [nextFail, locked, user.id],
    );
    return res.status(401).json({
      success: false,
      error: { code: 'INVALID_CREDENTIALS', message: 'Invalid national ID or PIN' },
    });
  }

  await query(
    `UPDATE users SET failed_login_attempts = 0, locked_until = NULL WHERE id = $1`,
    [user.id],
  );

  const { ACCESS_TOKEN_EXPIRES, REFRESH_TOKEN_EXPIRES } = await import('../config.js');
  const accessToken = signAccessToken({ userRow: { national_id: id, id: user.id } });
  const { refreshToken } = await createRefreshTokenForUser(user.id);
  const { qrHmacKey } = await ensureUserQrHmacKey(user.id);

  return res.status(200).json({
    success: true,
    data: {
      token: accessToken,
      accessToken,
      refreshToken,
      tokenType: 'Bearer',
      expiresIn: ACCESS_TOKEN_EXPIRES,
      refreshExpiresIn: REFRESH_TOKEN_EXPIRES,
      qrHmacKey,
    },
  });
}

/**
 * POST /auth/refresh
 */
export async function refreshAccess(req, res) {
  if (!getPool()) {
    return res.status(503).json({ success: false, error: { code: 'DB_UNAVAILABLE' } });
  }
  const { refreshToken } = req.body ?? {};
  if (typeof refreshToken !== 'string' || !refreshToken.trim()) {
    return res.status(400).json({
      success: false,
      error: { code: 'VALIDATION_ERROR', message: 'Body must include refreshToken' },
    });
  }
  let payload;
  try {
    payload = verifyRefreshToken(refreshToken.trim());
  } catch {
    return res.status(401).json({
      success: false,
      error: { code: 'INVALID_REFRESH', message: 'Invalid or expired refresh token' },
    });
  }
  if (payload.typ !== 'refresh' || !payload.jti) {
    return res.status(401).json({
      success: false,
      error: { code: 'INVALID_REFRESH', message: 'Not a refresh token' },
    });
  }
  const row = await findValidRefreshByJti(payload.jti);
  if (!row) {
    return res.status(401).json({
      success: false,
      error: { code: 'INVALID_REFRESH', message: 'Session revoked or expired' },
    });
  }
  const { ACCESS_TOKEN_EXPIRES } = await import('../config.js');
  const accessToken = signAccessToken({
    userRow: { national_id: row.national_id, id: row.u_id },
  });
  return res.status(200).json({
    success: true,
    data: { accessToken, token: accessToken, tokenType: 'Bearer', expiresIn: ACCESS_TOKEN_EXPIRES },
  });
}

/**
 * POST /auth/revoke
 */
export async function revoke(req, res) {
  if (!getPool()) {
    return res.status(503).json({ success: false, error: { code: 'DB_UNAVAILABLE' } });
  }
  const { refreshToken } = req.body ?? {};
  if (typeof refreshToken !== 'string' || !refreshToken.trim()) {
    return res.status(400).json({ success: false, error: { code: 'VALIDATION_ERROR' } });
  }
  let payload;
  try {
    payload = verifyRefreshToken(refreshToken.trim());
  } catch {
    return res.status(200).json({ success: true });
  }
  if (payload.jti) await deleteRefreshByJti(payload.jti);
  return res.status(200).json({ success: true });
}

/**
 * POST /auth/admin/token
 * Exchanges a long-lived `ADMIN_API_KEY` (only) for a short admin JWT. Same key as
 * `Authorization: Bearer` / `X-Admin-Key` on other admin routes.
 */
export async function issueAdminToken(req, res) {
  if (!ADMIN_API_KEY) {
    return res.status(501).json({
      success: false,
      error: { code: 'NOT_CONFIGURED', message: 'ADMIN_API_KEY is not set on the server' },
    });
  }
  const h = req.headers['x-admin-key'];
  const key = typeof h === 'string' ? h.trim() : '';
  const auth = req.headers.authorization;
  const bearer =
    typeof auth === 'string' && auth.toLowerCase().startsWith('bearer ')
      ? auth.slice(7).trim()
      : '';
  const provided = key || bearer;
  if (provided !== ADMIN_API_KEY) {
    return res.status(401).json({
      success: false,
      error: { code: 'UNAUTHORIZED', message: 'Valid admin key required' },
    });
  }
  const adminToken = signAdminToken({ sub: 'admin-key' });
  return res.status(200).json({
    success: true,
    data: {
      adminToken,
      tokenType: 'Bearer',
      expiresIn: ADMIN_JWT_EXPIRES,
    },
  });
}
