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
  windowsRawQueue('WINDOWS_RAW_QUEUE'),
  windowsSerial('WINDOWS_SERIAL'),
  bluetoothClassic('BLUETOOTH_CLASSIC'),
  androidUsbOtg('ANDROID_USB_OTG'),
  unknown('UNKNOWN');

  const PrinterConnectionType(this.storage);
  final String storage;

  bool get usesNativeEscPos => this != systemQueue && this != unknown;

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

enum ReceiptOutputChannel {
  systemPdf('SYSTEM_PDF'),
  nativeEscPos('NATIVE_ESC_POS');

  const ReceiptOutputChannel(this.storage);
  final String storage;

  static ReceiptOutputChannel fromConnection(PrinterConnectionType type) {
    return type.usesNativeEscPos
        ? ReceiptOutputChannel.nativeEscPos
        : ReceiptOutputChannel.systemPdf;
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
