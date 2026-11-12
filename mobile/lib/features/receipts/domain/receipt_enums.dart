enum ReceiptPaperWidth {
  mm58(58),
  mm80(80);

  const ReceiptPaperWidth(this.mm);
  final int mm;

  static ReceiptPaperWidth fromMm(int mm) {
    return ReceiptPaperWidth.values.firstWhere(
      (w) => w.mm == mm,
      orElse: () => ReceiptPaperWidth.mm58,
    );
  }
}

enum PrinterConnectionType {
  systemQueue('SYSTEM_QUEUE'),
  unknown('UNKNOWN');

  const PrinterConnectionType(this.storage);
  final String storage;

  static PrinterConnectionType parse(String? value) {
    if (value == null) {
      return PrinterConnectionType.systemQueue;
    }
    return PrinterConnectionType.values.firstWhere(
      (e) => e.storage == value,
      orElse: () => PrinterConnectionType.unknown,
    );
  }
}

enum ReceiptPrintType {
  original('ORIGINAL'),
  reprint('REPRINT'),
  returnReceipt('RETURN'),
  test('TEST');

  const ReceiptPrintType(this.storage);
  final String storage;
}

enum ReceiptPrintResult {
  success('SUCCESS'),
  failed('FAILED'),
  unknown('UNKNOWN');

  const ReceiptPrintResult(this.storage);
  final String storage;
}
