import {
  getAdminKpis,
  getSyncRecords,
  listAgentKeys,
  listAuditLogs,
  setAgentKeyDisabled,
} from '../../repositories/adminRepository.js';
import { createAuditLog } from '../../repositories/auditRepository.js';

function actorFromReq(req) {
  if (req.adminAuth?.type) {
    return {
      actorType: req.adminAuth.type,
      actorRef: req.adminAuth.ref ?? null,
    };
  }
  return {
    actorType: 'admin',
    actorRef: req.user?.nationalID ?? req.user?.sub ?? null,
  };
}

export async function fetchSyncRecords(req) {
  const limit = req.query.limit;
  const offset = req.query.offset;
  return getSyncRecords({ limit, offset });
}

export async function fetchKpis() {
  return getAdminKpis();
}

export async function fetchAgentKeys() {
  return listAgentKeys();
}

export async function disableAgentKey(req, disabled) {
  const id = String(req.params.id || '');
  if (!id) {
    const err = new Error('id is required');
    err.status = 400;
    err.code = 'VALIDATION_ERROR';
    throw err;
  }
  const row = await setAgentKeyDisabled({ id, disabled });
  if (!row) {
    const err = new Error('Agent key not found');
    err.status = 404;
    err.code = 'NOT_FOUND';
    throw err;
  }
  const actor = actorFromReq(req);
  await createAuditLog({
    actorType: actor.actorType,
    actorRef: actor.actorRef,
    action: disabled ? 'agent_key.disabled' : 'agent_key.enabled',
    resourceType: 'agent_api_key',
    resourceId: row.id,
    metadata: { keyId: row.key_id },
  });
  return row;
}

export async function fetchAuditLogs(req) {
  const logs = await listAuditLogs({
    limit: req.query.limit,
    offset: req.query.offset,
    action: req.query.action,
  });
  return logs;
}
