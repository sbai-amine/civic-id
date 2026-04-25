import jwt from 'jsonwebtoken';
import { JWT_SECRET } from '../config.js';

/**
 * Requires `Authorization: Bearer <access JWT>`.
 * Attaches decoded payload to `req.user`.
 */
export function authenticateToken(req, res, next) {
  const header = req.headers.authorization;
  const token =
    typeof header === 'string' && header.startsWith('Bearer ')
      ? header.slice(7).trim()
      : null;

  if (!token) {
    return res.status(401).json({
      success: false,
      error: {
        code: 'UNAUTHORIZED',
        message: 'Missing or invalid Authorization header (Bearer token required)',
      },
    });
  }

  try {
    const payload = jwt.verify(token, JWT_SECRET);
    if (payload.typ && payload.typ !== 'access') {
      return res.status(401).json({
        success: false,
        error: { code: 'UNAUTHORIZED', message: 'Access token required' },
      });
    }
    req.user = payload;
    return next();
  } catch (err) {
    return next(err);
  }
}
