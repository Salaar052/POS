import 'package:pos_mobile/features/catalog/domain/catalog_normalization.dart';

/// PKR amounts stored as minor units (paisa) — never use floating point for money.
abstract final class MoneyAmount {
  static const int scale = 2;

  static int parsePkrToMinor(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      throw const CatalogValidationException('Price is required');
    }
    final match = RegExp(r'^(\d+)(?:\.(\d{1,2}))?$').firstMatch(trimmed);
    if (match == null) {
      throw const CatalogValidationException(
        'Enter a valid price (up to 2 decimal places)',
      );
    }
    final major = int.parse(match.group(1)!);
    final fraction = (match.group(2) ?? '').padRight(scale, '0');
    if (fraction.length > scale) {
      throw const CatalogValidationException(
        'Enter a valid price (up to 2 decimal places)',
      );
    }
    final minor = int.parse(fraction);
    final total = major * _multiplier + minor;
    if (total < 0) {
      throw const CatalogValidationException('Price cannot be negative');
    }
    return total;
  }

  static void assertNonNegativeMinor(int minor) {
    if (minor < 0) {
      throw const CatalogValidationException('Price cannot be negative');
    }
  }

  static String formatPkrFromMinor(int minor) {
    assertNonNegativeMinor(minor);
    final major = minor ~/ _multiplier;
    final fraction = minor % _multiplier;
    return '$major.${fraction.toString().padLeft(scale, '0')}';
  }

  static int get _multiplier {
    var value = 1;
    for (var i = 0; i < scale; i++) {
      value *= 10;
    }
    return value;
  }
}
