import crypto from 'node:crypto';
import {
  createAgentKey,
  deleteAgentKey,
  getAdminKpis,
  getSyncRecords,
  listAgentKeys,
  listAuditLogs,
  setAgentKeyDisabled,
} from '../../repositories/adminRepository.js';
import {
  findCitizenById,
  listCitizens,
  resetCitizenPin,
  setCitizenLocked,
  unlockCitizen,
} from '../../repositories/userRepository.js';
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

function notFound(message) {
  const err = new Error(message);
  err.status = 404;
  err.code = 'NOT_FOUND';
  return err;
}

function validation(message) {
  const err = new Error(message);
  err.status = 400;
  err.code = 'VALIDATION_ERROR';
  return err;
}

export async function fetchSyncRecords(req) {
  return getSyncRecords({ limit: req.query.limit, offset: req.query.offset });
}

export async function fetchKpis() {
  return getAdminKpis();
}

export async function fetchAgentKeys() {
  return listAgentKeys();
}

export async function disableAgentKey(req, disabled) {
  const id = String(req.params.id || '');
  if (!id) throw validation('id is required');
  const row = await setAgentKeyDisabled({ id, disabled });
  if (!row) throw notFound('Agent key not found');
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

/**
 * Generates a fresh agent key. Returns the raw secret ONCE — only the SHA-256
 * hash is stored, so it cannot be recovered later.
 */
export async function issueAgentKey(req) {
  const label = String(req.body?.label || '').trim() || 'verifier device';
  const keyId = `ak_${crypto.randomBytes(4).toString('hex')}`;
  const secret = crypto.randomBytes(32).toString('hex');
  const keyHash = crypto.createHash('sha256').update(secret, 'utf8').digest('hex');

  const row = await createAgentKey({ keyId, keyHash, label });
  if (!row) throw validation('Could not create agent key (DB unavailable?)');

  const actor = actorFromReq(req);
  await createAuditLog({
    actorType: actor.actorType,
    actorRef: actor.actorRef,
    action: 'agent_key.created',
    resourceType: 'agent_api_key',
    resourceId: row.id,
    metadata: { keyId: row.key_id, label: row.label },
  });

  return { ...row, key: secret };
}

export async function removeAgentKey(req) {
  const id = String(req.params.id || '');
  if (!id) throw validation('id is required');
  const row = await deleteAgentKey(id);
  if (!row) throw notFound('Agent key not found');
  const actor = actorFromReq(req);
  await createAuditLog({
    actorType: actor.actorType,
    actorRef: actor.actorRef,
    action: 'agent_key.deleted',
    resourceType: 'agent_api_key',
    resourceId: row.id,
    metadata: { keyId: row.key_id, label: row.label },
  });
  return row;
}

export async function fetchAuditLogs(req) {
  return listAuditLogs({
    limit: req.query.limit,
    offset: req.query.offset,
    action: req.query.action,
  });
}

export async function fetchCitizens(req) {
  return listCitizens({
    search: req.query.search,
    limit: req.query.limit,
    offset: req.query.offset,
  });
}

export async function lockCitizen(req) {
  const id = String(req.params.id || '');
  if (!id) throw validation('id is required');
  const citizen = await findCitizenById(id);
  if (!citizen) throw notFound('Citizen not found');
  // Lock for 100 years — effectively permanent until admin unlocks.
  const lockedUntil = new Date(Date.now() + 100 * 365 * 24 * 60 * 60 * 1000);
  const row = await setCitizenLocked(id, lockedUntil);
  const actor = actorFromReq(req);
  await createAuditLog({
    actorType: actor.actorType,
    actorRef: actor.actorRef,
    action: 'citizen.locked',
    resourceType: 'user',
    resourceId: row.id,
    metadata: { nationalId: row.national_id },
  });
  return row;
}

export async function unlockCitizenAccount(req) {
  const id = String(req.params.id || '');
  if (!id) throw validation('id is required');
  const citizen = await findCitizenById(id);
  if (!citizen) throw notFound('Citizen not found');
  const row = await unlockCitizen(id);
  const actor = actorFromReq(req);
  await createAuditLog({
    actorType: actor.actorType,
    actorRef: actor.actorRef,
    action: 'citizen.unlocked',
    resourceType: 'user',
    resourceId: row.id,
    metadata: { nationalId: row.national_id },
  });
  return row;
}

export async function resetCitizenPinAction(req) {
  const id = String(req.params.id || '');
  if (!id) throw validation('id is required');
  const citizen = await findCitizenById(id);
  if (!citizen) throw notFound('Citizen not found');
  // Generate temp 6-digit PIN. Returned ONCE to the admin to share with citizen.
  const tempPin = String(crypto.randomInt(100000, 1000000));
  const row = await resetCitizenPin(id, tempPin);
  const actor = actorFromReq(req);
  await createAuditLog({
    actorType: actor.actorType,
    actorRef: actor.actorRef,
    action: 'citizen.pin_reset',
    resourceType: 'user',
    resourceId: row.id,
    metadata: { nationalId: row.national_id },
  });
  return { ...row, tempPin };
}
