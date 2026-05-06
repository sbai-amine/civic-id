import pg from 'pg';
import { DATABASE_URL } from '../config.js';

const { Pool } = pg;

let _pool;

export function getPool() {
  if (!DATABASE_URL) {
    return null;
  }
  if (!_pool) {
    const needsSsl =
      /[?&]sslmode=require/i.test(DATABASE_URL) ||
      /\.rlwy\.net|\.railway\.app|\.neon\.tech|\.supabase\.co|\.render\.com/i.test(DATABASE_URL) ||
      process.env.PGSSL === 'require';
    _pool = new Pool({
      connectionString: DATABASE_URL,
      max: 20,
      idleTimeoutMillis: 30_000,
      ssl: needsSsl ? { rejectUnauthorized: false } : false,
    });
  }
  return _pool;
}

export async function query(text, params) {
  const pool = getPool();
  if (!pool) throw new Error('DATABASE_URL is not configured');
  return pool.query(text, params);
}
