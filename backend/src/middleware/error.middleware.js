import jwt from 'jsonwebtoken';

/**
 * Wraps an async route handler so rejected promises reach Express error middleware.
 * @param {(req: import('express').Request, res: import('express').Response, next: import('express').NextFunction) => Promise<void>} fn
 */
export function asyncHandler(fn) {
  return (req, res, next) => {
    Promise.resolve(fn(req, res, next)).catch(next);
  };
}

/**
 * Central place to map errors to HTTP responses (no stack traces to clients).
 */
export function errorHandler(err, req, res, next) {
  if (res.headersSent) {
    return next(err);
  }

  if (err instanceof jwt.JsonWebTokenError) {
    return res.status(401).json({
      success: false,
      error: { code: 'INVALID_TOKEN', message: 'Invalid or malformed token' },
    });
  }

  if (err instanceof jwt.TokenExpiredError) {
    return res.status(401).json({
      success: false,
      error: { code: 'TOKEN_EXPIRED', message: 'Token has expired' },
    });
  }

  const status = err.status && Number.isInteger(err.status) ? err.status : 500;
  const message =
    status === 500 ? 'Internal server error' : err.message || 'Request failed';

  return res.status(status).json({
    success: false,
    error: { code: err.code || 'SERVER_ERROR', message },
  });
}
