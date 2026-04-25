import { Router } from 'express';
import * as admin from '../modules/admin/admin.controller.js';
import { requireAdminAccess } from '../middleware/adminAuth.middleware.js';
import { asyncHandler } from '../middleware/error.middleware.js';

const router = Router();

router.get('/sync-records', requireAdminAccess, asyncHandler(admin.listSyncRecords));
router.get('/kpis', requireAdminAccess, asyncHandler(admin.getKpis));
router.get('/agent-keys', requireAdminAccess, asyncHandler(admin.getAgentKeys));
router.post('/agent-keys/:id/disable', requireAdminAccess, asyncHandler(admin.disableAgentKey));
router.post('/agent-keys/:id/enable', requireAdminAccess, asyncHandler(admin.enableAgentKey));
router.get('/audit-logs', requireAdminAccess, asyncHandler(admin.getAuditLogs));

export default router;
