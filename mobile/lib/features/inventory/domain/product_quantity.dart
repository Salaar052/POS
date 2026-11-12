import 'package:pos_mobile/features/catalog/domain/catalog_normalization.dart';

/// Quantities stored as integers in the product unit's base scale (see [unitQuantityScale]).
abstract final class ProductQuantity {
  static int unitQuantityScale(String unit) {
    switch (unit) {
      case 'kg':
      case 'liter':
      case 'metre':
        return 3;
      case 'each':
      case 'pack':
      case 'box':
      case 'g':
      case 'ml':
        return 0;
      default:
        throw CatalogValidationException('Unknown unit: $unit');
    }
  }

  static bool allowsFractions(String unit) => unitQuantityScale(unit) > 0;

  static int parseToBase(String raw, String unit) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      throw const CatalogValidationException('Quantity is required');
    }
    final scale = unitQuantityScale(unit);
    if (scale == 0) {
      final match = RegExp(r'^\d+$').firstMatch(trimmed);
      if (match == null) {
        throw CatalogValidationException('Enter a whole number for $unit');
      }
      final value = int.parse(match.group(0)!);
      if (value <= 0) {
        throw const CatalogValidationException(
          'Quantity must be greater than zero',
        );
      }
      return value;
    }
    final match = RegExp(r'^(\d+)(?:\.(\d{1,3}))?$').firstMatch(trimmed);
    if (match == null) {
      throw CatalogValidationException(
        'Enter a valid quantity (up to 3 decimal places)',
      );
    }
    final whole = int.parse(match.group(1)!);
    final fraction = (match.group(2) ?? '').padRight(scale, '0');
    if (fraction.length > scale) {
      throw CatalogValidationException(
        'Enter a valid quantity (up to 3 decimal places)',
      );
    }
    final base = whole * _pow10(scale) + int.parse(fraction);
    if (base <= 0) {
      throw const CatalogValidationException(
        'Quantity must be greater than zero',
      );
    }
    return base;
  }

  static String formatFromBase(int base, String unit) {
    if (base < 0) {
      throw const CatalogValidationException('Quantity cannot be negative');
    }
    final scale = unitQuantityScale(unit);
    if (scale == 0) {
      return base.toString();
    }
    final divisor = _pow10(scale);
    final whole = base ~/ divisor;
    final fraction = base % divisor;
    return '$whole.${fraction.toString().padLeft(scale, '0')}';
  }

  static int _pow10(int exp) {
    var value = 1;
    for (var i = 0; i < exp; i++) {
      value *= 10;
    }
    return value;
  }
}
