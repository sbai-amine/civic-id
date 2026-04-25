import { createAuditLog } from '../repositories/auditRepository.js';

export async function auditRequest(req, _res, next) {
  req.audit = async ({ action, resourceType, resourceId, metadata }) => {
    const actorType = req.adminAuth?.type || (req.agentKeyId ? 'agent' : req.user ? 'citizen' : 'system');
    const actorRef = req.adminAuth?.ref || req.user?.nationalID || req.user?.sub || req.agentKeyId || null;
    await createAuditLog({ actorType, actorRef, action, resourceType, resourceId, metadata });
  };
  next();
}
