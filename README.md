# Pak POS — Offline-First POS & Billing

Commercial POS and billing management for businesses in Pakistan. Local SQLite is the operational database; cloud PostgreSQL provides sync, backup, and centralized management.

## Repository layout

| Path | Purpose |
|------|---------|
| `mobile/` | Flutter client (Windows, Android, iOS) |
| `server/` | NestJS REST API and sync backend |
| `docs/` | Architecture, API, deployment |

## Prerequisites

- Flutter **3.47.9** (Dart **3.13.7**)
- Node.js **20+** (LTS recommended)
- PostgreSQL connection for server development (e.g. Neon); not required for Phase 1 health checks
- Android SDK **36.0.0+** (mobile Android builds)
- Visual Studio **2026** with Windows development workload (desktop builds)

## Run the mobile app

```bash
cd mobile
flutter pub get
flutter run -d windows
# or: flutter run -d android
```

## Run the API server

```bash
cd server
cp .env.example .env   # edit DATABASE_URL when connecting a database
npm install
npm run start:dev
```

Health check: `GET http://localhost:3000/health`

## Verify

```bash
cd mobile && flutter analyze && flutter test
cd server && npm run lint && npm run test && npm run test:e2e
```

## Security

- Never commit `.env` files or database credentials.
- The Flutter app must not embed cloud database URLs or server secrets.

## Documentation

- [ADR-0001 — Offline-first architecture](docs/architecture/ADR-0001-offline-first-pos.md)
- [Phase dependencies](docs/architecture/phase-dependencies.md)
- [Phase 1 plan](docs/development/phase-1-plan.md)

## License

Proprietary — not for public redistribution without authorization.
