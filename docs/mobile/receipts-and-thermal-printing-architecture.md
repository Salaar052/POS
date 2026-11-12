# Receipts and thermal printing (Phase 5.1)

Offline-first receipts, invoice numbering, and system-queue printing for the Pak POS mobile client.

## Invoice numbering

- **When assigned:** Only when a draft sale is checked out (atomically inside the same SQLite transaction as stock, payments, and ledger writes).
- **Format:** `{prefix}-{UTC year}-{6-digit sequence}` (default prefix `INV`, e.g. `INV-2026-000001`).
- **Year segment:** Informational only; the underlying `INVOICE` document sequence **does not reset** when the calendar year changes.
- **Uniqueness:** Partial unique index on `sales.invoice_number` (non-null values).
- **Drafts / cancelled sales:** Do not consume invoice numbers.
- **Reprints:** Use the stored invoice number; no re-allocation.
- **Legacy sales (pre-5.1):** Migration v8 sets `INV-LEG-{sale_number}` for completed rows with null invoice numbers.

Configurable per business database via `receipt_settings.invoice_prefix` and `invoice_sequence_start` (applies only before the first `INVOICE` sequence row exists).

## Receipt rendering

- **Source data:** Immutable sale line snapshots (`product_name_snapshot`, prices, quantities), sale totals, payment rows, and receipt settings — not live catalog prices.
- **Engine:** `ReceiptTextLayout` (character-width layout) → `ReceiptPdfBuilder` (roll PDF via `pdf` package).
- **Widths:** 58 mm (~32 chars) and 80 mm (~48 chars).
- **Money:** Integer paisa via `MoneyAmount`.
- **Returns:** Separate layout; account credit is labeled as credit, not cash refund unless a real refund payment exists (returns currently credit ledger only).

## Printer architecture

| Layer | Role |
|--------|------|
| `ThermalPrinterService` | Discovery, connection state, print |
| `SystemQueuePrinterService` | OS print dialog (`printing` package) |
| `FakeThermalPrinterService` | Unit/widget tests |
| `ReceiptPrintService` | Build PDF, invoke transport, log attempts |
| `PrintAttemptRepository` | Local audit (not financial) |

**Printing is never part of the checkout transaction.**

## Supported platforms and transports

| Platform | Transport | Status |
|----------|-----------|--------|
| Windows | System print spooler via PDF (`Printing.layoutPdf`) | Implemented; not hardware-tested in CI |
| Android | Android print framework via PDF | Implemented; not hardware-tested in CI |
| Windows | Raw ESC/POS, USB direct, Bluetooth COM | **Not supported** |
| Android | Bluetooth Classic / BLE / USB OTG ESC/POS | **Not supported** |

### Historical hardware notes (pt210_947B, COM4, USB on Windows 11)

These were operator observations only. This phase does **not** include driver installation, COM pairing, or ESC/POS validation for that device.

## Dependencies

- `printing` 5.15.1 — system print UI, `listPrinters` where available
- `pdf` 3.13.1 — roll-format receipt PDF

## Schema (v8)

- `sales.invoice_number` (nullable text)
- `receipt_settings` (singleton row per business DB)
- `print_attempts` (audit log)

## Failure handling

- Checkout success is independent of print success.
- Ambiguous outcomes (`UNKNOWN`) are reported honestly; operators may retry manually (no automatic duplicate prints).
- Reprint does not alter sale timestamps, stock, payments, or ledger.

## Windows / Android setup

- **Windows:** Choose the thermal printer in the system print dialog; driver must be installed by the operator.
- **Android:** Use the system print sheet; Bluetooth/USB thermal paths require future ESC/POS work and permissions.

## Testing

- Unit tests: invoice allocation, text layout, fake printer, v7→v8 migration backfill.
- No automated test requires physical hardware.
