# Local database migrations

## Current version

- **Drift `schemaVersion`:** `2`
- **v1:** Phase 2 (`onCreate` → eight tables → triggers)
- **v2 (Phase 4.1):** `installation_profile`, `known_businesses` on bootstrap and business files; `onUpgrade` from 1→2 adds tables without dropping data

## Upgrades

Future phases append steps in `AppDatabase.migration.onUpgrade`:

```dart
if (from < 2) { /* Phase 5 catalog tables */ }
```

Do **not** ship empty upgrade steps.

## Testing future upgrades

When v2+ exists:

1. Generate fixture DBs under `mobile/test/fixtures/migrations/vN.sqlite` from tagged releases.
2. In tests: copy fixture → open with current `AppDatabase` → run migrations → assert schema + row counts.
3. CI runs the full chain v1 → current.

Phase 2 tests cover **fresh v1 creation** only.
