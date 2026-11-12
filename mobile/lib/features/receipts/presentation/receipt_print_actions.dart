import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_mobile/app/providers/receipt_providers.dart';
import 'package:pos_mobile/features/receipts/domain/receipt_enums.dart';

Future<void> promptPrintAfterCheckout(
  BuildContext context,
  WidgetRef ref, {
  required String saleId,
  required String? invoiceNumber,
}) async {
  final action = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Sale completed'),
      content: Text(
        invoiceNumber != null
            ? 'Invoice $invoiceNumber saved. Print receipt now?'
            : 'Sale saved. Print receipt now?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, 'skip'),
          child: const Text('Later'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, 'print'),
          child: const Text('Print receipt'),
        ),
      ],
    ),
  );
  if (action != 'print' || !context.mounted) {
    return;
  }
  await runSalePrint(
    context,
    ref,
    saleId: saleId,
    printType: ReceiptPrintType.original,
  );
}

Future<void> runSalePrint(
  BuildContext context,
  WidgetRef ref, {
  required String saleId,
  required ReceiptPrintType printType,
  bool forceSystemPdf = false,
}) async {
  final outcome = await ref
      .read(receiptPrintServiceProvider)
      .printSaleReceipt(
        saleId: saleId,
        printType: printType,
        forceSystemPdf: forceSystemPdf,
      );
  if (!context.mounted) {
    return;
  }
  final message = switch (outcome.result) {
    ReceiptPrintResult.success => 'Receipt sent to printer.',
    ReceiptPrintResult.failed =>
      'Print failed: ${outcome.message ?? 'Unknown error'}',
    ReceiptPrintResult.unknown =>
      outcome.message ??
          'Print may have succeeded — verify the printer before reprinting.',
  };
  final retry = outcome.result != ReceiptPrintResult.success;
  if (!retry) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
    return;
  }
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      action: SnackBarAction(
        label: 'Retry',
        onPressed: () => runSalePrint(
          context,
          ref,
          saleId: saleId,
          printType: printType,
          forceSystemPdf: forceSystemPdf,
        ),
      ),
    ),
  );
  if (!forceSystemPdf) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Try system PDF if native printing failed.'),
        action: SnackBarAction(
          label: 'Use PDF',
          onPressed: () => runSalePrint(
            context,
            ref,
            saleId: saleId,
            printType: printType,
            forceSystemPdf: true,
          ),
        ),
      ),
    );
  }
}

Future<void> runReturnPrint(
  BuildContext context,
  WidgetRef ref, {
  required String saleReturnId,
  ReceiptPrintType printType = ReceiptPrintType.returnReceipt,
}) async {
  final outcome = await ref
      .read(receiptPrintServiceProvider)
      .printReturnReceipt(saleReturnId: saleReturnId, printType: printType);
  if (!context.mounted) {
    return;
  }
  final message = switch (outcome.result) {
    ReceiptPrintResult.success => 'Return receipt sent to printer.',
    ReceiptPrintResult.failed =>
      'Print failed: ${outcome.message ?? 'Unknown error'}',
    ReceiptPrintResult.unknown => outcome.message ?? 'Print result uncertain.',
  };
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
