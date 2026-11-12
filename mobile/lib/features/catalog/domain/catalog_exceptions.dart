enum CatalogConflictCode {
  duplicateSku,
  duplicateBarcode,
  duplicateCategoryName,
  categoryNotFound,
  productNotFound,
  referenceConflict,
}

class CatalogConflictException implements Exception {
  CatalogConflictException(this.code, this.message);

  final CatalogConflictCode code;
  final String message;

  @override
  String toString() => message;
}

enum ProductArchiveFilter { activeOnly, archivedOnly, all }

/// Supported sellable units for catalog items (no stock tracking in this phase).
const List<String> catalogProductUnits = [
  'each',
  'kg',
  'g',
  'liter',
  'ml',
  'pack',
  'box',
];
