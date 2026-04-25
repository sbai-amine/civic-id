# BridgeID — deployment notes

## Prerequisites

- Docker Desktop (for local PostgreSQL)
- Node.js 20+ and npm
- Flutter SDK (for mobile apps)

## Database

```bash
docker compose up -d db
```

Copy `backend/.env.example` to `backend/.env` and set secrets and `DATABASE_URL`.

Run migrations:

```bash
npm --prefix backend run migrate
```

## API server

```bash
npm --prefix backend start
```

Default: `http://localhost:3000`

## Mobile apps

Citizen app (from repository root):

```bash
flutter run --dart-define=API_BASE_URL=http://localhost:3000
```

Verifier app (`agent_app`):

```bash
flutter run --dart-define=API_BASE_URL=http://localhost:3000 --dart-define=AGENT_API_KEY=<your-key>
```

## Admin web

From `admin-web/`:

```bash
cp .env.example .env.local
# Set VITE_API_BASE_URL and VITE_ADMIN_API_KEY in .env.local
npm install
npm run dev
```

## Troubleshooting

- **Port 3000 in use:** stop the other process or change `PORT` in `backend/.env`.
- **Database connection refused:** ensure the database container is running.
- **Flutter build issues on cloud-synced folders:** use a local non-synced directory for builds if needed.
