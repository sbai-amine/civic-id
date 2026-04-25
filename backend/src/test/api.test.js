import { test, before } from 'node:test';
import assert from 'node:assert/strict';
import request from 'supertest';
import app from '../app.js';
import { getPool } from '../db/pool.js';
import { hashCitizenQr } from '../utils/contentHash.js';
import { ADMIN_API_KEY } from '../config.js';

const hasDb = () => Boolean(getPool() && process.env.DATABASE_URL);

let accessToken;
const nationalId = '123456';

if (hasDb()) {
  before(async () => {
    const res = await request(app)
      .post('/login')
      .send({ nationalID: nationalId, PIN: '1234' });
    if (res.status === 200) {
      accessToken = res.body.data.accessToken;
    }
  });
}

test('GET /health', async () => {
  const res = await request(app).get('/health');
  assert.equal(res.status, 200);
  assert.equal(res.body.ok, true);
});

test('GET /services rejects bad JWT', async () => {
  const res = await request(app)
    .get('/services')
    .set('Authorization', 'Bearer not-a-jwt');
  assert.equal(res.status, 401);
});

test('POST /login (integration)', { skip: !hasDb() }, async () => {
  const res = await request(app)
    .post('/login')
    .send({ nationalID: nationalId, PIN: '1234' });
  assert.equal(res.status, 200);
  assert.equal(res.body.success, true);
  assert.ok(res.body.data.accessToken);
  assert.ok(res.body.data.refreshToken);
});

test('GET /services with valid token', { skip: !hasDb() }, async () => {
  if (!accessToken) return;
  const res = await request(app)
    .get('/services')
    .set('Authorization', `Bearer ${accessToken}`);
  assert.equal(res.status, 200);
  assert.ok(Array.isArray(res.body.data.services));
});

test('sync idempotency duplicate hash', { skip: !hasDb() }, async () => {
  if (!accessToken) return;
  const createdAt = new Date().toISOString();
  const serviceId = 'idempotency_test';
  const serviceName = 'Test';
  const payload = JSON.stringify({ userID: nationalId, timestamp: createdAt });
  const hash = hashCitizenQr({
    nationalId,
    serviceId,
    payload,
    createdAt,
  });
  const item = {
    localId: 999001,
    serviceId,
    serviceName,
    payload,
    createdAt,
    hash,
  };
  const a = await request(app)
    .post('/sync/service-qr')
    .set('Authorization', `Bearer ${accessToken}`)
    .send({ items: [item] });
  assert.equal(a.status, 200, a.text);
  const b = await request(app)
    .post('/sync/service-qr')
    .set('Authorization', `Bearer ${accessToken}`)
    .send({ items: [item] });
  assert.equal(b.status, 200);
  assert.ok(b.body.data.duplicates >= 1);
});

test('POST /auth/refresh validation', { skip: !hasDb() }, async () => {
  const res = await request(app).post('/auth/refresh').send({});
  assert.equal(res.status, 400);
});

test('POST /auth/admin/token — wrong key', { skip: !ADMIN_API_KEY }, async () => {
  const res = await request(app)
    .post('/auth/admin/token')
    .set('Authorization', 'Bearer not-the-admin-key');
  assert.equal(res.status, 401);
});

test('POST /auth/admin/token — success', { skip: !ADMIN_API_KEY }, async () => {
  const res = await request(app)
    .post('/auth/admin/token')
    .set('Authorization', `Bearer ${ADMIN_API_KEY}`);
  assert.equal(res.status, 200);
  assert.equal(res.body.success, true);
  assert.ok(res.body.data.adminToken);
  assert.equal(res.body.data.tokenType, 'Bearer');
  assert.ok(res.body.data.expiresIn);
});

