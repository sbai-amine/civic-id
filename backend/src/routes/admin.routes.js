import { Router } from 'express';
import * as admin from '../modules/admin/admin.controller.js';
import { requireAdminAccess } from '../middleware/adminAuth.middleware.js';
import { asyncHandler } from '../middleware/error.middleware.js';

const router = Router();

router.get('/sync-records', requireAdminAccess, asyncHandler(admin.listSyncRecords));
router.get('/kpis', requireAdminAccess, asyncHandler(admin.getKpis));

router.get('/agent-keys', requireAdminAccess, asyncHandler(admin.getAgentKeys));
router.post('/agent-keys', requireAdminAccess, asyncHandler(admin.createAgentKey));
router.post('/agent-keys/:id/disable', requireAdminAccess, asyncHandler(admin.disableAgentKey));
router.post('/agent-keys/:id/enable', requireAdminAccess, asyncHandler(admin.enableAgentKey));
router.delete('/agent-keys/:id', requireAdminAccess, asyncHandler(admin.deleteAgentKey));

router.get('/audit-logs', requireAdminAccess, asyncHandler(admin.getAuditLogs));

router.get('/citizens', requireAdminAccess, asyncHandler(admin.getCitizens));
router.post('/citizens/:id/lock', requireAdminAccess, asyncHandler(admin.lockCitizen));
router.post('/citizens/:id/unlock', requireAdminAccess, asyncHandler(admin.unlockCitizen));
router.post('/citizens/:id/reset-pin', requireAdminAccess, asyncHandler(admin.resetCitizenPin));

export default router;
