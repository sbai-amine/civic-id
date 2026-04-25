import { query } from '../db/pool.js';

export async function createAuditLog({ actorType, actorRef, action, resourceType, resourceId, metadata }) {
  try {
    await query(
      `INSERT INTO audit_logs (actor_type, actor_ref, action, resource_type, resource_id, metadata)
       VALUES ($1, $2, $3, $4, $5, $6)`,
      [actorType, actorRef ?? null, action, resourceType ?? null, resourceId ?? null, metadata ?? {}],
    );
  } catch (e) {
    // Allows tests/dev DBs that predate audit table migration.
    if (e?.code === '42P01') return;
    throw e;
  }
}