test('GET /admin/sync-records with admin JWT', { skip: !ADMIN_API_KEY }, async () => {
  const tok = await request(app)
    .post('/auth/admin/token')
    .set('Authorization', `Bearer ${ADMIN_API_KEY}`);
  assert.equal(tok.status, 200, tok.text);
  const { adminToken } = tok.body.data;
  const r = await request(app)
    .get('/admin/sync-records')
    .set('Authorization', `Bearer ${adminToken}`);
  assert.equal(r.status, 200, r.text);
  assert.equal(r.body.success, true);
  assert.ok(r.body.data);
});

test('GET /admin/kpis with admin JWT', { skip: !ADMIN_API_KEY }, async () => {
  const tok = await request(app)
    .post('/auth/admin/token')
    .set('Authorization', `Bearer ${ADMIN_API_KEY}`);
  assert.equal(tok.status, 200, tok.text);
  const r = await request(app)
    .get('/admin/kpis')
    .set('Authorization', `Bearer ${tok.body.data.adminToken}`);
  assert.equal(r.status, 200, r.text);
  assert.equal(r.body.success, true);
  assert.ok(r.body.data.kpis);
});

test('GET /admin/audit-logs with admin JWT', { skip: !ADMIN_API_KEY }, async () => {
  const tok = await request(app)
    .post('/auth/admin/token')
    .set('Authorization', `Bearer ${ADMIN_API_KEY}`);
  assert.equal(tok.status, 200, tok.text);
  const r = await request(app)
    .get('/admin/audit-logs')
    .set('Authorization', `Bearer ${tok.body.data.adminToken}`);
  assert.equal(r.status, 200, r.text);
  assert.equal(r.body.success, true);
  assert.ok(Array.isArray(r.body.data.logs));
});

test('POST /admin/agent-keys/:id/disable and enable', { skip: !hasDb() || !ADMIN_API_KEY }, async () => {
  const tok = await request(app)
    .post('/auth/admin/token')
    .set('Authorization', `Bearer ${ADMIN_API_KEY}`);
  assert.equal(tok.status, 200, tok.text);
  const adminToken = tok.body.data.adminToken;
  const keys = await request(app)
    .get('/admin/agent-keys')
    .set('Authorization', `Bearer ${adminToken}`);
  assert.equal(keys.status, 200, keys.text);
  assert.ok(Array.isArray(keys.body.data.keys));
  assert.ok(keys.body.data.keys.length >= 1);
  const id = keys.body.data.keys[0].id;

  const disable = await request(app)
    .post(`/admin/agent-keys/${id}/disable`)
    .set('Authorization', `Bearer ${adminToken}`);
  assert.equal(disable.status, 200, disable.text);
  assert.equal(disable.body.data.key.disabled, true);

  const enable = await request(app)
    .post(`/admin/agent-keys/${id}/enable`)
    .set('Authorization', `Bearer ${adminToken}`);
  assert.equal(enable.status, 200, enable.text);
  assert.equal(enable.body.data.key.disabled, false);
});

test('POST /crypto/sign-document and GET verify', { skip: !hasDb() || !ADMIN_API_KEY }, async () => {
  const login = await request(app)
    .post('/login')
    .send({ nationalID: nationalId, PIN: '1234' });
  assert.equal(login.status, 200, login.text);
  const userAccess = login.body.data.accessToken;
  const signed = await request(app)
    .post('/crypto/sign-document')
    .set('Authorization', `Bearer ${userAccess}`)
    .send({
      docType: 'service_request',
      payload: { serviceId: 'birth_certificate', requestedAt: new Date().toISOString() },
    });
  assert.equal(signed.status, 201, signed.text);
  assert.ok(signed.body.data.signed.id);
  assert.ok(signed.body.data.signed.signature);

  const tok = await request(app)
    .post('/auth/admin/token')
    .set('Authorization', `Bearer ${ADMIN_API_KEY}`);
  assert.equal(tok.status, 200, tok.text);
  const verify = await request(app)
    .get(`/crypto/signed-documents/${signed.body.data.signed.id}/verify`)
    .set('Authorization', `Bearer ${tok.body.data.adminToken}`);
  assert.equal(verify.status, 200, verify.text);
  assert.equal(verify.body.data.verification.ok, true);
});
