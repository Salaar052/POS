# Phase 1 — Project initialization

## Objectives

Establish a maintainable monorepo with runnable Flutter and NestJS applications, empty Prisma schema, documentation, and CI-ready verification commands—no business domain tables or sync.

## Tasks

1. `git init` at repository root (no commit without owner approval).
2. `flutter create` → `mobile/` with Windows, Android, iOS platforms.
3. NestJS scaffold → `server/` with health endpoint.
4. Prisma: `schema.prisma` with PostgreSQL datasource only (no models); `.env.example` on server.
5. Root `README.md`, `.gitignore`, architecture docs (ADR, phase deps).
6. Minimal Flutter shell UI (placeholder, not POS logic).
7. Tests: default Flutter widget test updated; Nest unit + e2e for `/health`.
8. Run `flutter analyze`, `flutter test`, `npm run lint`, `npm run test`, `npm run test:e2e`.

## Out of scope

- Drift, Riverpod, GoRouter, Dio, business entities.
- Database migrations against Neon/production.
- Git commit/push.

## Verification checklist

- [ ] `flutter doctor` clean
- [ ] `flutter run -d windows` launches placeholder app
- [ ] `npm run start:dev` serves `GET /health`
- [ ] `npx prisma validate` passes with placeholder `DATABASE_URL`
- [ ] All lint/test commands pass

## Known limitations (Phase 1)

- Default Nest root `GET /` remains for scaffold compatibility; product health is `/health`.
- PostgreSQL not required to run server or tests in this phase.
