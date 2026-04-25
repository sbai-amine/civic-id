import jwt from 'jsonwebtoken';
import crypto from 'node:crypto';
import { query } from '../db/pool.js';
import {
  JWT_SECRET,
  JWT_REFRESH_SECRET,
  ACCESS_TOKEN_EXPIRES,
  REFRESH_TOKEN_EXPIRES,
} from '../config.js';

export function signAccessToken({ userRow }) {
  return jwt.sign(
    {
      sub: userRow.national_id,
      nationalID: userRow.national_id,
      userId: userRow.id,
      typ: 'access',
    },
    JWT_SECRET,
    { expiresIn: ACCESS_TOKEN_EXPIRES },
  );
}

/**
 * @returns {{ refreshToken: string, jti: string, expires: Date }}
 */
export async function createRefreshTokenForUser(userId) {
  const jti = crypto.randomBytes(32).toString('hex');
  const refreshToken = jwt.sign(
    { sub: String(userId), jti, typ: 'refresh' },
    JWT_REFRESH_SECRET,
    { expiresIn: REFRESH_TOKEN_EXPIRES },
  );
  const decoded = jwt.decode(refreshToken, { complete: true });
  const expSec = decoded?.payload?.exp;
  const expires = new Date(
    (typeof expSec === 'number' ? expSec : 0) * 1000 || Date.now() + 7 * 24 * 3600 * 1000,
  );

  await query(
    `INSERT INTO refresh_tokens (user_id, jti, expires_at) VALUES ($1, $2, $3)`,
    [userId, jti, expires],
  );

  return { refreshToken, jti, expires };
}

export function verifyAccessToken(token) {
  return jwt.verify(token, JWT_SECRET);
}

export function verifyRefreshToken(token) {
  return jwt.verify(token, JWT_REFRESH_SECRET);
}

export async function findValidRefreshByJti(jti) {
  const { rows } = await query(
    `SELECT rt.*, u.national_id, u.id AS u_id
     FROM refresh_tokens rt
     JOIN users u ON u.id = rt.user_id
     WHERE rt.jti = $1 AND rt.expires_at > now()`,
    [jti],
  );
  if (rows.length === 0) return null;
  return rows[0];
}

export async function deleteRefreshByJti(jti) {
  await query('DELETE FROM refresh_tokens WHERE jti = $1', [jti]);
}
