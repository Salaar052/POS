# Local SQLite schema v2 — installation registry (Phase 4.1)

Drift `schemaVersion = 2` extends v1. **Normal app startup never calls `provisionBusiness()`.**

## Bootstrap vs business database

| File | Purpose |
|------|---------|
| `{pakpos}/local.sqlite` | **Bootstrap** — installation registry only; tenant tables remain present for schema compatibility but **must not** hold business operational data. |
| `{pakpos}/business_{business_id}.sqlite` | **Business** — tenant tables; `provisionBusiness()` runs only here via an explicit API. |

Startup always opens `local.sqlite` first. Switching to a business file replaces the active `DatabaseService` and `ProviderContainer`.

Cross-file provisioning is **not** one SQLite transaction. Recovery uses `known_businesses.provisioning_status`.

## New tables (v2)

### `installation_profile` (singleton)

| Column | Notes |
|--------|--------|
| `singleton_id` | Always `1` |
| `app_install_id` | Device install UUID |
| `active_business_id` | Nullable; set only after a business DB is verified |
| `created_at_ms` / `updated_at_ms` | UTC ms |

### `known_businesses`

| Column | Notes |
|--------|--------|
| `business_id` | PK — server-issued UUID |
| `display_name` | Label in UI / recovery |
| `database_file_name` | e.g. `business_{id}.sqlite` |
| `provisioning_status` | `PROVISIONING` or `READY` |
| `created_at_ms` | UTC ms |
| `last_opened_at_ms` | Nullable UTC ms |

No secrets, passwords, tokens, or API keys in these tables.

## Provisioning state machine

1. Explicit caller requests provision for a UUID `business_id`.
2. Bootstrap registry records `PROVISIONING` (if not already `READY`).
3. If `business_{id}.sqlite` **exists**: verify or fail — **never overwrite**.
4. Create business file; run `provisionBusiness()` in one business-DB transaction.
5. Verify `local_business.business_id`.
6. Mark registry `READY`; set `active_business_id` only after verification.

**Crash recovery:** stale `PROVISIONING` + valid business file → `openReadyBusiness` promotes to `READY`. Incomplete file → actionable error; file unchanged.

## Triggers (v2)

- Existing Phase 2 triggers unchanged.
- `installation_profile_singleton_insert` — one profile row.

## Migration v1 → v2

`onUpgrade` from 1 to 2: `CREATE` installation tables + installation trigger. Existing v1 rows and triggers are preserved.

See `LegacyV1AppDatabase` (test-only) and `schema_v2_migration_test.dart` for a real upgrade fixture.
