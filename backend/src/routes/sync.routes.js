import { Router } from 'express';
import * as syncController from '../controllers/sync.controller.js';
import { authenticateToken } from '../middleware/auth.middleware.js';
import { requireAgentApiKey } from '../middleware/agentApiKey.middleware.js';
import { asyncHandler } from '../middleware/error.middleware.js';

const router = Router();

router.post(
  '/service-qr',
  authenticateToken,
  asyncHandler(syncController.syncServiceQrBatch),
);

router.post(
  '/scans',
  asyncHandler(requireAgentApiKey),
  asyncHandler(syncController.syncScanBatch),
);

export default router;
