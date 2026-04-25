import { getPool } from '../db/pool.js';
import { hashCitizenQr, hashAgentScan } from '../utils/contentHash.js';
import { verifyCitizenServiceQrPayload } from './qrTokenService.js';
import { getOrCreateQrHmacKeyByNationalId } from '../repositories/userRepository.js';
import { insertAgentScan, insertCitizenServiceQr } from '../repositories/syncRepository.js';
import { acceptedScans, acceptedServiceQrs } from '../models/sync_store.model.js';

function isNonEmptyArray(v) {
  return Array.isArray(v) && v.length > 0;
}

/**
 * @param {import('express').Request} req
 * @param {import('express').Response} res
 */
export async function processCitizenServiceQrSync(req, res) {
  const { items } = req.body ?? {};
  if (!isNonEmptyArray(items)) {
    return res.status(400).json({
      success: false,
      error: { code: 'VALIDATION_ERROR', message: 'Body must include a non-empty items array' },
    });
  }

  const nationalId = req.user?.nationalID ?? req.user?.sub;
  if (!nationalId) {
    return res.status(401).json({ success: false, error: { code: 'UNAUTHORIZED' } });
  }

  if (!getPool()) {
    return memoryCitizenSync(items, nationalId, res);
  }

  const hmacKeyHex = await getOrCreateQrHmacKeyByNationalId(nationalId);
  if (!hmacKeyHex) {
    return res.status(500).json({
      success: false,
      error: { code: 'SERVER_ERROR', message: 'User not found' },
    });
  }

  const acceptedLocalIds = [];
  const duplicateLocalIds = [];

  for (const row of items) {
    const localId = row?.localId;
    const serviceId = row?.serviceId;
    const serviceName = row?.serviceName;
    const payload = row?.payload;
    const createdAt = row?.createdAt;
    const hash = row?.hash;

    if (
      typeof localId !== 'number' ||
      !Number.isInteger(localId) ||
      typeof serviceId !== 'string' ||
      typeof serviceName !== 'string' ||
      typeof payload !== 'string' ||
      typeof createdAt !== 'string' ||
      typeof hash !== 'string' ||
      !hash.trim()
    ) {
      return res.status(400).json({
        success: false,
        error: {
          code: 'VALIDATION_ERROR',
          message: 'Each item needs localId, serviceId, serviceName, payload, createdAt, hash (string)',
        },
      });
    }

    const v = verifyCitizenServiceQrPayload({
      payload,
      nationalId,
      hmacKeyHex,
      serviceId,
    });
    if (!v.ok) {
      return res.status(400).json({ success: false, error: { code: v.code, message: v.message } });
    }

    const expected = hashCitizenQr({ nationalId, serviceId, payload, createdAt });
    if (hash !== expected) {
      return res.status(400).json({
        success: false,
        error: { code: 'HASH_MISMATCH', message: 'Record hash does not match payload' },
      });
    }

    const createdAtClient = new Date(createdAt);
    const r = await insertCitizenServiceQr({
      nationalId,
      contentHash: hash,
      localId,
      serviceId,
      serviceName,
      payload,
      createdAtClient,
    });
    if (r === 'duplicate') duplicateLocalIds.push(localId);
    acceptedLocalIds.push(localId);
  }

  return res.status(200).json({
    success: true,
    data: {
      accepted: acceptedLocalIds.length,
      localIds: acceptedLocalIds,
      duplicates: duplicateLocalIds.length,
    },
  });
}

