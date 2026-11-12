# Supplier & purchasing (Phase 4.9)

## Authority

All supplier, purchase, payment, return and ledger data lives in the **per-business SQLite** file (schema v5). Server APIs and sync are deferred.

## Purchase lifecycle

| Status | Stock | Supplier ledger |
|--------|-------|-----------------|
| `DRAFT` | No effect | No effect |
| `RECEIVED` | `PURCHASE_RECEIVED` per line | `PURCHASE_PAYABLE` debit |
| `CANCELLED` | No effect | No effect |

**Receiving is full-receipt only** in this phase (no partial receiving).

## Receiving transaction (atomic)

1. Validate draft + items.
2. For each line: `InventoryRepository.applyMovementInTransaction` with `reference_type=PURCHASE_RECEIVE`, `reference_id={purchaseId}:{itemId}:{receiveKey}`.
3. If `supplierId` present: ledger `PURCHASE_PAYABLE` (debit = total).
4. Mark purchase `RECEIVED`, store `receiveIdempotencyKey`.

Duplicate receive with the same key returns the existing result; a second key on an already received purchase is rejected.

## Supplier ledger convention

**Outstanding payable = Σ debitMinor − Σ creditMinor**

| Entry | Debit | Credit |
|-------|-------|--------|
| `PURCHASE_PAYABLE` | purchase total | 0 |
| `PAYMENT` | 0 | payment amount |
| `PURCHASE_RETURN` | 0 | return total |

## Payments

- Recorded against **received** purchases with a supplier.
- Duplicate payments blocked via `purchase_payments.idempotency_key` and ledger reference.
- Overpayment rejected (no advance balance in this phase).

## Purchase returns

- Only against **received** purchases with a supplier.
- Eligible qty = `quantityReceivedBase − quantityReturnedBase`.
- Creates `PURCHASE_RETURN` stock movements and ledger credit atomically.

## Offline

No network required for any workflow in this phase.

## Future sync

Stable UUIDs on purchases, items, movements and ledger rows are suitable sync keys when server purchasing is added later.
