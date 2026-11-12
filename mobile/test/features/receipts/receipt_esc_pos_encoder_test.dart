import 'package:flutter_test/flutter_test.dart';
import 'package:pos_mobile/features/receipts/domain/receipt_enums.dart';
import 'package:pos_mobile/features/receipts/domain/receipt_esc_pos_encoder.dart';
import 'package:pos_mobile/features/receipts/domain/receipt_models.dart';
import 'package:pos_mobile/features/sales/domain/sales_enums.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'sale ESC/POS bytes include reset and ASCII-safe product name',
    () async {
      const business = ReceiptBusinessHeader(
        displayName: 'Shop',
        currencyDisplay: 'PKR',
      );
      final sale = SaleReceiptDocument(
        invoiceNumber: 'INV-2026-000001',
        saleNumber: 'SO-1',
        completedAtMs: 1,
        lines: const [
          SaleReceiptLine(
            description: 'Widget',
            quantityBase: 1,
            unitPriceMinor: 10000,
            discountMinor: 0,
            lineTotalMinor: 10000,
            unitLabel: 'pc',
          ),
        ],
        payments: const [
          SaleReceiptPaymentLine(
            method: SalePaymentMethod.cash,
            amountMinor: 10000,
          ),
        ],
        subtotalMinor: 10000,
        saleDiscountMinor: 0,
        totalMinor: 10000,
        amountPaidMinor: 10000,
        amountDueMinor: 0,
      );
      final bytes58 = await ReceiptEscPosEncoder.encodeSale(
        business: business,
        sale: sale,
        options: const ReceiptRenderOptions(
          paperWidth: ReceiptPaperWidth.mm58,
          showCustomerDetails: true,
          showPaymentBreakdown: true,
          showItemSku: false,
        ),
      );
      final bytes80 = await ReceiptEscPosEncoder.encodeSale(
        business: business,
        sale: sale,
        options: const ReceiptRenderOptions(
          paperWidth: ReceiptPaperWidth.mm80,
          showCustomerDetails: true,
          showPaymentBreakdown: true,
          showItemSku: false,
        ),
      );
      expect(bytes58, isNotEmpty);
      expect(bytes80.length, greaterThan(bytes58.length ~/ 2));
      expect(bytes58[0], 0x1B); // ESC
      final text = String.fromCharCodes(
        bytes58.where((b) => b >= 32 && b <= 126),
      );
      expect(text, contains('INV-2026-000001'));
      expect(text, contains('Widget'));
    },
  );

  test('non-ASCII characters are replaced for CP437 output', () async {
    const business = ReceiptBusinessHeader(
      displayName: 'Test',
      currencyDisplay: 'PKR',
    );
    final sale = SaleReceiptDocument(
      invoiceNumber: 'INV-1',
      saleNumber: 'SO-1',
      completedAtMs: 1,
      lines: const [
        SaleReceiptLine(
          description: 'Urdu: \u0645',
          quantityBase: 1,
          unitPriceMinor: 100,
          discountMinor: 0,
          lineTotalMinor: 100,
          unitLabel: 'pc',
        ),
      ],
      payments: const [],
      subtotalMinor: 100,
      saleDiscountMinor: 0,
      totalMinor: 100,
      amountPaidMinor: 100,
      amountDueMinor: 0,
    );
    final bytes = await ReceiptEscPosEncoder.encodeSale(
      business: business,
      sale: sale,
      options: const ReceiptRenderOptions(
        paperWidth: ReceiptPaperWidth.mm58,
        showCustomerDetails: false,
        showPaymentBreakdown: false,
        showItemSku: false,
      ),
    );
    final text = String.fromCharCodes(bytes.where((b) => b >= 32 && b <= 126));
    expect(text, contains('?'));
    expect(text, isNot(contains('\u0645')));
  });
}
