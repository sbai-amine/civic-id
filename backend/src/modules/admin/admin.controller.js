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

export async function createAgentKey(req, res) {
  const row = await adminService.issueAgentKey(req);
  return res.status(201).json({ success: true, data: { key: row } });
}

export async function deleteAgentKey(req, res) {
  const row = await adminService.removeAgentKey(req);
  return res.status(200).json({ success: true, data: { key: row } });
}

export async function getAuditLogs(req, res) {
  const logs = await adminService.fetchAuditLogs(req);
  return res.status(200).json({ success: true, data: { logs } });
}

export async function getCitizens(req, res) {
  const citizens = await adminService.fetchCitizens(req);
  return res.status(200).json({ success: true, data: { citizens } });
}

export async function lockCitizen(req, res) {
  const row = await adminService.lockCitizen(req);
  return res.status(200).json({ success: true, data: { citizen: row } });
}

export async function unlockCitizen(req, res) {
  const row = await adminService.unlockCitizenAccount(req);
  return res.status(200).json({ success: true, data: { citizen: row } });
}

export async function resetCitizenPin(req, res) {
  const row = await adminService.resetCitizenPinAction(req);
  return res.status(200).json({ success: true, data: { citizen: row } });
}
