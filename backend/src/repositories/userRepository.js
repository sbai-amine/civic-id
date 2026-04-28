import crypto from 'node:crypto';
import bcrypt from 'bcrypt';
import { query, getPool } from '../db/pool.js';

/**
 * List/search citizens for the admin console.
 * Search matches national_id prefix or full_name (case-insensitive substring).
 */
export async function listCitizens({ search, limit = 100, offset = 0 } = {}) {
  if (!getPool()) return [];
  const l = Math.max(1, Math.min(500, Number(limit) || 100));
  const o = Math.max(0, Number(offset) || 0);

  // Older deployments may lack the full_name column — detect once and adapt.
  const hasFullName = await columnExists('users', 'full_name');
  const nameSelect = hasFullName ? 'full_name' : "'' AS full_name";

  if (typeof search === 'string' && search.trim()) {
    const s = search.trim();
    const like = `%${s}%`;
    const where = hasFullName
      ? 'national_id ILIKE $1 OR full_name ILIKE $1'
      : 'national_id ILIKE $1';
    const { rows } = await query(
      `SELECT id, national_id, ${nameSelect}, created_at, locked_until, failed_login_attempts
       FROM users
       WHERE ${where}
       ORDER BY created_at DESC
       LIMIT $2 OFFSET $3`,
      [like, l, o],
    );
    return rows;
  }

  const { rows } = await query(
    `SELECT id, national_id, ${nameSelect}, created_at, locked_until, failed_login_attempts
     FROM users
     ORDER BY created_at DESC
     LIMIT $1 OFFSET $2`,
    [l, o],
  );
  return rows;
}

export async function findCitizenById(id) {
  if (!getPool()) return null;
  const hasFullName = await columnExists('users', 'full_name');
  const nameSelect = hasFullName ? 'full_name' : "'' AS full_name";
  const { rows } = await query(
    `SELECT id, national_id, ${nameSelect}, created_at, locked_until, failed_login_attempts
     FROM users WHERE id = $1`,
    [id],
  );
  return rows[0] ?? null;
}

export async function setCitizenLocked(id, lockedUntil) {
  const { rows } = await query(
    `UPDATE users SET locked_until = $1
     WHERE id = $2
     RETURNING id, national_id, locked_until, failed_login_attempts`,
    [lockedUntil, id],
  );
  return rows[0] ?? null;
}

export async function unlockCitizen(id) {
  const { rows } = await query(
    `UPDATE users
     SET locked_until = NULL, failed_login_attempts = 0
     WHERE id = $1
     RETURNING id, national_id, locked_until, failed_login_attempts`,
    [id],
  );
  return rows[0] ?? null;
}

export async function resetCitizenPin(id, newPin) {
  const hash = await bcrypt.hash(newPin, 12);
  const { rows } = await query(
    `UPDATE users
     SET password_hash = $1, failed_login_attempts = 0, locked_until = NULL
     WHERE id = $2
     RETURNING id, national_id`,
    [hash, id],
  );
  return rows[0] ?? null;
}

async function columnExists(table, column) {
  try {
    const { rows } = await query(
      `SELECT 1 FROM information_schema.columns WHERE table_name = $1 AND column_name = $2 LIMIT 1`,
      [table, column],
    );
    return rows.length > 0;
  } catch {
    return false;
  }
}

/**
 * Ensures the citizen has a random HMAC key for v2 service QR codes; persists if missing.
 * @param {string} userId - users.id (UUID)
 * @returns {Promise<{ qrHmacKey: string }>}
 */
export async function ensureUserQrHmacKey(userId) {
  const { rows } = await query('SELECT id, qr_hmac_key FROM users WHERE id = $1', [userId]);
  if (!rows[0]) {
    throw new Error('user not found');
  }
  let k = rows[0].qr_hmac_key;
  if (!k || !String(k).trim()) {
    k = crypto.randomBytes(32).toString('hex');
    await query('UPDATE users SET qr_hmac_key = $1 WHERE id = $2', [k, userId]);
  }
  return { qrHmacKey: k };
}

/**
 * @param {string} nationalId
 * @returns {Promise<string | null>} HMAC key hex, or null if no user
 */
export async function getOrCreateQrHmacKeyByNationalId(nationalId) {
  const { rows } = await query('SELECT id, qr_hmac_key FROM users WHERE national_id = $1', [nationalId]);
  if (!rows[0]) return null;
  if (rows[0].qr_hmac_key && String(rows[0].qr_hmac_key).trim()) {
    return String(rows[0].qr_hmac_key);
  }
  const { qrHmacKey } = await ensureUserQrHmacKey(rows[0].id);
  return qrHmacKey;
}
