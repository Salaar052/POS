# Sales and customer accounts (Phase 5.0)

Schema **v6** adds customers, sales, sale items, sale payments, customer ledger, sale returns, and sale return items to each per-business SQLite database.

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

Any failure rolls back the entire transaction (no partial sale, stock, payments, or ledger).

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

- Only **completed** sales; cumulative returned qty cannot exceed sold qty.
- Return amount is proportional to the original line total snapshot.
- Stock: `SALE_RETURN` movements inside the same transaction as return rows.
- Account customers: `SALE_RETURN` ledger credit reduces receivable; cash refunds are not auto-recorded (credit balance only unless a separate refund payment is added later).

## Idempotency

- `sales.checkout_idempotency_key` — unique when set; retries return the same completed sale.
- `sale_payments.idempotency_key` — unique per payment row.
- `sale_returns.idempotency_key` — unique per return.
- `customer_ledger_entries` — unique on `(reference_type, reference_id, entry_type)`.

## Migration

Non-destructive **v5 → v6** adds sales tables and indexes via `applySalesIndexes`; catalog, inventory, and purchasing data are untouched.

## Known limitations

- No receipt printing, invoice numbering, server sync, or payment gateways (Phase 5.1+).
- Customer payments reduce **overall** outstanding balance, not specific invoices.
- No separate cash refund transaction on returns (ledger credit only).
- POS UI supports basic cash checkout; mixed tender at checkout is API-ready but minimally exposed in UI.
