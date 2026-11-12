# Inventory architecture (Phase 4.8)

## Authority

Stock levels are **never** stored on `products`. Each business SQLite file holds:

- `inventory_balances` — current `quantity_on_hand_base` and optional `minimum_stock_base`
- `stock_movements` — immutable ledger rows with previous/resulting balances

## Quantity representation

- Count units (`each`, `pack`, `box`, `g`, `ml`): integer base (scale 0).
- Fractional units (`kg`, `liter`, `metre`): integer milli-units (scale 3), e.g. `1.500 kg` → `1500`.

Parsing/formatting: `ProductQuantity`.

## Movement rules

- Quantity on each movement is **positive**; direction comes from `movement_type`.
- Balance updates and movement insert are **one SQLite transaction**.
- Duplicate source application is blocked via `(reference_type, reference_id, product_id, movement_type)` unique index and idempotency keys for manual operations.
- **Negative stock** is rejected unless a future business policy enables it.
- Corrections use compensating movements (`reverseMovement`), not deletes.

## Future sync

Movement and balance rows use stable UUIDs. Purchases/sales (later phases) should reference movements with typed `reference_type` / `reference_id` for idempotent receive/checkout.
