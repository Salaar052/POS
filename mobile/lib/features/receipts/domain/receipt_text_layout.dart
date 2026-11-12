import 'package:pos_mobile/features/catalog/domain/money_amount.dart';
import 'package:pos_mobile/features/receipts/domain/receipt_enums.dart';
import 'package:pos_mobile/features/receipts/domain/receipt_models.dart';
import 'package:pos_mobile/features/sales/domain/sales_enums.dart';

abstract final class ReceiptTextLayout {
  static int charsPerLine(ReceiptPaperWidth width) =>
      width == ReceiptPaperWidth.mm80 ? 48 : 32;

  static List<String> buildSaleReceipt({
    required ReceiptBusinessHeader business,
    required SaleReceiptDocument sale,
    required ReceiptRenderOptions options,
  }) {
    final width = charsPerLine(options.paperWidth);
    final lines = <String>[];

    void center(String text) => lines.add(_center(text, width));
    void row(String left, String right) =>
        lines.add(_leftRight(left, right, width));
    void separator() => lines.add('-' * width);

    if (business.displayName != null &&
        business.displayName!.trim().isNotEmpty) {
      center(business.displayName!.trim());
    }
    if (business.address != null && business.address!.trim().isNotEmpty) {
      for (final part in _wrap(business.address!.trim(), width)) {
        center(part);
      }
    }
    if (business.phone != null && business.phone!.trim().isNotEmpty) {
      center(business.phone!.trim());
    }
    if (business.taxId != null && business.taxId!.trim().isNotEmpty) {
      center('Reg: ${business.taxId!.trim()}');
    }
    if (business.headerText != null && business.headerText!.trim().isNotEmpty) {
      for (final part in _wrap(business.headerText!.trim(), width)) {
        center(part);
      }
    }

    separator();
    center(sale.isReprint ? 'REPRINT' : 'SALE RECEIPT');
    separator();

    row('Invoice', sale.invoiceNumber);
    row('Order', sale.saleNumber);
    row('Date', _formatDateTime(sale.completedAtMs));

    if (options.showCustomerDetails && sale.customerName != null) {
      for (final part in _wrap('Customer: ${sale.customerName!}', width)) {
        lines.add(part);
      }
      if (sale.customerPhone != null && sale.customerPhone!.trim().isNotEmpty) {
        lines.add('Phone: ${sale.customerPhone!.trim()}');
      }
    }

    if (sale.notes != null && sale.notes!.trim().isNotEmpty) {
      for (final part in _wrap('Notes: ${sale.notes!.trim()}', width)) {
        lines.add(part);
      }
    }

    separator();
    for (final item in sale.lines) {
      final title = item.description;
      for (final part in _wrap(title, width)) {
        lines.add(part);
      }
      if (options.showItemSku && item.sku != null && item.sku!.isNotEmpty) {
        lines.add('SKU: ${item.sku}');
      }
      final qtyLine =
          '${item.quantityBase} x ${_money(item.unitPriceMinor, business.currencyDisplay)}';
      final total = _money(item.lineTotalMinor, business.currencyDisplay);
      row(qtyLine, total);
      if (item.discountMinor > 0) {
        row(
          '  Line disc.',
          '-${_money(item.discountMinor, business.currencyDisplay)}',
        );
      }
    }

    separator();
    row('Subtotal', _money(sale.subtotalMinor, business.currencyDisplay));
    if (sale.saleDiscountMinor > 0) {
      row(
        'Discount',
        '-${_money(sale.saleDiscountMinor, business.currencyDisplay)}',
      );
    }
    row('TOTAL', _money(sale.totalMinor, business.currencyDisplay));

    if (options.showPaymentBreakdown) {
      separator();
      for (final payment in sale.payments) {
        row(
          _paymentLabel(payment.method),
          _money(payment.amountMinor, business.currencyDisplay),
        );
        if (payment.referenceNumber != null &&
            payment.referenceNumber!.trim().isNotEmpty) {
          lines.add('Ref: ${payment.referenceNumber!.trim()}');
        }
      }
      row('Paid', _money(sale.amountPaidMinor, business.currencyDisplay));
      if (sale.amountDueMinor > 0) {
        row(
          'Balance due',
          _money(sale.amountDueMinor, business.currencyDisplay),
        );
      }
    }

    if (business.footerText != null && business.footerText!.trim().isNotEmpty) {
      separator();
      for (final part in _wrap(business.footerText!.trim(), width)) {
        center(part);
      }
    }

    lines.add('');
    return lines;
  }

