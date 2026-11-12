enum PurchasingConflictCode {
  notFound,
  invalidState,
  duplicateOperation,
  validation,
  supplierRequired,
  paymentExceedsDue,
  returnExceedsEligible,
}

class PurchasingConflictException implements Exception {
  PurchasingConflictException(this.code, this.message);

  final PurchasingConflictCode code;
  final String message;

  @override
  String toString() => message;
}
