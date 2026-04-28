import app from './app.js';
import { PORT, DATABASE_URL } from './config.js';
import { getPool } from './db/pool.js';

const pool = getPool();
if (!pool) {
  console.warn(
    '[bridgeid-api] No DATABASE_URL — /login, sync, and other DB routes return 503. Set DATABASE_URL and run: npm run migrate',
  );
} else {
  console.log('[bridgeid-api] Database pool ready.');
  // Self-healing schema patch: ensures full_name exists on legacy DBs created
  // before the column was added to init.sql.
  pool
    .query("ALTER TABLE users ADD COLUMN IF NOT EXISTS full_name TEXT NOT NULL DEFAULT ''")
    .catch((e) => console.warn('[bridgeid-api] full_name column patch failed:', e.message));
}

app.listen(PORT, '0.0.0.0', () => {
  console.log(`BridgeID API listening on http://localhost:${PORT}`);
});
