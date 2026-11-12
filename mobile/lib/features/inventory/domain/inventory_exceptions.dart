enum InventoryConflictCode {
  duplicateReference,
  productNotFound,
  movementNotFound,
  insufficientStock,
  invalidQuantity,
  balanceMissing,
}

class InventoryConflictException implements Exception {
  InventoryConflictException(this.code, this.message);

  final InventoryConflictCode code;
  final String message;

  @override
  String toString() => message;
}

enum StockStatus { inStock, lowStock, outOfStock, notConfigured }
