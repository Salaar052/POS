import 'package:pos_mobile/features/receipts/domain/receipt_enums.dart';
import 'package:pos_mobile/features/sales/domain/sales_enums.dart';

class SaleReceiptLine {
  const SaleReceiptLine({
    required this.description,
    this.sku,
    required this.quantityBase,
    required this.unitPriceMinor,
    required this.discountMinor,
    required this.lineTotalMinor,
    required this.unitLabel,
  });

  final String description;
  final String? sku;
  final int quantityBase;
  final int unitPriceMinor;
  final int discountMinor;
  final int lineTotalMinor;
  final String unitLabel;
}

class SaleReceiptPaymentLine {
  const SaleReceiptPaymentLine({
    required this.method,
    required this.amountMinor,
    this.referenceNumber,
  });

  final SalePaymentMethod method;
  final int amountMinor;
  final String? referenceNumber;
}

class SaleReceiptDocument {
  const SaleReceiptDocument({
    required this.invoiceNumber,
    required this.saleNumber,
    required this.completedAtMs,
    required this.lines,
    required this.payments,
    required this.subtotalMinor,
    required this.saleDiscountMinor,
    required this.totalMinor,
    required this.amountPaidMinor,
    required this.amountDueMinor,
    this.customerName,
    this.customerPhone,
    this.notes,
    this.isReprint = false,
  });

  final String invoiceNumber;
  final String saleNumber;
  final int completedAtMs;
  final List<SaleReceiptLine> lines;
  final List<SaleReceiptPaymentLine> payments;
  final int subtotalMinor;
  final int saleDiscountMinor;
  final int totalMinor;
  final int amountPaidMinor;
  final int amountDueMinor;
  final String? customerName;
  final String? customerPhone;
  final String? notes;
  final bool isReprint;
}

class ReturnReceiptLine {
  const ReturnReceiptLine({
    required this.description,
    required this.quantityBase,
    required this.lineTotalMinor,
  });

  final String description;
  final int quantityBase;
  final int lineTotalMinor;
}

class ReturnReceiptDocument {
  const ReturnReceiptDocument({
    required this.returnNumber,
    required this.originalInvoiceNumber,
    required this.completedAtMs,
    required this.reason,
    required this.lines,
    required this.totalMinor,
    required this.accountCreditMinor,
    required this.cashRefundMinor,
    this.customerName,
    this.isReprint = false,
  });

  final String returnNumber;
  final String originalInvoiceNumber;
  final int completedAtMs;
  final String reason;
  final List<ReturnReceiptLine> lines;
  final int totalMinor;
  final int accountCreditMinor;
  final int cashRefundMinor;
  final String? customerName;
  final bool isReprint;
}

class ReceiptBusinessHeader {
  const ReceiptBusinessHeader({
    this.displayName,
    this.address,
    this.phone,
    this.taxId,
    this.headerText,
    this.footerText,
    required this.currencyDisplay,
  });

  final String? displayName;
  final String? address;
  final String? phone;
  final String? taxId;
  final String? headerText;
  final String? footerText;
  final String currencyDisplay;
}

class ReceiptRenderOptions {
  const ReceiptRenderOptions({
    required this.paperWidth,
    required this.showCustomerDetails,
    required this.showPaymentBreakdown,
    required this.showItemSku,
  });

  final ReceiptPaperWidth paperWidth;
  final bool showCustomerDetails;
  final bool showPaymentBreakdown;
  final bool showItemSku;
}
