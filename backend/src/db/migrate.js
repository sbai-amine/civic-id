import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import bcrypt from 'bcrypt';
import { getPool } from './pool.js';
import { BCRYPT_ROUNDS } from '../config.js';
import { DATABASE_URL } from '../config.js';
import dotenv from 'dotenv';

dotenv.config();

const __dirname = path.dirname(fileURLToPath(import.meta.url));

async function run() {
  if (!DATABASE_URL) {
    console.error('DATABASE_URL is required. Example: postgresql://civickey:civickey@localhost:5432/civickey');
    process.exit(1);
  }
  const pool = getPool();
  const sqlPath = path.join(__dirname, '../../sql/init.sql');
  const sql = fs.readFileSync(sqlPath, 'utf8');
  await pool.query(sql);

  await pool.query(
    'ALTER TABLE users ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ NOT NULL DEFAULT now()',
  );
  await pool.query(
    'CREATE INDEX IF NOT EXISTS idx_sync_created_at_server ON sync_records (created_at_server DESC)',
  );
  await pool.query(
    'CREATE INDEX IF NOT EXISTS idx_sync_source_created ON sync_records (source, created_at_server DESC)',
  );
  await pool.query(
    'CREATE INDEX IF NOT EXISTS idx_sync_user_created ON sync_records (user_national_id, created_at_server DESC)',
  );
  await pool.query(
    'CREATE INDEX IF NOT EXISTS idx_signed_docs_hash ON signed_documents (payload_hash)',
  );
  await pool.query('ALTER TABLE users ADD COLUMN IF NOT EXISTS qr_hmac_key TEXT');
  await pool.query(
    "ALTER TABLE users ADD COLUMN IF NOT EXISTS full_name TEXT NOT NULL DEFAULT ''",
  );
  await pool.query(
    `CREATE TABLE IF NOT EXISTS audit_logs (
      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      actor_type TEXT NOT NULL,
      actor_ref TEXT,
      action TEXT NOT NULL,
      resource_type TEXT,
      resource_id TEXT,
      metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
      created_at TIMESTAMPTZ NOT NULL DEFAULT now()
    )`,
  );
  await pool.query(
    `CREATE TABLE IF NOT EXISTS signed_documents (
      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      user_national_id TEXT NOT NULL,
      doc_type TEXT NOT NULL,
      doc_payload JSONB NOT NULL,
      payload_hash TEXT NOT NULL,
      signature TEXT NOT NULL,
      signature_alg TEXT NOT NULL DEFAULT 'ed25519',
      signed_at TIMESTAMPTZ NOT NULL DEFAULT now()
    )`,
  );
  const crypto = await import('node:crypto');
  const { rows: missingKey } = await pool.query(
    'SELECT id FROM users WHERE qr_hmac_key IS NULL OR btrim(qr_hmac_key) = $1',
    [''],
  );
  for (const u of missingKey) {
    const k = crypto.randomBytes(32).toString('hex');
    await pool.query('UPDATE users SET qr_hmac_key = $1 WHERE id = $2', [k, u.id]);
  }

  const { rows: users } = await pool.query('SELECT id FROM users WHERE national_id = $1', [
    '123456',
  ]);
  if (users.length === 0) {
    const hash = await bcrypt.hash('1234', BCRYPT_ROUNDS);
    await pool.query(
      `INSERT INTO users (national_id, password_hash) VALUES ($1, $2)`,
      ['123456', hash],
    );
    console.log('Seeded demo user national_id=123456');
  }

  // Seed a default API key for agent (stored as SHA-256 of full key)
  const { rows: keys } = await pool.query('SELECT id FROM agent_api_keys LIMIT 1');
  if (keys.length === 0) {
    const crypto = await import('node:crypto');
    const fullKey = process.env.SEED_AGENT_API_KEY || `ck_live_${crypto.randomBytes(24).toString('hex')}`;
    const keyId = fullKey.slice(0, 12);
    const keyHash = crypto.createHash('sha256').update(fullKey, 'utf8').digest('hex');
    await pool.query(
      `INSERT INTO agent_api_keys (key_id, key_hash, label) VALUES ($1, $2, 'seed')`,
      [keyId, keyHash],
    );
    console.log('');
    console.log('======== AGENT API KEY (store securely; not shown again) ========');
    console.log(fullKey);
    console.log('Set in agent app: --dart-define=AGENT_API_KEY=...');
    console.log('==================================================================');
  }

  await pool.end();
  console.log('Migration complete.');
}

run().catch((e) => {
  console.error(e);
  process.exit(1);
});
