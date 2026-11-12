enum SaleStatus {
  draft('DRAFT'),
  completed('COMPLETED'),
  cancelled('CANCELLED');

  const SaleStatus(this.storage);
  final String storage;

  static SaleStatus parse(String value) =>
      SaleStatus.values.firstWhere((e) => e.storage == value);
}

enum SalePaymentMethod {
  cash('CASH'),
  card('CARD'),
  bankTransfer('BANK_TRANSFER'),
  mobileWallet('MOBILE_WALLET'),
  other('OTHER');

  const SalePaymentMethod(this.storage);
  final String storage;

  static SalePaymentMethod parse(String value) =>
      SalePaymentMethod.values.firstWhere((e) => e.storage == value);
}

enum CustomerLedgerEntryType {
  saleReceivable('SALE_RECEIVABLE'),
  customerPayment('CUSTOMER_PAYMENT'),
  saleReturn('SALE_RETURN'),
  adjustment('ADJUSTMENT');

  const CustomerLedgerEntryType(this.storage);
  final String storage;
}

enum SaleReturnStatus {
  completed('COMPLETED');

  const SaleReturnStatus(this.storage);
  final String storage;
}
