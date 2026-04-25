import { test } from 'node:test';
import assert from 'node:assert/strict';
import { buildCanonicalV2, hmacSignatureBase64, verifyCitizenServiceQrPayload } from '../services/qrTokenService.js';

const key = '0'.repeat(64);

test('HMAC v2 sign and verify with matching nationalId', () => {
  const userId = '123456';
  const ts = '2026-01-15T10:00:00.000Z';
  const nonce = 'aabbccdd';
  const serviceId = 'birth_certificate';
  const can = buildCanonicalV2({ userId, timestamp: ts, nonce, serviceId });
  const sig = hmacSignatureBase64(key, can);
  const payload = JSON.stringify({
    v: 2,
    userID: userId,
    timestamp: ts,
    nonce,
    serviceId,
    signature: sig,
  });
  const v = verifyCitizenServiceQrPayload({
    payload,
    nationalId: userId,
    hmacKeyHex: key,
    serviceId,
  });
  assert.equal(v.ok, true);
});

test('verify fails on tampered signature', () => {
  const userId = '123456';
  const ts = '2026-01-15T10:00:00.000Z';
  const can = buildCanonicalV2({ userId, timestamp: ts, nonce: 'n1', serviceId: 's' });
  const bad = JSON.stringify({
    v: 2,
    userID: userId,
    timestamp: ts,
    nonce: 'n1',
    serviceId: 's',
    signature: hmacSignatureBase64('1'.repeat(64), can),
  });
  const v = verifyCitizenServiceQrPayload({
    payload: bad,
    nationalId: userId,
    hmacKeyHex: key,
    serviceId: 's',
  });
  assert.equal(v.ok, false);
  assert.equal(v.code, 'BAD_SIGNATURE');
});
