import pg from 'pg';
import { DATABASE_URL } from '../config.js';

const { Pool } = pg;

let _pool;

export function getPool() {
  if (!DATABASE_URL) {
    return null;
  }
  if (!_pool) {
    _pool = new Pool({
      connectionString: DATABASE_URL,
      max: 20,
      idleTimeoutMillis: 30_000,
    });
  }
  return _pool;
}

export async function query(text, params) {
  const pool = getPool();
  if (!pool) throw new Error('DATABASE_URL is not configured');
  return pool.query(text, params);
}
