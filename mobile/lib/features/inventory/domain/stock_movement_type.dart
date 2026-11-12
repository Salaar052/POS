/// Directional stock ledger entries. Quantity is always positive; type defines effect.
enum StockMovementType {
  openingStock('OPENING_STOCK', isInbound: true),
  purchaseReceived('PURCHASE_RECEIVED', isInbound: true),
  sale('SALE', isInbound: false),
  saleReturn('SALE_RETURN', isInbound: true),
  purchaseReturn('PURCHASE_RETURN', isInbound: false),
  adjustmentIn('ADJUSTMENT_IN', isInbound: true),
  adjustmentOut('ADJUSTMENT_OUT', isInbound: false),
  damage('DAMAGE', isInbound: false),
  expired('EXPIRED', isInbound: false),
  reversal('REVERSAL', isInbound: false);

  const StockMovementType(this.storageValue, {required this.isInbound});

  final String storageValue;
  final bool isInbound;

  static StockMovementType fromStorage(String value) {
    return StockMovementType.values.firstWhere(
      (e) => e.storageValue == value,
      orElse: () => throw ArgumentError('Unknown movement type: $value'),
    );
  }

  /// Compensating type for [reversal] rows tied to an original movement.
  static StockMovementType inboundPartner(StockMovementType type) {
    if (type.isInbound) {
      return StockMovementType.adjustmentOut;
    }
    return StockMovementType.adjustmentIn;
  }
}
