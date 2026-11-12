# Server identity foundation (Phase 4.3)

Phase 4.3 defines the **PostgreSQL identity schema**, Prisma migration (generated, not applied to Neon), NestJS module boundaries, password/token hashing utilities, tenant-isolation policy helpers, and audit rules. **Authentication HTTP APIs are intentionally not implemented.**

## Data model

| Model | Purpose |
|-------|---------|
| `Business` | Tenant root (PKR / Asia-Karachi defaults, `ACTIVE` / `SUSPENDED` / `CLOSED`) |
| `User` | Login identity; `normalizedEmail` unique; `passwordHash` only (Argon2id at service layer) |
| `BusinessMembership` | User ↔ business with `MembershipRole` and `MembershipStatus` |
| `Device` | Per-business device; `deviceIdentifierHash` unique per business; status lifecycle |
| `RefreshToken` | Opaque refresh sessions; **token hash only**; rotation via `tokenFamilyId` / `replacedByTokenId` |
| `AuditLog` | Append-only security audit trail (`metadata` JSON, no secrets) |

```mermaid
erDiagram
  Business ||--o{ BusinessMembership : has
  User ||--o{ BusinessMembership : joins
  Business ||--o{ Device : owns
  User ||--o{ Device : registers
  User ||--o{ RefreshToken : holds
  Business ||--o{ RefreshToken : scopes
  Device ||--o{ RefreshToken : binds
  Business ||--o{ AuditLog : scopes
  User ||--o{ AuditLog : actor
  Device ||--o{ AuditLog : actor
```

## Tenant isolation

1. Every business-owned row references `businessId` (or optional `businessId` on audit for platform events).
2. **Verified** `VerifiedTenantContext` is populated only after authentication + membership checks in later phases.
3. **Never** authorize using a client-supplied `businessId` alone (`TenantAuthorizationPolicy.rejectClientSuppliedBusinessId`).
4. Membership must be `ACTIVE` before business access.
5. Device `ACTIVE` status is validated separately; **revoked devices cannot reconnect into an active session** without a new activation flow (later phases).
6. Cross-business access requires explicit server-side authorization, not URL/body parameters.

No authentication guard reads untrusted headers in this phase.

## Future authentication requirements (Phase 4.8+)

Registration (Phase 4.4) may create an owner with **`User.status = PENDING_VERIFICATION`** while **`BusinessMembership.status = ACTIVE`** and **`role = OWNER`**. These dimensions are **independent**:

| Check | Rule |
|-------|------|
| Session | A valid **authenticated session** is required; registration alone is not authorization. |
| User | **`User.status`** and verification rules (e.g. `emailVerifiedAt`) must pass before treating the account as fully trusted. |
| Membership | **`BusinessMembership.status`** must be **`ACTIVE`**. |
| Role | The operation must be allowed for the member’s **`MembershipRole`**. |
| Tenancy | **Business context** comes from server-verified membership/session identity — never from a raw client `businessId`. |

An **ACTIVE OWNER membership does not** automatically authorize a **`PENDING_VERIFICATION`** user to use protected APIs.

## Password hashing

- **Argon2id** via the `argon2` package (`PasswordHashingService`).
- Plain passwords are rejected when empty and are **never** logged or returned.

## Refresh tokens

- Only **SHA-256 hashes** of opaque tokens are stored (`TokenHashService`).
- Raw tokens are generated with `randomBytes` for future login flows.
- Rotation fields: `tokenFamilyId`, `replacedByTokenId`, `RefreshTokenStatus`.

Access JWTs are **not** stored in the database.

## Audit

- Application rejects metadata keys matching sensitive patterns (password, token, secret, etc.).
- Migration adds PostgreSQL triggers preventing `UPDATE`/`DELETE` on `AuditLog`.

## Deletion behavior

Foreign keys use **`ON DELETE RESTRICT`** for business, user, membership, session, and audit relations so financial/audit history is not cascade-wiped. Device and audit references to devices may `SET NULL` where appropriate.

Implications:

- **Business `CLOSED`**: business row remains; memberships/devices/tokens must be revoked or closed via future workflows.
- **User suspension**: user row remains; sessions revoked in later APIs.
- **Device `REVOKED`**: status + `revokedAt`; re-activation requires a new controlled flow.

## Migration procedure (not applied in Phase 4.3)

Migration: `prisma/migrations/20251110133000_identity_foundation/`

Generated with:

```bash
cd server
# Stub URL only — does not connect to Neon for diff generation
export DATABASE_URL="postgresql://build:build@127.0.0.1:5432/pakpos_schema_only?schema=public"
npx prisma migrate diff --from-empty --to-schema-datamodel prisma/schema.prisma \
  --script -o prisma/migrations/20251110133000_identity_foundation/migration.sql
npx prisma validate
npx prisma generate
```

**Apply later** in a controlled dev database only:

```bash
npx prisma migrate deploy
```

Do **not** run `db push`, `migrate dev` against production/Neon until schema review is complete.

## Deferred APIs (Phase 4.4+)

- Business / owner registration
- Login, logout, refresh
- Device registration, activation, revocation
- Flutter auth integration

## Security limitations

- Schema and utilities alone do **not** provide authentication.
- No integration tests were run against a live PostgreSQL instance in this phase unless a local test DB is configured.
- JWT issuance remains disabled until `JWT_ACCESS_SECRET` and Phase 4.8.
