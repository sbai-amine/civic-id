# BridgeID

Digital identity and civic services companion: secure sign-in, service catalog, signed service QR codes, offline-first sync, and an operations dashboard for administrators.

**Author:** Mohammed Amine, Ali, Aymen

## Features

- **Citizen mobile app (Flutter):** national ID + PIN sign-in, JWT session handling, service browsing, HMAC-signed service QR generation, local history, offline outbox with retry and sync status.
- **Verifier mobile app (Flutter):** QR scanning, local validation, pending upload queue.
- **Backend API (Node.js + PostgreSQL):** authentication, sync endpoints with idempotency, admin KPIs and audit logs, optional document signing (Ed25519).
- **Admin web (React + Vite):** overview metrics, device keys, audit log viewer.

## Tech stack

| Layer | Technology |
|--------|------------|
| Citizen & verifier apps | Flutter, Dart, sqflite, secure storage |
| Admin UI | React 18, Vite 5, Tailwind CSS |
| API | Express, PostgreSQL, JWT, bcrypt |
| Infrastructure | Docker Compose (PostgreSQL) |

## Repository layout

- `lib/` — citizen Flutter application source
- `agent_app/` — verifier Flutter application source
- `backend/` — REST API and database migrations
- `admin-web/` — standalone admin dashboard

## Installation

### 1. Clone

```bash
git clone https://github.com/sbai-amine/civic-id
cd bridgeID
```

### 2. Backend

```bash
cd backend
cp .env.example .env
# Edit .env: DATABASE_URL, JWT secrets, ADMIN_API_KEY, etc.
npm install
cd ..
docker compose up -d db
npm --prefix backend run migrate
npm --prefix backend start
```

### 3. Admin web (optional)

```bash
cd admin-web
cp .env.example .env.local
# Set VITE_API_BASE_URL (e.g. http://127.0.0.1:3000) and VITE_ADMIN_API_KEY
npm install
npm run dev
```

### 4. Flutter apps

From the repo root (citizen app):

```bash
flutter pub get
flutter run --dart-define=API_BASE_URL=https://civic-id-production.up.railway.app
```

Verifier app:

```bash
cd agent_app
flutter pub get
flutter run --dart-define=API_BASE_URL=http://localhost:3000 --dart-define=AGENT_API_KEY=<key-from-backend>
```

## Usage

1. Start PostgreSQL and the API (`npm --prefix backend start`).
2. Open the citizen app, sign in with a user created by your migration/seed policy.
3. Browse services, generate a service QR, and use **Sync** on the home screen when online.
4. Use the verifier app to scan codes and upload scan records when online.
5. Use the admin web app (with `VITE_ADMIN_API_KEY`) to review metrics and logs.

## Security notes

- Never commit real `.env` files or production keys.
- Rotate `JWT_*` secrets and `ADMIN_API_KEY` for production.
- Restrict CORS origins in production via backend configuration.

## License

All rights reserved unless otherwise specified by the author.

## Assessment Deliverable 3

- Report: `docs/DELIVERABLE_3_REPORT.md`
- Jira backlog import file: `docs/product_backlog_jira_template.csv`
- CI/CD pipeline: `.github/workflows/ci-cd.yml`
