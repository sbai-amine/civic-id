import crypto from 'node:crypto';
import { ALLOW_LEGACY_QR_PAYLOAD } from '../config.js';

/**
 * v2: HMAC-SHA256(key, "v2|userID|timestamp|nonce|serviceId") (hex key → raw bytes; digest compared as base64 in JSON)
 */
export function buildCanonicalV2({ userId, timestamp, nonce, serviceId }) {
  return `v2|${userId}|${timestamp}|${nonce}|${serviceId}`;
}

export function hmacSignatureBase64(hmacKeyHex, canonical) {
  const h = crypto.createHmac('sha256', Buffer.from(hmacKeyHex, 'hex'));
  h.update(canonical, 'utf8');
  return h.digest('base64');
}

/**
 * Verifies a citizen service-qr JSON payload. v2: must match HMAC. v1: optional if [ALLOW_LEGACY_QR_PAYLOAD] allows.
 * @param {{ payload: string, nationalId: string, hmacKeyHex: string, serviceId: string }} p
 * @returns {{ ok: true } | { ok: false, code: string, message: string }}
 */
export function verifyCitizenServiceQrPayload(p) {
  const { payload, nationalId, hmacKeyHex, serviceId } = p;
  let obj;
  try {
    obj = JSON.parse(payload);
  } catch {
    return { ok: false, code: 'INVALID_PAYLOAD', message: 'Payload is not valid JSON' };
  }
  if (obj == null || typeof obj !== 'object') {
    return { ok: false, code: 'INVALID_PAYLOAD', message: 'Invalid payload' };
  }

  const v = obj.v;
  const uid = obj.userID ?? obj.userId;
  if (v === 2) {
    if (typeof uid !== 'string' || !uid) {
      return { ok: false, code: 'VALIDATION_ERROR', message: 'Missing userID' };
    }
    if (uid !== nationalId) {
      return { ok: false, code: 'USER_MISMATCH', message: 'QR user does not match authenticated user' };
    }
    if (obj.serviceId != null && String(obj.serviceId) !== String(serviceId)) {
      return { ok: false, code: 'SERVICE_MISMATCH', message: 'serviceId in QR does not match item' };
    }
    const { timestamp, nonce, signature } = obj;
    if (typeof timestamp !== 'string' || typeof nonce !== 'string' || typeof signature !== 'string') {
      return { ok: false, code: 'VALIDATION_ERROR', message: 'v2 requires timestamp, nonce, signature' };
    }
    const can = buildCanonicalV2({ userId: uid, timestamp, nonce, serviceId: String(serviceId) });
    const expect = hmacSignatureBase64(hmacKeyHex, can);
    const a = Buffer.from(signature, 'base64');
    const b = Buffer.from(expect, 'base64');
    if (a.length !== b.length || !crypto.timingSafeEqual(a, b)) {
      return { ok: false, code: 'BAD_SIGNATURE', message: 'Invalid QR digital signature' };
    }
    return { ok: true };
  }

  if (v == null && obj.userID && obj.timestamp && !obj.nonce) {
    if (ALLOW_LEGACY_QR_PAYLOAD) {
      return { ok: true };
    }
    return {
      ok: false,
      code: 'QR_UPGRADE_REQUIRED',
      message: 'This QR format is no longer accepted; generate a new QR in the app.',
    };
  }

  if (v === 1) {
    if (ALLOW_LEGACY_QR_PAYLOAD) return { ok: true };
    return {
      ok: false,
      code: 'QR_UPGRADE_REQUIRED',
      message: 'This QR format is no longer accepted; generate a new QR in the app.',
    };
  }

  return { ok: false, code: 'VALIDATION_ERROR', message: 'Unsupported or invalid QR version' };
}
