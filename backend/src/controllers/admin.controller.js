import { query } from '../db/pool.js';
import { getPool } from '../db/pool.js';
import { acceptedScans, acceptedServiceQrs } from '../models/sync_store.model.js';

/**
 * GET /admin/sync-records
 */
export async function listSyncRecords(req, res) {
  if (getPool()) {
    const { rows } = await query(
      `SELECT id, user_national_id, content_hash, local_id, service_id, service_name,
              payload, source, raw_payload, created_at_client, created_at_server
       FROM sync_records
       ORDER BY created_at_server DESC
       LIMIT 2000`,
    );
    return res.status(200).json({ success: true, data: { records: rows } });
  }
  return res.status(200).json({
    success: true,
    data: {
      records: {
        serviceQrs: acceptedServiceQrs,
        scans: acceptedScans,
      },
    },
  });
}
