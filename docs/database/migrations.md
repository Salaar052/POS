# Local database migrations

## Current version

- **Drift `schemaVersion`:** `7` (`mobile/lib/database/app_database.dart`)
- Bootstrap and per-business SQLite files share this strategy.

## Compatibility decision (v6 → v7)

**Case B applied.** Commit `5549df1` on `origin/dev` shipped **schema v6** with `customer_ledger_entries` **without** `payment_method` or `reference_number`. Any business database created from that build reports `PRAGMA user_version = 6` and omits those columns.

Opening such a file with only a Dart table-definition change (still at schema 6) would **not** run a migration. **v7** adds the columns via `addCustomerLedgerPaymentColumnsIfNeeded()` (checks `PRAGMA table_info` before `ALTER TABLE`, so fresh v7 creates and v5→v6→v7 paths do not duplicate columns).

## Migration sequence

| Version | Phase | What changes |
|--------:|-------|----------------|
| 1 | 2 | Core bootstrap tables, Phase 2 triggers |
| 2 | 4.1 | `installation_profile`, `known_businesses` |
| 3 | 4.7 | Product catalog |
| 4 | 4.8 | Inventory balances and stock movements |
| 5 | 4.9 | Purchasing and supplier ledger |
| 6 | 5.0 | Customers, sales, sale payments, customer ledger (legacy layout), sale returns |
| 7 | 5.0 fix | `customer_ledger_entries.payment_method`, `customer_ledger_entries.reference_number` (nullable) |

Upgrades are additive only (no business-table drops).

## Customer ledger payment metadata

- `payment_method` — `SalePaymentMethod` storage string when `entry_type` is `CUSTOMER_PAYMENT`
- `reference_number` — structured receipt/transfer reference (not stored in `notes`)
- `notes` — free text

Other entry types leave payment metadata null.

## Return rollback

Sale returns run inside `DatabaseRunner.runInTransaction`. Failures during inventory, return rows, or ledger writes roll back the whole return (verified in `sales_repository_integrity_test.dart`).

## Running migration tests

From `mobile/`:

```bash
flutter test test/database/
```

### Fixture upgrade coverage

| Test | Path |
|------|------|
| v1 → current | `schema_v2_migration_test.dart` + `LegacyV1AppDatabase` |
| v5 → current | `schema_v5_to_v6_migration_test.dart` + `LegacyV5AppDatabase` |
| **v6 (shipped) → v7** | `schema_v6_to_v7_migration_test.dart` + `LegacyV6AppDatabase` |

Fresh-provision tests assert latest schema on new databases; they do not replace fixture upgrade tests.

## Fixtures

- `legacy_v1_app_database.dart` — schema 1
- `legacy_v5_app_database.dart` — schema 5 (pre-sales)
- `legacy_v6_app_database.dart` — schema 6 with ledger layout matching `origin/dev` (no payment columns)

## Manual verification

1. Copy a pre-upgrade business `.sqlite` file.
2. Open with current `AppDatabase`.
3. Confirm `PRAGMA user_version` is `7` and ledger rows are intact.
4. Spot-check products, stock, sales, and ledger queries.
