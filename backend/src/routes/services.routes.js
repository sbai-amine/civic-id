import { Router } from 'express';
import * as servicesController from '../controllers/services.controller.js';
import { authenticateToken } from '../middleware/auth.middleware.js';
import { asyncHandler } from '../middleware/error.middleware.js';

const router = Router();

router.get('/', authenticateToken, asyncHandler(servicesController.listServices));

export default router;
