import crypto from 'node:crypto';

/**
 * Must match `lib/utils/content_hash.dart` (citizen).
 */
export function hashCitizenQr({ nationalId, serviceId, payload, createdAt }) {
  const s = `${nationalId}|${serviceId}|${payload}|${createdAt}`;
  return crypto.createHash('sha256').update(s, 'utf8').digest('hex');
}

/**
 * Must match `lib/utils/content_hash.dart` (agent).
 */
export function hashAgentScan({ userId, rawPayload, scannedAt }) {
  const s = `agent|${userId ?? ''}|${rawPayload}|${scannedAt}`;
  return crypto.createHash('sha256').update(s, 'utf8').digest('hex');
}
