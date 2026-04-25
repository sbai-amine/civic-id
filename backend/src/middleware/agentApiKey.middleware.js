import crypto from 'node:crypto';
import { query } from '../db/pool.js';
import { getPool } from '../db/pool.js';
import { AGENT_SYNC_SECRET } from '../config.js';

/**
 * Resolves either:
 * - `X-API-Key: <key>` or `Authorization: Bearer <key>` (full API key) against `agent_api_keys`
 * - Legacy `X-CivicKey-Agent-Sync: <AGENT_SYNC_SECRET>` or matching Bearer
 */
export async function requireAgentApiKey(req, res, next) {
  const fromHeader = (name) => {
    const h = req.headers[name];
    return typeof h === 'string' ? h.trim() : '';
  };

  const xApi = fromHeader('x-api-key');
  const auth = fromHeader('authorization');
  const bearer = auth.toLowerCase().startsWith('bearer ') ? auth.slice(7).trim() : '';
  const legacy = fromHeader('x-civickey-agent-sync');

  if (getPool() && (xApi || bearer)) {
    const key = xApi || bearer;
    if (key) {
      const keyHash = crypto.createHash('sha256').update(key, 'utf8').digest('hex');
      const { rows } = await query(
        'SELECT id FROM agent_api_keys WHERE key_hash = $1 AND disabled = false',
        [keyHash],
      );
      if (rows.length) {
        req.agentKeyId = rows[0].id;
        return next();
      }
    }
  }

  if (AGENT_SYNC_SECRET) {
    if (legacy && legacy === AGENT_SYNC_SECRET) {
      req.agentKeyId = null;
      return next();
    }
    if (bearer && bearer === AGENT_SYNC_SECRET) {
      req.agentKeyId = null;
      return next();
    }
  }

  return res.status(401).json({
    success: false,
    error: {
      code: 'INVALID_AGENT_KEY',
      message: 'Valid X-API-Key, Bearer token, or legacy X-CivicKey-Agent-Sync required',
    },
  });
}
