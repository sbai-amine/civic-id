import { createSignedDocument, getSignedDocumentById } from '../../repositories/signedDocumentRepository.js';
import { createAuditLog } from '../../repositories/auditRepository.js';
import { signPayload, verifyPayloadSignature } from './cryptoIdentity.service.js';

export async function signDocumentForUser({ nationalId, docType, docPayload }) {
  const sig = signPayload(docPayload);
  const row = await createSignedDocument({
    userNationalId: nationalId,
    docType,
    docPayload,
    payloadHash: sig.payloadHash,
    signature: sig.signature,
    signatureAlg: sig.signatureAlg,
  });
  await createAuditLog({
    actorType: 'citizen',
    actorRef: nationalId,
    action: 'document.signed',
    resourceType: 'signed_document',
    resourceId: row.id,
    metadata: { docType },
  });
  return {
    ...row,
    publicKeyPem: sig.publicKeyPem,
  };
}

export async function verifyStoredDocument({ id }) {
  const row = await getSignedDocumentById(id);
  if (!row) {
    const err = new Error('Signed document not found');
    err.status = 404;
    err.code = 'NOT_FOUND';
    throw err;
  }
  const verification = verifyPayloadSignature({
    payload: row.doc_payload,
    signature: row.signature,
  });
  return {
    document: row,
    verification,
  };
}
