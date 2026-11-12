# Phase 6 — Reporting (offline-first)

All metrics read from the **active business SQLite database** via `ReportingRepository` and `databaseRunnerProvider`. The bootstrap database is never used for reports (`CatalogAccessGate` on dashboard/reports).

## Timezone

Pakistan business days use `Asia/Karachi` (UTC+05:00, no DST) via `PakistanTime` and `ReportPeriod`.

## Monetary definitions

Documented in `ReportingDefinitions` and enforced in SQL aggregations (integer minor units / paisa).

- **COGS, gross profit, expenses, net profit:** deferred — sale items have no historical cost snapshot; no expense module.
- **Inventory valuation:** current `cost_price_minor × quantity_on_hand_base` (indicative, not COGS).

## UI

- **Dashboard:** period chips, sales/purchase/inventory/financial cards, charts (`fl_chart`), top products.
- **Reports:** tabbed sales, purchases, inventory, and account balances with per-party ledger history (debit/credit, running balance within period).
- **Charts:** `DailyTrendBarChart` for sales and purchase daily series (separate titles/semantics).
