# Local SQLite schema v1 (Phase 2)

Drift `schemaVersion = 1` is the **only** schema version source of truth (no duplicate version table).

## Tenancy

- **Bootstrap (pre-provision):** `{appSupport}/pakpos/local.sqlite` — opened at app startup; **no** automatic `provisionBusiness()`
- **After provision (Phase 4+):** `{appSupport}/pakpos/business_{business_id}.sqlite`
- **`local_business`**: single row (`singleton_id = 1`), `business_id` UNIQUE
- All tenant tables reference `local_business.business_id` via foreign keys
- `provisionBusiness()` must be called explicitly; opening the DB does not create a business

## Tables

| Table | Role |
|-------|------|
| `local_business` | Business snapshot |
| `local_device` | Device row bound to same `business_id` (singleton) |
| `users_cache` | Non-secret user profile + `role` text (`owner`/`manager`/`cashier`) |
| `app_settings` | Key/value JSON per `setting_key` PK |
| `sync_operations` | Append-only outbound queue |
| `sync_cursors` | Inbound cursor placeholders |
| `sync_conflicts` | Master-data conflict placeholders |
| `audit_events` | Append-only audit log |

## Timestamps

All operational timestamps are **UTC Unix milliseconds** (`INTEGER`).

## Triggers

- Singleton insert guards on `local_business` and `local_device`
- `audit_events`: no UPDATE/DELETE
- `sync_operations`: no DELETE; identity/payload/`depends_on` immutable on UPDATE
- Self-dependency blocked on INSERT/UPDATE

## Phase 4

Offline credentials (password verifier, tokens) live in **platform secure storage**, not in `users_cache`.

Installation registry (schema v2): see [local-schema-v2-installation.md](local-schema-v2-installation.md). Bootstrap `local.sqlite` must not be used as the business database.
