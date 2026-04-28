# Deliverable 3 Report (30%)

Project: **BridgeID**  
Repository: [https://github.com/aliiahmeeed999-hub/bridgeID](https://github.com/aliiahmeeed999-hub/bridgeID)

Submission links summary:

| Requirement | Link / Evidence |
|---|---|
| GitHub repository | [https://github.com/aliiahmeeed999-hub/bridgeID](https://github.com/aliiahmeeed999-hub/bridgeID) |
| CI/CD workflow file | `.github/workflows/ci-cd.yml` |
| Product backlog (Jira import) | `docs/product_backlog_jira_template.csv` |
| Jira board access | `<PASTE_JIRA_BOARD_URL>` |
| Screenshots folder | `docs/screenshots/` |

---

## 1) Product Backlog Creation (5 points)

Chosen project management tool: **Jira**

### Backlog organization method

- Backlog is prioritized by **P1 / P2 / P3** and grouped by epics:
  - Authentication
  - QR Security
  - Offline Sync
  - Verifier App
  - Admin Console
  - CI/CD
  - Localization
  - Security Hardening
  - Documentation & Testing
- Estimation uses **Story Points**.
- Stories are mapped to target sprints.

### Included backlog artifact

- Jira import template (CSV): `docs/product_backlog_jira_template.csv`
- Contains 20 structured stories with:
  - Priority
  - Epic
  - Story ID
  - User Story
  - Acceptance Criteria
  - Story Points
  - Sprint

### Product backlog content snapshot

The backlog includes:

- P1 critical delivery items: authentication, QR security, offline sync, admin operations, CI/CD.
- P2 stabilization items: localization, profile/security UX, performance indexing.
- P3 readiness items: smoke tests and final class demo preparation.

### Evidence required for submission

- Add your Jira board URL here: `<PASTE_JIRA_BOARD_URL>`
- Add screenshots in the submission package:
  - Screenshot 1: Product backlog list view with priorities
  - Screenshot 2: Story details view (acceptance criteria + story points)
  - Screenshot 3: Sprint board view
  - Screenshot 4 (optional but recommended): board filter/search or sprint burndown view

---

## 2) CI/CD Pipeline Implementation (10 points)

Implemented using **GitHub Actions**.

Workflow file:

- `.github/workflows/ci-cd.yml`

### CI (Quality Checks)

Triggers:

- Pull requests to `main`
- Pushes to `main`
- Manual trigger (`workflow_dispatch`)

Checks performed:

1. **Backend**
   - Node.js setup
   - PostgreSQL service container
   - `npm ci` (backend)
   - Migration: `npm run migrate`
   - Tests: `npm test`
2. **Admin Web**
   - `npm ci` (admin-web)
   - Production build: `npm run build`
3. **Citizen App (Flutter)**
   - `flutter pub get`
   - `flutter analyze`
   - `flutter test`
4. **Verifier App (Flutter)**
   - `flutter pub get`
   - `flutter analyze`
   - `flutter test`

### CD (Deployment)

On successful push to `main`, the workflow deploys **admin-web** to **GitHub Pages**:

- Build path: `admin-web/dist`
- Deployment actions:
  - `actions/configure-pages`
  - `actions/upload-pages-artifact`
  - `actions/deploy-pages`

### Required repository settings

For production deployment behavior:

- Repository Variables:
  - `VITE_API_BASE_URL`
- Repository Secrets:
  - `VITE_ADMIN_API_KEY`

### Collaboration practices (for repository evidence)

To demonstrate collaboration practices in GitHub:

- Use protected `main` branch (recommended in repository settings).
- Use feature branches for changes (`feature/*`, `fix/*`).
- Open Pull Requests instead of direct pushes to `main` for team work.
- Require at least one review before merge (if team setup is available).
- Keep CI checks required before merge.

---

## 3) Technology Stack and High-Level Architecture (5 points)

### Technology stack

- **Citizen Mobile App:** Flutter + Dart
- **Verifier Mobile App:** Flutter + Dart
- **Local persistence (mobile):** SQLite (`sqflite`) + secure storage
- **Backend API:** Node.js (Express)
- **Database:** PostgreSQL
- **Authentication:** JWT (access/refresh), admin API key/JWT
- **Admin Web:** React + Vite + Tailwind CSS
- **CI/CD:** GitHub Actions
- **Containerized local DB:** Docker Compose

### High-level architecture

1. Citizen app authenticates against backend API.
2. Citizen generates signed QR payloads and stores records locally (offline-first queue).
3. Verifier app scans and validates QR data locally, then uploads scan records when online.
4. Backend validates payload integrity, applies idempotent sync writes, and stores audit logs.
5. Admin web consumes secure admin endpoints for KPIs, logs, and key management.
6. CI/CD ensures build/test quality and deploys admin web changes on main branch.

Reference architecture note:

- `docs/PRODUCTION_ARCHITECTURE.md`

---

## 4) 10-Minute In-Class Demo Plan (10 points)

### Suggested agenda (10 minutes total)

1. **Problem & objective (1 min)**
   - Briefly define the use case and users.
2. **Architecture & stack (2 min)**
   - Show system components and data flow.
3. **Product backlog (2 min)**
   - Open Jira board; explain prioritization and sprint planning.
4. **CI/CD pipeline (2 min)**
   - Show GitHub Actions runs and deployment workflow.
5. **Live feature walkthrough (3 min)**
   - Citizen sign-in and QR generation
   - Verifier scan + sync behavior
   - Admin dashboard KPIs/logs

### Demo checklist

- Backend running and database migrated
- Citizen app ready
- Verifier app ready
- Admin web URL working
- Jira board tab open
- GitHub Actions tab open (recent successful run visible)

---

## Submission Package Checklist

- [x] Comprehensive report with backlog and CI/CD details (`docs/DELIVERABLE_3_REPORT.md`)
- [x] Product backlog template (`docs/product_backlog_jira_template.csv`)
- [x] CI/CD workflow (`.github/workflows/ci-cd.yml`)
- [ ] Jira board access link added in report
- [ ] Jira screenshots attached
- [x] GitHub repository link provided
- [ ] GitHub Actions run screenshot attached
- [ ] Optional PR/branch collaboration screenshot attached

