import { Router } from 'express';
import * as authController from '../controllers/auth.controller.js';
import { asyncHandler } from '../middleware/error.middleware.js';

const router = Router();

// Mounted at /login → POST /login
router.post('/', asyncHandler(authController.login));

export default router;
