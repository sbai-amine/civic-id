import crypto from 'node:crypto';
import { query } from '../db/pool.js';

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
