/// Declared capabilities for the active printer transport (best-effort).
class PrinterCapabilities {
  const PrinterCapabilities({
    required this.supportsEscPos,
    required this.supportsPdf,
    required this.paperWidthsMm,
    this.supportsCut = false,
    this.supportsCashDrawer = false,
    this.supportsLogoRaster = false,
    this.characterEncoding = 'CP437',
    this.unicodeReceiptText = false,
  });

  final bool supportsEscPos;
  final bool supportsPdf;
  final List<int> paperWidthsMm;
  final bool supportsCut;
  final bool supportsCashDrawer;
  final bool supportsLogoRaster;
  final String characterEncoding;
  final bool unicodeReceiptText;

  static const systemPdfOnly = PrinterCapabilities(
    supportsEscPos: false,
    supportsPdf: true,
    paperWidthsMm: [58, 80],
    characterEncoding: 'CP437',
  );

  static const escPosThermal = PrinterCapabilities(
    supportsEscPos: true,
    supportsPdf: false,
    paperWidthsMm: [58, 80],
    characterEncoding: 'CP437',
    unicodeReceiptText: false,
  );

  static const escPosWithPdfFallback = PrinterCapabilities(
    supportsEscPos: true,
    supportsPdf: true,
    paperWidthsMm: [58, 80],
    characterEncoding: 'CP437',
  );
}