function memoryCitizenSync(items, nationalId, res) {
  const acceptedLocalIds = [];
  for (const row of items) {
    const localId = row?.localId;
    const serviceId = row?.serviceId;
    const serviceName = row?.serviceName;
    const payload = row?.payload;
    const createdAt = row?.createdAt;
    if (
      typeof localId !== 'number' ||
      !Number.isInteger(localId) ||
      typeof serviceId !== 'string' ||
      typeof serviceName !== 'string' ||
      typeof payload !== 'string' ||
      typeof createdAt !== 'string'
    ) {
      return res.status(400).json({ success: false, error: { code: 'VALIDATION_ERROR' } });
    }
    acceptedServiceQrs.push({
      receivedAt: new Date().toISOString(),
      uploadedByNationalId: nationalId,
      localId,
      serviceId,
      serviceName,
      payload,
      createdAt,
    });
    acceptedLocalIds.push(localId);
  }
  return res.status(200).json({
    success: true,
    data: { accepted: acceptedLocalIds.length, localIds: acceptedLocalIds, duplicates: 0 },
  });
}

/**
 * @param {import('express').Request} req
 * @param {import('express').Response} res
 */
export async function processAgentScanSync(req, res) {
  const { items } = req.body ?? {};
  if (!isNonEmptyArray(items)) {
    return res.status(400).json({
      success: false,
      error: { code: 'VALIDATION_ERROR', message: 'Body must include a non-empty items array' },
    });
  }

  if (!getPool()) {
    return memoryAgentSync(items, res);
  }

  const agentKeyId = req.agentKeyId ?? null;
  const acceptedLocalIds = [];
  const duplicateLocalIds = [];

  for (const row of items) {
    const localId = row?.localId;
    const rawPayload = row?.rawPayload;
    const userId = row?.userId;
    const parseOk = row?.parseOk;
    const scannedAt = row?.scannedAt;
    const hash = row?.hash;
    if (
      typeof localId !== 'number' ||
      !Number.isInteger(localId) ||
      typeof rawPayload !== 'string' ||
      typeof scannedAt !== 'string' ||
      typeof parseOk !== 'boolean' ||
      typeof hash !== 'string' ||
      !hash.trim()
    ) {
      return res.status(400).json({ success: false, error: { code: 'VALIDATION_ERROR' } });
    }
    if (userId != null && typeof userId !== 'string') {
      return res.status(400).json({ success: false, error: { code: 'VALIDATION_ERROR' } });
    }

    const expected = hashAgentScan({ userId, rawPayload, scannedAt });
    if (hash !== expected) {
      return res.status(400).json({
        success: false,
        error: { code: 'HASH_MISMATCH', message: 'Record hash does not match payload' },
      });
    }

    const r = await insertAgentScan({
      userId: userId ?? null,
      contentHash: hash,
      localId,
      rawPayload,
      agentKeyId,
      scannedAt: new Date(scannedAt),
    });
    if (r === 'duplicate') duplicateLocalIds.push(localId);
    acceptedLocalIds.push(localId);
  }

  return res.status(200).json({
    success: true,
    data: {
      accepted: acceptedLocalIds.length,
      localIds: acceptedLocalIds,
      duplicates: duplicateLocalIds.length,
    },
  });
}

function memoryAgentSync(items, res) {
  const acceptedLocalIds = [];
  for (const row of items) {
    const localId = row?.localId;
    const rawPayload = row?.rawPayload;
    const userId = row?.userId;
    const payloadTimestamp = row?.payloadTimestamp;
    const parseOk = row?.parseOk;
    const scannedAt = row?.scannedAt;
    if (
      typeof localId !== 'number' ||
      !Number.isInteger(localId) ||
      typeof rawPayload !== 'string' ||
      typeof scannedAt !== 'string' ||
      typeof parseOk !== 'boolean'
    ) {
      return res.status(400).json({ success: false, error: { code: 'VALIDATION_ERROR' } });
    }
    acceptedScans.push({
      receivedAt: new Date().toISOString(),
      localId,
      rawPayload,
      userId: userId ?? null,
      payloadTimestamp: payloadTimestamp ?? null,
      parseOk,
      scannedAt,
    });
    acceptedLocalIds.push(localId);
  }
  return res.status(200).json({
    success: true,
    data: { accepted: acceptedLocalIds.length, localIds: acceptedLocalIds, duplicates: 0 },
  });
}
