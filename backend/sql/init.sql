-- CivicKey production schema
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  national_id TEXT NOT NULL UNIQUE,
  full_name TEXT NOT NULL DEFAULT '',
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
    'Birth Certificate',
    'Official request for a certified copy of a birth record from the civil registry.',
    '["National ID of parent or legal guardian", "Family record book", "Parent consent if minor"]'::jsonb,
    '5.00 DH — same-day processing where available'
  ),
  (
    'national_id_renewal',
    'National ID Renewal',
    'Renewal or replacement of the electronic national identity card (CNIE).',
    '["Expired or damaged CNIE", "2 passport photos", "Birth certificate"]'::jsonb,
    'Free for first replacement — 40.00 DH for subsequent replacements'
  ),
  (
    'passport_application',
    'Passport Application',
    'Application for a new Moroccan passport or renewal of an existing one.',
    '["National ID (CNIE)", "Birth certificate", "4 passport photos", "Proof of residence", "Tax stamp"]'::jsonb,
    '500.00 DH — standard processing (4–6 weeks)'
  ),
  (
    'family_record_book',
    'Family Record Book',
    'Official document recording family composition, issued at marriage or birth.',
    '["Marriage certificate", "National IDs of both spouses", "Birth certificates of children if applicable"]'::jsonb,
    'Free'
  ),
  (
    'marriage_certificate',
    'Marriage Certificate',
    'Certified copy of a marriage record from the civil registry.',
    '["National IDs of both spouses", "Original marriage act reference number"]'::jsonb,
    '5.00 DH'
  ),
  (
    'death_certificate',
    'Death Certificate',
    'Official certified copy of a death record from the civil registry.',
    '["National ID of requesting family member", "Deceased''s identity information", "Medical death certificate if available"]'::jsonb,
    '5.00 DH'
  ),
  (
    'residence_certificate',
    'Residence Certificate',
    'Official proof of residence issued by the local commune or district authority for address verification.',
    '["National ID (CNIE)", "Utility bill (water/electricity — last 3 months) or lease", "Rental contract or property title if requested"]'::jsonb,
    '10.00 DH'
  ),
  (
    'certificate_of_life',
    'Certificate of Life',
    'Proof of life certificate required by pension funds and foreign authorities.',
    '["National ID (CNIE)", "Recent medical certificate or personal appearance at commune"]'::jsonb,
    '10.00 DH'
  ),
  (
    'driving_license_application',
    'Driving License Application',
    'Application for a first-time Moroccan driving license (Category B).',
    '["National ID (CNIE)", "Medical fitness certificate", "Proof of passing theory and practical exams", "4 passport photos"]'::jsonb,
    '300.00 DH — Category B (standard car/motorcycle fees vary)'
  ),
  (
    'vehicle_registration',
    'Vehicle Registration',
    'Registration of a new or transferred vehicle with the transport authority.',
    '["National ID", "Vehicle purchase invoice or transfer document", "Insurance certificate", "Technical inspection certificate"]'::jsonb,
    'Varies by vehicle type and fiscal horsepower — from 350.00 DH'
  ),
  (
    'social_security_enrollment',
    'CNSS Enrollment',
    'Enrollment in the social security system for health insurance, family allowances, and pension.',
    '["National ID (CNIE)", "Employment contract or employer declaration", "Birth certificate", "Bank account details (RIB)"]'::jsonb,
    'Free — employer handles registration'
  ),
  (
    'ramed_enrollment',
    'RAMED Medical Assistance',
    'Enrollment in the medical assistance program for low-income households.',
    '["National ID", "Proof of income or indigence certificate", "Family record book"]'::jsonb,
    'Free — means-tested eligibility'
  ),
  (
    'land_registry_extract',
    'Land Registry Extract',
    'Official extract from the land registry confirming property ownership and legal status.',
    '["National ID", "Property title number", "Completed request form"]'::jsonb,
    '150.00 DH'
  ),
  (
    'judicial_record',
    'Criminal Record Certificate',
    'Official certificate of criminal record status, required for employment, travel visas, and administrative procedures.',
    '["National ID (CNIE)", "Birth certificate"]'::jsonb,
    'Free — processed at local courthouse or online via e-services'
  ),
  (
    'tax_clearance_certificate',
    'Tax Clearance Certificate',
    'Certificate from the tax authority confirming no outstanding tax liabilities.',
    '["National ID or company registration number", "Tax identification number", "Last tax return"]'::jsonb,
    'Free'
  )
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  required_documents = EXCLUDED.required_documents,
  fee_display = EXCLUDED.fee_display;
