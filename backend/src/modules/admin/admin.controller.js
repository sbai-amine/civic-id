import * as adminService from './admin.service.js';
import { acceptedScans, acceptedServiceQrs } from '../../models/sync_store.model.js';
import { getPool } from '../../db/pool.js';

export async function listSyncRecords(req, res) {
  if (!getPool()) {
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
  const records = await adminService.fetchSyncRecords(req);
  return res.status(200).json({ success: true, data: { records } });
}

export async function getKpis(req, res) {
  const kpis = await adminService.fetchKpis(req);
  return res.status(200).json({ success: true, data: { kpis } });
}

export async function getAgentKeys(req, res) {
  const keys = await adminService.fetchAgentKeys(req);
  return res.status(200).json({ success: true, data: { keys } });
}

export async function disableAgentKey(req, res) {
  const row = await adminService.disableAgentKey(req, true);
  return res.status(200).json({ success: true, data: { key: row } });
}

export async function enableAgentKey(req, res) {
  const row = await adminService.disableAgentKey(req, false);
  return res.status(200).json({ success: true, data: { key: row } });
}

export async function getAuditLogs(req, res) {
  const logs = await adminService.fetchAuditLogs(req);
  return res.status(200).json({ success: true, data: { logs } });
}
