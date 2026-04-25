# BridgeID — system architecture

This note summarizes how the repository is structured and how the main components interact.

## Overview

- **Citizen app (Flutter):** authentication, service catalog, signed service QR generation, local SQLite outbox, and sync to the API.
- **Verifier app (Flutter):** QR capture, local sanity checks, SQLite queue, and scan upload to the API.
- **API (Node.js + Express):** REST endpoints backed by PostgreSQL; JWT access and refresh tokens; admin operations; optional Redis for rate limiting.
- **Admin web (React + Vite):** operational dashboard for metrics, device keys, and audit logs.

## Backend layering

Routes stay thin. Business rules live in `src/services/`. SQL is isolated in `src/repositories/`. Shared behavior (auth, errors, rate limits, CORS) sits under `src/middleware/`.

## Identity and QR

Citizen service QR payloads use a versioned JSON format with an HMAC over a canonical string. The server verifies signatures before accepting sync rows. Duplicate submissions are prevented with a stable content hash and idempotent inserts.

## Offline sync

The citizen app stores pending rows locally and uploads batches when online. Failed rows can be retried from the UI. The verifier app follows the same pattern for scan records.

## Security

Secrets belong in environment variables only (see `backend/.env.example`). Production deployments should terminate TLS at a reverse proxy, restrict CORS origins, and use strong random values for all JWT and admin keys.
