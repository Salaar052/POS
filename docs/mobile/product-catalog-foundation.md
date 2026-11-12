# Product catalog foundation (Phase 4.7)

## Authority

The **per-business SQLite file** (`business_<uuid>.sqlite`) is the authoritative catalog store for products and categories. The bootstrap `local.sqlite` registry never holds catalog rows.

Server-side product models are **deferred**. NestJS continues to handle identity and session authentication only.

## Future synchronization boundary

When multi-device sync arrives:

- Catalog writes append to `sync_operations` (existing infrastructure) with entity types `Product` and `ProductCategory`.
- Conflict resolution must remain **scoped by `businessId`** on the server; local files already enforce single-tenant isolation via separate database files.
- Monetary fields stay as **integer minor units** end-to-end through sync payloads (no floats).
- Stock quantities and movements are **out of scope** for this phase and must not be inferred from catalog tables.
