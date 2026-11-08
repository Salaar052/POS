# Phase dependency list

Phases are sequential unless noted. **Sync (10)** and **full backup (11)** must not block local POS (Phases 5–6).

```text
Phase 1  ──► monorepo, Flutter shell, NestJS health, Prisma empty schema
Phase 2  ──► Drift schema + migrations (depends 1)
Phase 3  ──► App shell, router, themes (depends 1, 2 lightweight)
Phase 4  ──► Auth + device activation (depends 2, 3)
Phase 5  ──► Products, inventory, movements (depends 4)
Phase 6  ──► POS, sales, receipts (depends 5)
           └──► **Basic local export** (minimum backup; depends 6)
Phase 7  ──► Customers, ledger, suppliers (depends 6)
Phase 8  ──► Purchases, expenses (depends 5, 7)
Phase 9  ──► Accounting + local reports (depends 6–8; uses D4 perpetual inventory)
Phase 10 ──► Cloud API + sync engine + reconciliation (depends 4, 9 data model; **not** required for 6)
Phase 11 ──► Full backup/restore + cloud backup strategy (depends 6 local export, 10 optional for cloud)
Phase 12 ──► Printing hardware (depends 6)
Phase 13 ──► Security review + offline/sync tests (depends 10 if present)
Phase 14 ──► Deployment + docs (depends 13)
```

## Parallelization notes

| After | Can start in parallel |
|-------|------------------------|
| Phase 6 | Phase 7 and basic export |
| Phase 9 | Phase 10 and Phase 12 (printing) |
| Phase 6 without 10 | Full shop operation offline indefinitely |

## MVP without sync

Phases **1–6 + 9 (daily sales reports only) + basic export** = pilot-ready single-device shop. Add **10** for multi-device and cloud backup.
