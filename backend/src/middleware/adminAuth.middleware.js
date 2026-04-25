import { ADMIN_API_KEY, ADMIN_NATIONAL_IDS } from '../config.js';
import { verifyAdminAccessToken } from '../services/adminTokenService.js';
import { authenticateToken } from './auth.middleware.js';

function extractAdminCredentials(req) {
  const keyHeader = req.headers['x-admin-key'];
  const key = typeof keyHeader === 'string' ? keyHeader.trim() : '';
  const auth = req.headers.authorization;
  const bearer =
    typeof auth === 'string' && auth.toLowerCase().startsWith('bearer ')
      ? auth.slice(7).trim()
      : '';
  return { key, bearer };
}

/**
 * - `Authorization: Bearer <ADMIN_API_KEY>` or `X-Admin-Key: <ADMIN_API_KEY>`
 * - `Authorization: Bearer <admin_jwt>` from `POST /auth/admin/token` (separate secret / issuer from citizen tokens)
 * - **or** valid user JWT where `nationalID` is listed in `ADMIN_NATIONAL_IDS`.
 */
export function requireAdminAccess(req, res, next) {
  const { key, bearer } = extractAdminCredentials(req);

  if (ADMIN_API_KEY && (bearer === ADMIN_API_KEY || key === ADMIN_API_KEY)) {
    req.adminAuth = { type: 'admin_api_key', ref: 'global' };
    return next();
  }

  if (bearer) {
    try {
      const payload = verifyAdminAccessToken(bearer);
      if (payload && payload.typ === 'admin') {
        req.adminAuth = { type: 'admin_jwt', ref: String(payload.sub ?? 'admin') };
        return next();
      }
    } catch {
      // fall through to user JWT
    }
  }

  return authenticateToken(req, res, () => {
    const nid = req.user?.nationalID || req.user?.sub;
    if (typeof nid === 'string' && ADMIN_NATIONAL_IDS.length && ADMIN_NATIONAL_IDS.includes(nid)) {
      req.adminAuth = { type: 'admin_user', ref: nid };
      return next();
    }
    return res.status(403).json({
      success: false,
      error: { code: 'FORBIDDEN', message: 'Admin authentication required' },
    });
  });
}
