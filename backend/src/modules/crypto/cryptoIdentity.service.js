import crypto from 'node:crypto';
import { SIGNING_PRIVATE_KEY_PEM, SIGNING_PUBLIC_KEY_PEM } from '../../config.js';

let privatePem = SIGNING_PRIVATE_KEY_PEM;
let publicPem = SIGNING_PUBLIC_KEY_PEM;

if (!privatePem || !publicPem) {
  const pair = crypto.generateKeyPairSync('ed25519');
  privatePem = pair.privateKey.export({ type: 'pkcs8', format: 'pem' }).toString();
  publicPem = pair.publicKey.export({ type: 'spki', format: 'pem' }).toString();
  console.warn('[bridgeid-api] Using ephemeral signing keypair (set SIGNING_PRIVATE_KEY_PEM/PUBLIC for persistence).');
}

function sortObject(v) {
  if (Array.isArray(v)) return v.map(sortObject);
  if (v && typeof v === 'object') {
    return Object.keys(v)
      .sort()
      .reduce((acc, k) => {
        acc[k] = sortObject(v[k]);
        return acc;
      }, {});
  }
  return v;
}

export function canonicalizePayload(payload) {
  return JSON.stringify(sortObject(payload));
}

export function hashPayloadHex(payload) {
  return crypto.createHash('sha256').update(canonicalizePayload(payload), 'utf8').digest('hex');
}

export function signPayload(payload) {
  const canonical = canonicalizePayload(payload);
  const signature = crypto.sign(null, Buffer.from(canonical, 'utf8'), privatePem).toString('base64');
  return {
    signature,
    signatureAlg: 'ed25519',
    payloadHash: hashPayloadHex(payload),
    publicKeyPem: publicPem,
  };
}

export function verifyPayloadSignature({ payload, signature }) {
  const canonical = canonicalizePayload(payload);
  const ok = crypto.verify(
    null,
    Buffer.from(canonical, 'utf8'),
    publicPem,
    Buffer.from(signature, 'base64'),
  );
  return {
    ok,
    payloadHash: hashPayloadHex(payload),
    publicKeyPem: publicPem,
  };
}
