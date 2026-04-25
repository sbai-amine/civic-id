import { query } from '../db/pool.js';

let _ensured = false;

async function ensureSignedDocsTable() {
  if (_ensured) return;
  await query(
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
  _ensured = true;
}

export async function createSignedDocument({ userNationalId, docType, docPayload, payloadHash, signature, signatureAlg }) {
  await ensureSignedDocsTable();
  const { rows } = await query(
    `INSERT INTO signed_documents (user_national_id, doc_type, doc_payload, payload_hash, signature, signature_alg)
     VALUES ($1, $2, $3, $4, $5, $6)
     RETURNING id, user_national_id, doc_type, doc_payload, payload_hash, signature, signature_alg, signed_at`,
    [userNationalId, docType, docPayload, payloadHash, signature, signatureAlg],
  );
  return rows[0];
}

export async function getSignedDocumentById(id) {
  await ensureSignedDocsTable();
  const { rows } = await query(
    `SELECT id, user_national_id, doc_type, doc_payload, payload_hash, signature, signature_alg, signed_at
     FROM signed_documents
     WHERE id = $1`,
    [id],
  );
  return rows[0] ?? null;
}
