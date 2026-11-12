import 'dart:typed_data';

import 'package:pos_mobile/data/repositories/print_attempt_repository.dart';
import 'package:pos_mobile/data/repositories/receipt_settings_repository.dart';
import 'package:pos_mobile/features/receipts/application/receipt_data_service.dart';
import 'package:pos_mobile/features/receipts/application/thermal_printer_service.dart';
import 'package:pos_mobile/features/receipts/domain/printer_models.dart';
import 'package:pos_mobile/features/receipts/domain/receipt_enums.dart';
import 'package:pos_mobile/features/receipts/domain/receipt_esc_pos_encoder.dart';
import 'package:pos_mobile/features/receipts/domain/receipt_models.dart';
import 'package:pos_mobile/features/receipts/domain/receipt_pdf_builder.dart';

class ReceiptPrintService {
  ReceiptPrintService({
    required ReceiptDataService data,
    required ThermalPrinterService printer,
    required ReceiptSettingsRepository settings,
    required PrintAttemptRepository printAttempts,
  }) : _data = data,
       _printer = printer,
       _settings = settings,
       _printAttempts = printAttempts;

  final ReceiptDataService _data;
  final ThermalPrinterService _printer;
  final ReceiptSettingsRepository _settings;
  final PrintAttemptRepository _printAttempts;

  static const refTypeSale = 'SALE';
  static const refTypeReturn = 'SALE_RETURN';

  Future<PrintOutcome> printSaleReceipt({
    required String saleId,
    required ReceiptPrintType printType,
    bool forceSystemPdf = false,
  }) async {
    final loaded = await _data.loadSaleReceipt(
      saleId: saleId,
      isReprint: printType == ReceiptPrintType.reprint,
    );
    final useEscPos =
        !forceSystemPdf &&
        _printer.activeOutputChannel == ReceiptOutputChannel.nativeEscPos;

    if (useEscPos) {
      final escPos = await ReceiptEscPosEncoder.encodeSale(
        business: loaded.business,
        sale: loaded.document,
        options: loaded.options,
      );
      return _deliverAndLog(
        escPos: escPos,
        referenceType: refTypeSale,
        referenceId: saleId,
        documentNumber: loaded.document.invoiceNumber,
        printType: printType,
        paperWidthMm: loaded.options.paperWidth.mm,
      );
    }

    final pdf = await ReceiptPdfBuilder.buildSalePdf(
      business: loaded.business,
      sale: loaded.document,
      options: loaded.options,
    );
    return _deliverAndLog(
      pdf: pdf,
      referenceType: refTypeSale,
      referenceId: saleId,
      documentNumber: loaded.document.invoiceNumber,
      printType: printType,
      paperWidthMm: loaded.options.paperWidth.mm,
    );
  }

  Future<PrintOutcome> printReturnReceipt({
    required String saleReturnId,
    required ReceiptPrintType printType,
    bool forceSystemPdf = false,
  }) async {
    final loaded = await _data.loadReturnReceipt(
      saleReturnId: saleReturnId,
      isReprint: printType == ReceiptPrintType.reprint,
    );
    final useEscPos =
        !forceSystemPdf &&
        _printer.activeOutputChannel == ReceiptOutputChannel.nativeEscPos;

    if (useEscPos) {
      final escPos = await ReceiptEscPosEncoder.encodeReturn(
        business: loaded.business,
        doc: loaded.document,
        paperWidth: loaded.paperWidth,
      );
      return _deliverAndLog(
        escPos: escPos,
        referenceType: refTypeReturn,
        referenceId: saleReturnId,
        documentNumber: loaded.document.returnNumber,
        printType: printType,
        paperWidthMm: loaded.paperWidth.mm,
      );
    }

    final pdf = await ReceiptPdfBuilder.buildReturnPdf(
      business: loaded.business,
      doc: loaded.document,
      paperWidth: loaded.paperWidth,
    );
    return _deliverAndLog(
      pdf: pdf,
      referenceType: refTypeReturn,
      referenceId: saleReturnId,
      documentNumber: loaded.document.returnNumber,
      printType: printType,
      paperWidthMm: loaded.paperWidth.mm,
    );
  }

  Future<PrintOutcome> printTestReceipt({bool forceSystemPdf = false}) async {
    final settings = await _settings.getSettings();
    final paper = ReceiptPaperWidth.fromMm(settings.paperWidthMm);
    final testHeader = ReceiptBusinessHeader(
      displayName: settings.businessDisplayName,
      address: settings.businessAddress,
      phone: settings.businessPhone,
      taxId: settings.taxRegistrationId,
      headerText: settings.headerText,
      footerText: settings.footerText,
      currencyDisplay: settings.currencyDisplay,
    );
    final useEscPos =
        !forceSystemPdf &&
        _printer.activeOutputChannel == ReceiptOutputChannel.nativeEscPos;

    if (useEscPos) {
      final escPos = await ReceiptEscPosEncoder.encodeTest(
        business: testHeader,
        paperWidth: paper,
      );
      return _deliverAndLog(
        escPos: escPos,
        referenceType: 'TEST',
        referenceId: 'test',
        documentNumber: 'TEST',
        printType: ReceiptPrintType.test,
        paperWidthMm: paper.mm,
      );
    }

    final pdf = await ReceiptPdfBuilder.buildTestPdf(
      business: testHeader,
      paperWidth: paper,
    );
    return _deliverAndLog(
      pdf: pdf,
      referenceType: 'TEST',
      referenceId: 'test',
      documentNumber: 'TEST',
      printType: ReceiptPrintType.test,
      paperWidthMm: paper.mm,
    );
  }

  Future<PrintOutcome> _deliverAndLog({
    Uint8List? pdf,
    Uint8List? escPos,
    required String referenceType,
    required String referenceId,
    required String documentNumber,
    required ReceiptPrintType printType,
    required int paperWidthMm,
  }) async {
    final settings = await _settings.getSettings();
    final copies = settings.defaultCopyCount.clamp(1, 5);
    final printerId =
        _printer.activeConfiguration?.printerId ?? settings.selectedPrinterId;

    final PrintOutcome outcome;
    if (escPos != null) {
      outcome = await _printer.printEscPos(
        escPosBytes: escPos,
        jobName: documentNumber,
        copyCount: copies,
      );
    } else if (pdf != null) {
      outcome = await _printer.printPdf(
        pdfBytes: pdf,
        jobName: documentNumber,
        copyCount: copies,
      );
    } else {
      outcome = const PrintOutcome(
        result: ReceiptPrintResult.failed,
        message: 'No receipt payload',
      );
    }

    await _printAttempts.logAttempt(
      referenceType: referenceType,
      referenceId: referenceId,
      documentNumber: documentNumber,
      printType: printType,
      result: outcome.result,
      paperWidthMm: paperWidthMm,
      printerId: printerId,
      errorDetail: outcome.message,
    );

    return outcome;
  }
}
