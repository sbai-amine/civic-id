import { config } from 'dotenv';
import path from 'node:path';
import { fileURLToPath } from 'url';

const root = path.join(path.dirname(fileURLToPath(import.meta.url)), '../..');
config({ path: path.join(root, '.env') });
if (!process.env.ADMIN_API_KEY) {
  process.env.ADMIN_API_KEY = 'civickey-test-default-admin';
}
if (!process.env.JWT_ADMIN_SECRET) {
  process.env.JWT_ADMIN_SECRET = 'civickey-test-default-admin-jwt-secret-32c';
}
process.env.ALLOW_LEGACY_QR_PAYLOAD = '1';
