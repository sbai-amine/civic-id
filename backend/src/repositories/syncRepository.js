import { query } from '../db/pool.js';

/**
 * @param {object} p
 * @param {string} p.nationalId
 * @param {string} p.contentHash
 * @param {number} p.localId
 * @param {string} p.serviceId
 * @param {string} p.serviceName
 * @param {string} p.payload
 * @param {Date} p.createdAtClient
 * @returns {Promise<'inserted' | 'duplicate'>}
 */
export async function insertCitizenServiceQr(p) {
  const { nationalId, contentHash, localId, serviceId, serviceName, payload, createdAtClient } = p;
  try {
    await query(
      `INSERT INTO sync_records (
         user_national_id, content_hash, local_id, service_id, service_name, payload, source, created_at_client
       ) VALUES ($1, $2, $3, $4, $5, $6, 'citizen', $7)`,
      [nationalId, contentHash, localId, serviceId, serviceName, payload, createdAtClient],
    );
    return 'inserted';
  } catch (e) {
    if (e.code === '23505') return 'duplicate';
    throw e;
  }
}

/**
 * @param {object} p
 * @param {string | null} p.userId
 * @param {string} p.contentHash
 * @param {number} p.localId
 * @param {string} p.rawPayload
 * @param {string | null} p.agentKeyId
 * @param {Date} p.scannedAt
 * @returns {Promise<'inserted' | 'duplicate'>}
 */
export async function insertAgentScan(p) {
  const { userId, contentHash, localId, rawPayload, agentKeyId, scannedAt } = p;
  try {
    await query(
      `INSERT INTO sync_records (
         user_national_id, content_hash, local_id, service_id, service_name, payload, source, raw_payload, agent_key_id, created_at_client
       ) VALUES ($1, $2, $3, null, null, null, 'agent', $4, $5, $6)`,
      [userId ?? null, contentHash, localId, rawPayload, agentKeyId, scannedAt],
    );
    return 'inserted';
  } catch (e) {
    if (e.code === '23505') return 'duplicate';
    throw e;
  }
}
