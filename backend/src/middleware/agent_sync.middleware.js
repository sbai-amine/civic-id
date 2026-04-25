import { AGENT_SYNC_SECRET } from '../config.js';

/**
 * Validates `X-CivicKey-Agent-Sync` against [AGENT_SYNC_SECRET].
 * Used for Agent device uploads (no citizen JWT on that app).
 */
export function requireAgentSyncSecret(req, res, next) {
  const header = req.headers['x-civickey-agent-sync'];
  const provided = typeof header === 'string' ? header.trim() : '';

  if (!provided || provided !== AGENT_SYNC_SECRET) {
    return res.status(401).json({
      success: false,
      error: {
        code: 'INVALID_AGENT_SYNC_SECRET',
        message: 'Missing or invalid X-CivicKey-Agent-Sync header',
      },
    });
  }

  return next();
}
