-- CivicKey production schema
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  national_id TEXT NOT NULL UNIQUE,
  password_hash TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  failed_login_attempts INT NOT NULL DEFAULT 0,
  locked_until TIMESTAMPTZ,
  -- Per-citizen secret for HMAC of service QRs; returned at login, stored in secure device storage.
  qr_hmac_key TEXT
);

CREATE TABLE IF NOT EXISTS refresh_tokens (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  jti TEXT NOT NULL UNIQUE,
  expires_at TIMESTAMPTZ NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_refresh_user ON refresh_tokens (user_id);

CREATE TABLE IF NOT EXISTS services (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT NOT NULL DEFAULT '',
  required_documents JSONB NOT NULL DEFAULT '[]',
  fee_display TEXT NOT NULL DEFAULT ''
);

CREATE TABLE IF NOT EXISTS sync_records (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_national_id TEXT,
  content_hash TEXT NOT NULL,
  local_id INT,
  service_id TEXT,
  service_name TEXT,
  payload TEXT,
  source TEXT NOT NULL CHECK (source IN ('citizen', 'agent')),
  raw_payload TEXT,
  agent_key_id UUID,
  created_at_client TIMESTAMPTZ,
  created_at_server TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE UNIQUE INDEX IF NOT EXISTS idx_sync_content_hash ON sync_records (content_hash);
CREATE INDEX IF NOT EXISTS idx_sync_created_at_server ON sync_records (created_at_server DESC);
CREATE INDEX IF NOT EXISTS idx_sync_source_created ON sync_records (source, created_at_server DESC);
CREATE INDEX IF NOT EXISTS idx_sync_user_created ON sync_records (user_national_id, created_at_server DESC);

CREATE TABLE IF NOT EXISTS agent_api_keys (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  key_id TEXT NOT NULL,
  key_hash TEXT NOT NULL,
  label TEXT NOT NULL DEFAULT 'device',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  disabled BOOLEAN NOT NULL DEFAULT false
);
CREATE INDEX IF NOT EXISTS idx_agent_key_id ON agent_api_keys (key_id);

CREATE TABLE IF NOT EXISTS audit_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  actor_type TEXT NOT NULL,
  actor_ref TEXT,
  action TEXT NOT NULL,
  resource_type TEXT,
  resource_id TEXT,
  metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_audit_created ON audit_logs (created_at DESC);
CREATE INDEX IF NOT EXISTS idx_audit_action ON audit_logs (action);

CREATE TABLE IF NOT EXISTS signed_documents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_national_id TEXT NOT NULL,
  doc_type TEXT NOT NULL,
  doc_payload JSONB NOT NULL,
  payload_hash TEXT NOT NULL,
  signature TEXT NOT NULL,
  signature_alg TEXT NOT NULL DEFAULT 'ed25519',
  signed_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_signed_docs_user ON signed_documents (user_national_id, signed_at DESC);
CREATE INDEX IF NOT EXISTS idx_signed_docs_hash ON signed_documents (payload_hash);

INSERT INTO services (id, name, description, required_documents, fee_display) VALUES
  (
    'birth_certificate',
    'Birth certificate',
    'Official request for a certified copy of a birth record.',
    '["National ID (original or copy)", "Parent consent if minor"]'::jsonb,
    '2.00 USD — same-day processing where available'
  ),
  (
    'residence_certificate',
    'Residence certificate',
    'Proof of residence for address verification.',
    '["National ID", "Utility bill (last 3 months) or lease"]'::jsonb,
    '1.50 USD'
  )
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  required_documents = EXCLUDED.required_documents,
  fee_display = EXCLUDED.fee_display;