  static List<String> buildReturnReceipt({
    required ReceiptBusinessHeader business,
    required ReturnReceiptDocument doc,
    required ReceiptPaperWidth paperWidth,
  }) {
    final width = charsPerLine(paperWidth);
    final lines = <String>[];

    void center(String text) => lines.add(_center(text, width));
    void row(String left, String right) =>
        lines.add(_leftRight(left, right, width));
    void separator() => lines.add('-' * width);

    if (business.displayName != null &&
        business.displayName!.trim().isNotEmpty) {
      center(business.displayName!.trim());
    }
    separator();
    center(doc.isReprint ? 'RETURN REPRINT' : 'RETURN RECEIPT');
    separator();
    row('Return', doc.returnNumber);
    row('Invoice', doc.originalInvoiceNumber);
    row('Date', _formatDateTime(doc.completedAtMs));
    if (doc.customerName != null) {
      lines.add('Customer: ${doc.customerName}');
    }
    lines.add('Reason: ${doc.reason}');
    separator();
    for (final line in doc.lines) {
      for (final part in _wrap(line.description, width)) {
        lines.add(part);
      }
      row(
        'Qty ${line.quantityBase}',
        _money(line.lineTotalMinor, business.currencyDisplay),
      );
    }
    separator();
    row('Return total', _money(doc.totalMinor, business.currencyDisplay));
    if (doc.accountCreditMinor > 0) {
      row(
        'Account credit',
        _money(doc.accountCreditMinor, business.currencyDisplay),
      );
    }
    if (doc.cashRefundMinor > 0) {
      row('Cash refund', _money(doc.cashRefundMinor, business.currencyDisplay));
    }
    lines.add('');
    return lines;
  }

  static String _money(int minor, String currency) =>
      '${MoneyAmount.formatPkrFromMinor(minor)} $currency';

  static String _paymentLabel(SalePaymentMethod method) {
    return switch (method) {
      SalePaymentMethod.cash => 'Cash',
      SalePaymentMethod.card => 'Card',
      SalePaymentMethod.bankTransfer => 'Bank',
      SalePaymentMethod.mobileWallet => 'Wallet',
      SalePaymentMethod.other => 'Other',
    };
  }

  static String _formatDateTime(int ms) {
    final dt = DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true).toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${dt.year}-${two(dt.month)}-${two(dt.day)} '
        '${two(dt.hour)}:${two(dt.minute)}';
  }

  static String _center(String text, int width) {
    if (text.length >= width) {
      return text.substring(0, width);
    }
    final pad = width - text.length;
    final left = pad ~/ 2;
    return ' ' * left + text;
  }

  static String _leftRight(String left, String right, int width) {
    final gap = width - left.length - right.length;
    if (gap >= 1) {
      return '$left${' ' * gap}$right';
    }
    final maxLeft = width - right.length - 1;
    if (maxLeft < 1) {
      return right.substring(0, width);
    }
    return '${left.substring(0, maxLeft)} $right';
  }

  static List<String> _wrap(String text, int width) {
    if (text.length <= width) {
      return [text];
    }
    final result = <String>[];
    var start = 0;
    while (start < text.length) {
      var end = (start + width).clamp(0, text.length);
      if (end < text.length) {
        var breakAt = text.lastIndexOf(' ', end);
        if (breakAt <= start) {
          breakAt = end;
        }
        end = breakAt;
      }
      result.add(text.substring(start, end).trim());
      start = end;
      while (start < text.length && text[start] == ' ') {
        start++;
      }
    }
    return result.where((l) => l.isNotEmpty).toList();
  }
}
