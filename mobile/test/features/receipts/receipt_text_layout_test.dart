import 'package:flutter_test/flutter_test.dart';
import 'package:pos_mobile/features/receipts/domain/receipt_enums.dart';
import 'package:pos_mobile/features/receipts/domain/receipt_models.dart';
import 'package:pos_mobile/features/receipts/domain/receipt_text_layout.dart';
import 'package:pos_mobile/features/sales/domain/sales_enums.dart';

void main() {
  const business = ReceiptBusinessHeader(
    displayName: 'Test Shop',
    currencyDisplay: 'PKR',
  );

  final sale = SaleReceiptDocument(
    invoiceNumber: 'INV-2026-000001',
    saleNumber: 'SO-000001',
    completedAtMs: DateTime.utc(2026, 1, 2, 10, 30).millisecondsSinceEpoch,
    lines: const [
      SaleReceiptLine(
        description: 'Very long product name that should wrap on narrow paper',
        quantityBase: 2,
        unitPriceMinor: 15050,
        discountMinor: 100,
        lineTotalMinor: 30000,
        unitLabel: 'pc',
      ),
    ],
    payments: const [
      SaleReceiptPaymentLine(
        method: SalePaymentMethod.cash,
        amountMinor: 25000,
      ),
    ],
    subtotalMinor: 30100,
    saleDiscountMinor: 100,
    totalMinor: 30000,
    amountPaidMinor: 25000,
    amountDueMinor: 5000,
    customerName: 'Customer With A Long Name',
  );

  test('58mm layout respects character width', () {
    final lines = ReceiptTextLayout.buildSaleReceipt(
      business: business,
      sale: sale,
      options: const ReceiptRenderOptions(
        paperWidth: ReceiptPaperWidth.mm58,
        showCustomerDetails: true,
        showPaymentBreakdown: true,
        showItemSku: false,
      ),
    );
    final width = ReceiptTextLayout.charsPerLine(ReceiptPaperWidth.mm58);
    for (final line in lines) {
      expect(line.length, lessThanOrEqualTo(width));
    }
    expect(lines.any((l) => l.contains('INV-2026-000001')), isTrue);
    expect(lines.any((l) => l.contains('Balance due')), isTrue);
  });

  test('80mm layout is wider', () {
    expect(
      ReceiptTextLayout.charsPerLine(ReceiptPaperWidth.mm80),
      greaterThan(ReceiptTextLayout.charsPerLine(ReceiptPaperWidth.mm58)),
    );
  });
}
