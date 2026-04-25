import { Router } from 'express';
import { authenticateToken } from '../middleware/auth.middleware.js';
import { requireAdminAccess } from '../middleware/adminAuth.middleware.js';
import { asyncHandler } from '../middleware/error.middleware.js';
import * as cryptoController from '../modules/crypto/crypto.controller.js';

const router = Router();

router.post('/sign-document', authenticateToken, asyncHandler(cryptoController.signDocument));
router.get('/signed-documents/:id/verify', requireAdminAccess, asyncHandler(cryptoController.verifyDocument));

export default router;
