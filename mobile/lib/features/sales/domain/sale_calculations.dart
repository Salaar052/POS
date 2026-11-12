import 'package:pos_mobile/features/catalog/domain/money_amount.dart';
import 'package:pos_mobile/features/inventory/domain/product_quantity.dart';

/// Integer paisa sale totals (no floating point).
abstract final class SaleCalculations {
  static int lineSubtotalMinor({
    required int quantityBase,
    required int unitPriceMinor,
    required String unit,
  }) {
    return PurchaseLineSubtotal.quantityTimesPrice(
      quantityBase: quantityBase,
      unitPriceMinor: unitPriceMinor,
      unit: unit,
    );
  }

  static int lineTotalMinor({
    required int lineSubtotalMinor,
    required int discountMinor,
  }) {
    MoneyAmount.assertNonNegativeMinor(lineSubtotalMinor);
    MoneyAmount.assertNonNegativeMinor(discountMinor);
    if (discountMinor > lineSubtotalMinor) {
      throw const SaleCalculationException(
        'Line discount cannot exceed line subtotal',
      );
    }
    return lineSubtotalMinor - discountMinor;
  }

  static SaleTotals saleTotals({
    required Iterable<int> lineTotalsMinor,
    required int saleDiscountMinor,
  }) {
    var subtotal = 0;
    for (final line in lineTotalsMinor) {
      subtotal += line;
    }
    MoneyAmount.assertNonNegativeMinor(subtotal);
    MoneyAmount.assertNonNegativeMinor(saleDiscountMinor);
    if (saleDiscountMinor > subtotal) {
      throw const SaleCalculationException(
        'Sale discount cannot exceed subtotal',
      );
    }
    return SaleTotals(
      subtotalMinor: subtotal,
      discountMinor: saleDiscountMinor,
      totalMinor: subtotal - saleDiscountMinor,
    );
  }
}

class SaleTotals {
  const SaleTotals({
    required this.subtotalMinor,
    required this.discountMinor,
    required this.totalMinor,
  });

  final int subtotalMinor;
  final int discountMinor;
  final int totalMinor;
}

class SaleCalculationException implements Exception {
  const SaleCalculationException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Shared qty×price helper (matches purchase semantics).
abstract final class PurchaseLineSubtotal {
  static int quantityTimesPrice({
    required int quantityBase,
    required int unitPriceMinor,
    required String unit,
  }) {
    assert(quantityBase > 0);
    MoneyAmount.assertNonNegativeMinor(unitPriceMinor);
    final scale = ProductQuantity.unitQuantityScale(unit);
    if (scale == 0) {
      return quantityBase * unitPriceMinor;
    }
    return (quantityBase * unitPriceMinor) ~/ _pow10(scale);
  }

  static int _pow10(int exp) {
    var v = 1;
    for (var i = 0; i < exp; i++) {
      v *= 10;
    }
    return v;
  }
}
