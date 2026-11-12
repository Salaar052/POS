import 'package:pos_mobile/features/catalog/domain/money_amount.dart';
import 'package:pos_mobile/features/inventory/domain/product_quantity.dart';
import 'package:pos_mobile/features/purchasing/domain/purchasing_enums.dart';

/// Deterministic purchase totals in integer paisa.
abstract final class PurchaseCalculations {
  /// [unitCostMinor] is per display unit (per kg, per each, etc.).
  static int lineSubtotalMinor({
    required int quantityBase,
    required int unitCostMinor,
    required String unit,
  }) {
    assert(quantityBase > 0);
    MoneyAmount.assertNonNegativeMinor(unitCostMinor);
    final scale = ProductQuantity.unitQuantityScale(unit);
    if (scale == 0) {
      return quantityBase * unitCostMinor;
    }
    return (quantityBase * unitCostMinor) ~/ _pow10(scale);
  }

  static int _pow10(int exp) {
    var v = 1;
    for (var i = 0; i < exp; i++) {
      v *= 10;
    }
    return v;
  }

  static int lineTotalMinor({
    required int lineSubtotalMinor,
    required int discountMinor,
    required int taxMinor,
  }) {
    MoneyAmount.assertNonNegativeMinor(lineSubtotalMinor);
    MoneyAmount.assertNonNegativeMinor(discountMinor);
    MoneyAmount.assertNonNegativeMinor(taxMinor);
    if (discountMinor > lineSubtotalMinor) {
      throw const PurchaseCalculationException(
        'Line discount cannot exceed line subtotal',
      );
    }
    return lineSubtotalMinor - discountMinor + taxMinor;
  }

  static PurchaseTotals purchaseTotals({
    required Iterable<int> lineTotalsMinor,
    required int purchaseDiscountMinor,
    required int purchaseTaxMinor,
    required int additionalChargesMinor,
  }) {
    var subtotal = 0;
    for (final line in lineTotalsMinor) {
      subtotal += line;
    }
    MoneyAmount.assertNonNegativeMinor(subtotal);
    MoneyAmount.assertNonNegativeMinor(purchaseDiscountMinor);
    MoneyAmount.assertNonNegativeMinor(purchaseTaxMinor);
    MoneyAmount.assertNonNegativeMinor(additionalChargesMinor);
    if (purchaseDiscountMinor > subtotal) {
      throw const PurchaseCalculationException(
        'Purchase discount cannot exceed subtotal',
      );
    }
    final total =
        subtotal -
        purchaseDiscountMinor +
        purchaseTaxMinor +
        additionalChargesMinor;
    return PurchaseTotals(
      subtotalMinor: subtotal,
      discountMinor: purchaseDiscountMinor,
      taxMinor: purchaseTaxMinor,
      additionalChargesMinor: additionalChargesMinor,
      totalMinor: total,
    );
  }

  static PurchasePaymentStatus paymentStatus({
    required int totalMinor,
    required int amountPaidMinor,
  }) {
    MoneyAmount.assertNonNegativeMinor(totalMinor);
    MoneyAmount.assertNonNegativeMinor(amountPaidMinor);
    if (amountPaidMinor <= 0) {
      return PurchasePaymentStatus.unpaid;
    }
    if (amountPaidMinor >= totalMinor) {
      return PurchasePaymentStatus.paid;
    }
    return PurchasePaymentStatus.partial;
  }
}

class PurchaseTotals {
  const PurchaseTotals({
    required this.subtotalMinor,
    required this.discountMinor,
    required this.taxMinor,
    required this.additionalChargesMinor,
    required this.totalMinor,
  });

  final int subtotalMinor;
  final int discountMinor;
  final int taxMinor;
  final int additionalChargesMinor;
  final int totalMinor;
}

class PurchaseCalculationException implements Exception {
  const PurchaseCalculationException(this.message);
  final String message;
  @override
  String toString() => message;
}
