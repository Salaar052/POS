# Sales and customer accounts (Phase 5.0)

Schema **v6** introduced customers, sales, sale items, sale payments, customer ledger, sale returns, and sale return items. **Schema v7** adds nullable `payment_method` and `reference_number` on `customer_ledger_entries` for databases created from the initial v6 release (see `docs/database/migrations.md`).

## Schema relationships

- **customers** — profiles with normalized name/phone for search; archive preserves history.
- **sales** — draft → completed/cancelled lifecycle; monetary fields in integer paisa; optional `customer_id`; internal `sale_number` (`SO-…`) for display only (not fiscal invoicing).
- **sale_items** — historical product snapshots (name, SKU/barcode, unit, price, qty, discounts).
- **sale_payments** — checkout payments tied to a sale with unique `idempotency_key`.
- **customer_ledger_entries** — append-only receivable ledger (see sign convention).
- **sale_returns** / **sale_return_items** — partial or full returns against completed sales.

## Checkout transaction boundary

`SalesRepository.checkout` runs inside a single `DatabaseRunner.runInTransaction`:

1. Validate draft sale and line items.
2. Recompute totals; validate payments (walk-in must be fully paid).
3. Re-check stock on hand per line.
4. Insert `SALE` stock movements via `InventoryRepository.applyMovementInTransaction`.
5. Insert sale payments.
6. For account customers: ledger debit (sale receivable) for sale total, credits for each checkout payment.
7. Mark sale completed with `checkout_idempotency_key`.

Any failure rolls back the entire transaction (no partial sale, stock, payments, or ledger). Checkout payment idempotency keys are resolved before totals are finalized; reusing a key with a different sale, amount, method, reference, or notes is rejected (`SalesConflictCode.idempotencyConflict`).

## Inventory integration

- Uses existing `StockMovementType.sale` (outbound) and `saleReturn` (inbound).
- Reference: `SALE_CHECKOUT` + `{saleId}:{itemId}:{checkoutKey}`; returns use `SALE_RETURN` + `{returnId}:{itemId}`.
- Duplicate checkout with the same idempotency key returns the completed sale without double stock deduction.

## Customer ledger sign convention

**Outstanding receivable = Σ debitMinor − Σ creditMinor** (mirrors supplier payables).

| Entry type        | Debit | Credit | Meaning                          |
|-------------------|-------|--------|----------------------------------|
| SALE_RECEIVABLE   | total | 0      | Credit sale on checkout          |
| CUSTOMER_PAYMENT  | 0     | amount | Cash received (checkout or later)|
| SALE_RETURN       | 0     | amount | Reduce receivable for return     |

Walk-in sales (`customer_id` null) do not write ledger rows. Payments at checkout for account customers are credits; unpaid balance remains as outstanding.

## Walk-in behavior

No customer record required. Checkout **must** receive payments equal to `total_minor`; partial walk-in credit is rejected.

## Price snapshot

Unit selling price is captured on **add to cart** (`addDraftItem`) from `products.selling_price_minor` and stored on `sale_items` for immutable history.

## Returns and refunds

- Only **completed** sales; cumulative returned qty cannot exceed sold qty (duplicate return lines for the same `sale_item` are **aggregated** before validation).
- Return amount is proportional to the original line total snapshot.
- Stock: `SALE_RETURN` movements inside the same transaction as return rows; failures roll back return headers, items, stock movements, and ledger credits together (see `return rollback` tests in `sales_repository_integrity_test.dart`).
- **Financial behavior:** a return records a **`SALE_RETURN` ledger credit** for account customers — it reduces outstanding receivable or increases customer credit (negative receivable). This is **not** a cash/card/bank refund unless a separate refund payment workflow is added later.
- Walk-in returns adjust stock only; no customer ledger rows are written.
- Fully paid account sales: a return credits the ledger (customer may show negative outstanding = store credit), without reversing `sale_payments` rows.

## Idempotency

- `sales.checkout_idempotency_key` — unique when set; retries return the same completed sale.
- `sale_payments.idempotency_key` — globally unique; existing rows must match sale, amount, method, reference, and notes or checkout fails.
- `sale_returns.idempotency_key` — existing return must match sale, reason, and aggregated line quantities.
- `customer_ledger_entries` — unique on `(reference_type, reference_id, entry_type)`; customer payment retries validate full payload including method and reference.

**Concurrency:** SQLite serializes writers; checkout/return/payment logic relies on single-database transactions plus movement and idempotency references. Parallel isolate/process checkout is not explicitly stress-tested; overselling the same stock from two simultaneous writers would require additional coordination beyond sequential unit tests.

## Migration

Non-destructive **v5 → v6** adds sales tables; **v6 → v7** adds ledger payment metadata columns on databases shipped without them (`schema_migration_helpers.dart`).

## Known limitations

- No receipt printing, invoice numbering, server sync, or payment gateways (Phase 5.1+).
- Customer payments reduce **overall** outstanding balance, not specific invoices.
- No separate cash refund transaction on returns (ledger credit only).
- POS UI supports basic cash checkout; mixed tender at checkout is API-ready but minimally exposed in UI.
