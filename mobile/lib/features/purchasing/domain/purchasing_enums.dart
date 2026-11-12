enum PurchaseStatus {
  draft('DRAFT'),
  received('RECEIVED'),
  cancelled('CANCELLED');

  const PurchaseStatus(this.storage);
  final String storage;

  static PurchaseStatus parse(String value) {
    return PurchaseStatus.values.firstWhere((e) => e.storage == value);
  }
}

enum PurchasePaymentStatus {
  unpaid('UNPAID'),
  partial('PARTIAL'),
  paid('PAID');

  const PurchasePaymentStatus(this.storage);
  final String storage;

  static PurchasePaymentStatus parse(String value) {
    return PurchasePaymentStatus.values.firstWhere((e) => e.storage == value);
  }
}

enum PurchasePaymentMethod {
  cash('CASH'),
  bankTransfer('BANK_TRANSFER'),
  other('OTHER');

  const PurchasePaymentMethod(this.storage);
  final String storage;

  static PurchasePaymentMethod parse(String value) {
    return PurchasePaymentMethod.values.firstWhere((e) => e.storage == value);
  }
}

enum SupplierLedgerEntryType {
  purchasePayable('PURCHASE_PAYABLE'),
  payment('PAYMENT'),
  purchaseReturn('PURCHASE_RETURN'),
  adjustment('ADJUSTMENT'),
  reversal('REVERSAL');

  const SupplierLedgerEntryType(this.storage);
  final String storage;
}

enum PurchaseReturnStatus {
  completed('COMPLETED');

  const PurchaseReturnStatus(this.storage);
  final String storage;
}
