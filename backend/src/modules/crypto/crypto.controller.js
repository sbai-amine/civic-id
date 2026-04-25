import * as cryptoDomain from './crypto.controller.service.js';

export async function signDocument(req, res) {
  const nationalId = req.user?.nationalID ?? req.user?.sub;
  if (!nationalId) {
    return res.status(401).json({ success: false, error: { code: 'UNAUTHORIZED' } });
  }
  const { docType, payload } = req.body ?? {};
  if (typeof docType !== 'string' || !docType.trim() || payload == null || typeof payload !== 'object') {
    return res.status(400).json({
      success: false,
      error: {
        code: 'VALIDATION_ERROR',
        message: 'Body must include docType (string) and payload (object)',
      },
    });
  }
  const signed = await cryptoDomain.signDocumentForUser({
    nationalId,
    docType: docType.trim(),
    docPayload: payload,
  });
  return res.status(201).json({ success: true, data: { signed } });
}

export async function verifyDocument(req, res) {
  const id = String(req.params.id || '');
  if (!id) {
    return res.status(400).json({ success: false, error: { code: 'VALIDATION_ERROR' } });
  }
  const data = await cryptoDomain.verifyStoredDocument({ id });
  return res.status(200).json({ success: true, data });
}
