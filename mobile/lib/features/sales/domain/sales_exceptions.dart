enum SalesConflictCode {
  notFound,
  invalidState,
  duplicateOperation,
  validation,
  customerRequired,
  paymentExceedsDue,
  walkInRequiresFullPayment,
  returnExceedsEligible,
  insufficientStock,
}

class SalesConflictException implements Exception {
  SalesConflictException(this.code, this.message);

  final SalesConflictCode code;
  final String message;

  @override
  String toString() => message;
}
