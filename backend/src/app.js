import express from 'express';
import rateLimit from 'express-rate-limit';
import cors from 'cors';
import helmet from 'helmet';
import authRoutes from './routes/auth.routes.js';
import * as authController from './controllers/auth.controller.js';
import servicesRoutes from './routes/services.routes.js';
import syncRoutes from './routes/sync.routes.js';
import adminRoutes from './routes/admin.routes.js';
import cryptoRoutes from './routes/crypto.routes.js';
import { errorHandler } from './middleware/error.middleware.js';
import { asyncHandler } from './middleware/error.middleware.js';
import { auditRequest } from './middleware/audit.middleware.js';
import {
  RATE_LIMIT_MAX,
  RATE_LIMIT_WINDOW_MS,
  LOGIN_RATE_LIMIT_MAX,
  ADMIN_TOKEN_RATE_LIMIT_MAX,
  CORS_ALLOWED_ORIGINS,
} from './config.js';
import { withOptionalRedisStore } from './infra/redisRateLimit.js';

const app = express();

app.set('trust proxy', 1);
app.use(
  helmet({
    contentSecurityPolicy: false,
  }),
);

app.use(
  rateLimit(
    withOptionalRedisStore('global', {
      windowMs: RATE_LIMIT_WINDOW_MS,
      max: RATE_LIMIT_MAX,
      standardHeaders: true,
      legacyHeaders: false,
    }),
  ),
);

app.use(
  cors({
    origin(origin, callback) {
      if (CORS_ALLOWED_ORIGINS.length === 0) {
        callback(null, true);
        return;
      }
      if (!origin) {
        callback(null, true);
        return;
      }
      if (CORS_ALLOWED_ORIGINS.includes(origin)) {
        callback(null, true);
        return;
      }
      callback(null, false);
    },
    credentials: true,
  }),
);
app.use(express.json({ limit: '2mb' }));
app.use(auditRequest);

app.get('/health', (_req, res) => {
  res.status(200).json({ ok: true });
});

app.post(
  '/auth/refresh',
  rateLimit(
    withOptionalRedisStore('auth-refresh', {
      windowMs: 60_000,
      max: 30,
    }),
  ),
  asyncHandler(authController.refreshAccess),
);
app.post('/auth/revoke', asyncHandler(authController.revoke));

app.post(
  '/auth/admin/token',
  rateLimit(
    withOptionalRedisStore('auth-admin-token', {
      windowMs: 60_000,
      max: ADMIN_TOKEN_RATE_LIMIT_MAX,
    }),
  ),
  asyncHandler(authController.issueAdminToken),
);

app.use(
  '/login',
  rateLimit(
    withOptionalRedisStore('login', {
      windowMs: 60_000,
      max: LOGIN_RATE_LIMIT_MAX,
    }),
  ),
  authRoutes,
);
app.use('/services', servicesRoutes);
app.use('/sync', syncRoutes);
app.use('/admin', adminRoutes);
app.use('/crypto', cryptoRoutes);

app.use((_req, res) => {
  res.status(404).json({
    success: false,
    error: { code: 'NOT_FOUND', message: 'Route not found' },
  });
});

app.use(errorHandler);

export default app;
