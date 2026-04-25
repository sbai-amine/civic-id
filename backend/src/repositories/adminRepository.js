import { query } from '../db/pool.js';
import { getPool } from '../db/pool.js';

export async function getSyncRecords({ limit = 200, offset = 0 } = {}) {
  const l = Math.max(1, Math.min(2000, Number(limit) || 200));
  const o = Math.max(0, Number(offset) || 0);
  const { rows } = await query(
    `SELECT id, user_national_id, content_hash, local_id, service_id, service_name,
            payload, source, raw_payload, created_at_client, created_at_server
     FROM sync_records
     ORDER BY created_at_server DESC
     LIMIT $1 OFFSET $2`,
    [l, o],
  );
  return rows;
}

export async function getAdminKpis() {
  if (!getPool()) {
    return {
      users: 0,
      serviceRecords: 0,
      agentScans: 0,
      pendingLike: 0,
      activeAgentKeys: 0,
    };
  }
  const [{ rows: users }, { rows: citizen }, { rows: agent }, { rows: keys }] = await Promise.all([
    query('SELECT COUNT(*)::int AS c FROM users'),
    query("SELECT COUNT(*)::int AS c FROM sync_records WHERE source = 'citizen'"),
    query("SELECT COUNT(*)::int AS c FROM sync_records WHERE source = 'agent'"),
    query('SELECT COUNT(*)::int AS c FROM agent_api_keys WHERE disabled = false'),
  ]);
  return {
    users: users[0].c,
    serviceRecords: citizen[0].c,
    agentScans: agent[0].c,
    pendingLike: 0,
    activeAgentKeys: keys[0].c,
  };
}

export async function listAgentKeys() {
  if (!getPool()) return [];
  try {
    const { rows } = await query(
      `SELECT id, key_id, label, disabled, created_at
       FROM agent_api_keys
       ORDER BY created_at DESC
       LIMIT 500`,
    );
    return rows;
  } catch (e) {
    if (e?.code === '42P01') return [];
    throw e;
  }
}

export async function setAgentKeyDisabled({ id, disabled }) {
  if (!getPool()) return null;
  try {
    const { rows } = await query(
      'UPDATE agent_api_keys SET disabled = $1 WHERE id = $2 RETURNING id, key_id, label, disabled, created_at',
      [disabled, id],
    );
    return rows[0] ?? null;
  } catch (e) {
    if (e?.code === '42P01') return null;
    throw e;
  }
}

export async function listAuditLogs({ limit = 100, offset = 0, action } = {}) {
  if (!getPool()) return [];
  const l = Math.max(1, Math.min(500, Number(limit) || 100));
  const o = Math.max(0, Number(offset) || 0);
  try {
    if (typeof action === 'string' && action.trim()) {
      const { rows } = await query(
        `SELECT id, actor_type, actor_ref, action, resource_type, resource_id, metadata, created_at
         FROM audit_logs
         WHERE action = $1
         ORDER BY created_at DESC
         LIMIT $2 OFFSET $3`,
        [action.trim(), l, o],
      );
      return rows;
    }
    const { rows } = await query(
      `SELECT id, actor_type, actor_ref, action, resource_type, resource_id, metadata, created_at
       FROM audit_logs
       ORDER BY created_at DESC
       LIMIT $1 OFFSET $2`,
      [l, o],
    );
    return rows;
  } catch (e) {
    if (e?.code === '42P01') return [];
    throw e;
  }
}
