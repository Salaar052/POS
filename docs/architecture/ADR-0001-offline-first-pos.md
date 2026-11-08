# ADR-0001: Offline-First POS Architecture

**Status:** Accepted (Phase 0, revised)  
**Date:** 2026-11-09

## Context

Pak POS must complete sales and billing without internet. Cloud services provide sync, backup, and multi-device consistency—not checkout availability.

## Environment baseline (verified)

| Component | Version / state |
|-----------|------------------|
| Flutter | 3.47.9 (stable) |
| Dart | 3.13.7 |
| OS | Windows 11 |
| Android SDK | 36.0.0, licenses accepted |
| Visual Studio | Community 2026, Windows workload ready |
| `flutter doctor` | No issues found |

## Decisions

### D1 — Local-first operational data

SQLite on device is the runtime system of record. All ordinary checkout, stock movements, ledger, and local reports complete without cloud API or sync.

### D2 — Cloud sync is orthogonal (Phase 10)

Synchronization is a reliable background concern. Local sales never depend on upload success. Phase 10 delivers the sync engine; Phases 1–9 build full local POS capability first.

### D3 — Early local backup (before full sync)

Phase 11 delivers full backup/restore UX, but **basic local export** (database/CSV/JSON with schema version and checksum) is required **no later than Phase 6** (after sales exist) so shops can protect data without cloud.

### D4 — Perpetual inventory accounting

- **Credit purchase:** Dr Inventory, Cr Accounts Payable.
- **COGS:** recognized at sale (Dr COGS, Cr Inventory), not at purchase.
- **Cash purchase:** Dr Inventory, Cr Cash/Bank.

### D5 — Immutable financial operations offline

Sales, payments, refunds, stock movements, ledger entries, and posted journals are append-only locally. Corrections use compensating transactions only.

### D6 — Server-rejected financial operations (reconciliation)

If the server rejects a previously committed local financial operation:

1. **Never** delete or silently rewrite the local transaction.
2. Mark sync state as `reconciliation_required` with server reason codes.
3. Surface in a **Reconciliation** workflow (manager/owner): retry after fix, attach explanation, or create compensating entries per policy.
4. Operational reporting continues from local truth; cloud totals may diverge until resolved.

### D7 — Tenancy from authenticated context

`businessId` for authorization and queries is derived from the validated access token / device credential on the server. Client-supplied `businessId` is ignored for authZ (may be used as a consistency hint only after match).

### D8 — Offline authorization validity

Default **7 days** from last successful online session validation, configurable via business security policy (shorter allowed; longer requires explicit owner risk acceptance).

**Revocation while offline:** Server revocation does not reach the device until connectivity returns. During offline window, a revoked device may still operate within cached credentials until expiry or failed sync. Mitigations: short offline TTL, mandatory periodic online check for sensitive actions, immediate local session wipe after first successful post-revocation sync.

### D9 — Sync dependency ordering

Operations upload in **dependency order** within a batch:

1. Master data: categories → products → variants → customers → suppliers.
2. Movements and documents referencing masters: stock movements, purchases, sales, payments, ledger, journals.

**Recovery:** If a child operation references a parent not yet on server:

- Client keeps parent `pending` and blocks child from `in_flight` until parent is `acknowledged`, or
- Client sends explicit `dependsOn: [operationId]`; server returns `409 DEPENDENCY_PENDING`; child retries with backoff.

Server idempotency keys remain `operationId` per business.

### D10 — Multi-device stock

Quantity derived from movement history; negative stock flagged; offline sales are never discarded for oversell conflicts.

## Consequences

- Larger local schema and test surface before cloud sync ships.
- Reconciliation UI is mandatory for enterprise trust.
- Server API must expose structured reject reasons and dependency status.
