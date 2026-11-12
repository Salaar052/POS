# Receipts and thermal printing (Phase 5.1 + 5.2)

Offline-first receipts, invoice numbering, and printing for the Pak POS mobile client.

## Invoice numbering (5.1)

Unchanged from Phase 5.1 — see schema v8, `INV-YYYY-######` at checkout, legacy `INV-LEG-{sale_number}`.

## Receipt rendering

- **Shared content:** `ReceiptTextLayout` → used by both PDF (`ReceiptPdfBuilder`) and ESC/POS (`ReceiptEscPosEncoder`).
- **Widths:** 58 mm and 80 mm.
- **Money:** Integer paisa via `MoneyAmount`.
- **Encoding (ESC/POS):** CP437, ASCII-safe substitution (`?` for unsupported code points). **Urdu/Unicode not validated on hardware.**

## Printer architecture (5.2)

| Layer | Role |
|--------|------|
| `ThermalPrinterService` | Discovery, connect, `printPdf` / `printEscPos` |
| `CompositeThermalPrinterService` | Routes PDF vs native transports |
| `SystemQueuePrinterService` | OS print dialog (`printing`) |
| `WindowsRawEscPosDevice` | RAW jobs via Win32 spooler |
| `WindowsSerialEscPosDevice` | COM ports (`flutter_libserialport`) |
| `BluetoothEscPosDevice` | Bluetooth Classic (`print_bluetooth_thermal`) |
| `ReceiptEscPosEncoder` | ESC/POS bytes (`esc_pos_utils_plus`) |
| `ReceiptPrintService` | Same sale data → PDF or ESC/POS by active transport |
| `FakeThermalPrinterService` | Tests |

**Printing remains outside checkout.**

## Output channel selection

| `PrinterConnectionType` | Output |
|-------------------------|--------|
| `SYSTEM_QUEUE` | PDF via system dialog |
| `WINDOWS_RAW_QUEUE` | ESC/POS RAW to named queue |
| `WINDOWS_SERIAL` | ESC/POS to COM port |
| `BLUETOOTH_CLASSIC` | ESC/POS over Bluetooth |
| `ANDROID_USB_OTG` | Reserved — **not implemented** |

`forceSystemPdf` on print APIs overrides native path for explicit PDF fallback.

## Supported platforms and transports

| Platform | Transport | Status |
|----------|-----------|--------|
| Windows | System PDF (`printing`) | Implemented (5.1) |
| Windows | RAW queue ESC/POS (`win32` WritePrinter RAW) | Implemented; **not hardware-tested in CI** |
| Windows | Serial COM ESC/POS (`dart:io` → `\\.\COMx`) | Implemented; **not hardware-tested in CI** |
| Windows | Bluetooth paired (`print_bluetooth_thermal`) | Implemented; **not hardware-tested in CI** |
| Android | System PDF | Implemented (5.1) |
| Android | Bluetooth Classic ESC/POS | Implemented; permissions declared; **not hardware-tested in CI** |
| Android | USB OTG ESC/POS | **Not supported** |
| Either | BLE ESC/POS | **Not supported** |

### Hardware investigation (this phase, read-only)

Observed on the dev machine (no test print fired):

- Windows queue **POS58 Printer** → `USB001`, driver `POS58ENG` (58 mm class).
- COM ports: **COM3, COM4, COM5, COM6** present.
- Historical **pt210_947B** / COM4 not confirmed; not found by name in the printer list.
- ESC/POS compatibility for POS58/COM devices is **assumed** pending operator validation.

## Dependencies

| Package | Version (pubspec) | Use |
|---------|-------------------|-----|
| `printing` | 5.15.1 | System PDF |
| `pdf` | 3.13.1 | Roll PDF |
| `esc_pos_utils_plus` | 2.0.4 | ESC/POS encoding |
| `win32` | 6.4.0 | Windows RAW print |
| `ffi` | 2.2.0 | Win32 interop |
| `print_bluetooth_thermal` | 1.2.5 | Bluetooth bytes |

## ESC/POS capabilities

**Implemented (encoder):** reset, CP437 table, text, bold (titles/totals), line feeds, paper feed.

**Not sent (unless validated on hardware):** full/partial cut, cash drawer kick, raster logo, barcode/QR, Urdu glyphs.

## Android permissions

Declared in manifest: `BLUETOOTH_CONNECT`, `BLUETOOTH_SCAN` (neverForLocation). Runtime: requested by `print_bluetooth_thermal` when discovering/connecting Bluetooth.

## Windows setup

- **RAW queue:** Install thermal driver; select queue name from discovery (e.g. POS58). Driver must accept RAW datatype.
- **Serial:** Pair USB/Bluetooth as COM in Device Manager; connect via COM discovery or manual `COMx`.
- **Bluetooth:** Pair in Windows Settings; use Bluetooth transport discovery (MAC from paired list).

## Failure handling

- Checkout independent of print.
- No automatic retry on `UNKNOWN`.
- Operator may **Retry** or **Use PDF** from POS UI.
- Print attempts logged in `print_attempts` (unchanged schema v8).

## Testing

| Area | Level |
|------|--------|
| ESC/POS byte layout, ASCII, 58/80 | Unit-tested |
| Composite transport routing | Unit-tested |
| PDF path | Unit-tested (5.1) |
| Windows/Android debug builds | Build-tested |
| POS58 / COM / Bluetooth physical print | **Pending operator** |
