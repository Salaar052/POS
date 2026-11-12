/// Text normalization for catalog duplicate detection.
abstract final class CatalogNormalization {
  static String normalizeCategoryName(String raw) {
    final collapsed = raw.trim().replaceAll(RegExp(r'\s+'), ' ');
    return collapsed.toLowerCase();
  }

  static String? normalizeSku(String? raw) {
    if (raw == null) {
      return null;
    }
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    return trimmed.toUpperCase();
  }

  static String? normalizeBarcode(String? raw) {
    if (raw == null) {
      return null;
    }
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }

  static String requireProductName(String raw) {
    final name = raw.trim();
    if (name.isEmpty) {
      throw const CatalogValidationException('Product name is required');
    }
    return name;
  }

  static String requireCategoryName(String raw) {
    final name = raw.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (name.isEmpty) {
      throw const CatalogValidationException('Category name is required');
    }
    return name;
  }
}

class CatalogValidationException implements Exception {
  const CatalogValidationException(this.message);

  final String message;

  @override
  String toString() => message;
}
