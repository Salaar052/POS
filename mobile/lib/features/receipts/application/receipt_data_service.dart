import 'package:drift/drift.dart';
import 'package:pos_mobile/data/repositories/customer_repository.dart';
import 'package:pos_mobile/data/repositories/database_runner.dart';
import 'package:pos_mobile/data/repositories/receipt_settings_repository.dart';
import 'package:pos_mobile/data/repositories/sales_repository.dart';
import 'package:pos_mobile/database/app_database.dart';
import 'package:pos_mobile/features/receipts/domain/receipt_enums.dart';
import 'package:pos_mobile/features/receipts/domain/receipt_models.dart';
import 'package:pos_mobile/features/sales/domain/sales_enums.dart';

class ReceiptDataService {
  ReceiptDataService(
    this._runner, {
    SalesRepository? sales,
    ReceiptSettingsRepository? settings,
    CustomerRepository? customers,
  }) : _sales = sales ?? SalesRepository(_runner),
       _settings = settings ?? ReceiptSettingsRepository(_runner),
       _customers = customers ?? CustomerRepository(_runner);

  final DatabaseRunner _runner;
  final SalesRepository _sales;
  final ReceiptSettingsRepository _settings;
  final CustomerRepository _customers;

  Future<
    ({
      ReceiptBusinessHeader business,
      ReceiptRenderOptions options,
      SaleReceiptDocument document,
    })
  >
  loadSaleReceipt({required String saleId, bool isReprint = false}) async {
    final sale = await _sales.getSaleById(saleId);
    if (sale == null || sale.status != SaleStatus.completed.storage) {
      throw StateError('Completed sale not found');
    }
    final invoice = sale.invoiceNumber;
    if (invoice == null || invoice.isEmpty) {
      throw StateError('Sale has no invoice number');
    }
    final items = await _sales.listSaleItems(saleId);
    final payments = await _sales.listSalePayments(saleId);
    final settings = await _settings.getSettings();

    String? customerPhone;
    if (sale.customerId != null) {
      final customer = await _customers.getById(sale.customerId!);
      customerPhone = customer?.phone;
    }

    final lines = items
        .map(
          (i) => SaleReceiptLine(
            description: i.productNameSnapshot,
            sku: i.skuSnapshot,
            quantityBase: i.quantityBase,
            unitPriceMinor: i.unitPriceMinor,
            discountMinor: i.discountMinor,
            lineTotalMinor: i.lineTotalMinor,
            unitLabel: i.unitSnapshot,
          ),
        )
        .toList();

    final payLines = payments
        .map(
          (p) => SaleReceiptPaymentLine(
            method: SalePaymentMethod.parse(p.paymentMethod),
            amountMinor: p.amountMinor,
            referenceNumber: p.referenceNumber,
          ),
        )
        .toList();

    final business = ReceiptBusinessHeader(
      displayName: settings.businessDisplayName,
      address: settings.businessAddress,
      phone: settings.businessPhone,
      taxId: settings.taxRegistrationId,
      headerText: settings.headerText,
      footerText: settings.footerText,
      currencyDisplay: settings.currencyDisplay,
    );

    final options = ReceiptRenderOptions(
      paperWidth: ReceiptPaperWidth.fromMm(settings.paperWidthMm),
      showCustomerDetails: settings.showCustomerDetails,
      showPaymentBreakdown: settings.showPaymentBreakdown,
      showItemSku: settings.showItemSku,
    );

    final document = SaleReceiptDocument(
      invoiceNumber: invoice,
      saleNumber: sale.saleNumber,
      completedAtMs: sale.completedAtMs ?? sale.updatedAtMs,
      lines: lines,
      payments: payLines,
      subtotalMinor: sale.subtotalMinor,
      saleDiscountMinor: sale.discountMinor,
      totalMinor: sale.totalMinor,
      amountPaidMinor: sale.amountPaidMinor,
      amountDueMinor: sale.amountDueMinor,
      customerName: sale.customerNameSnapshot,
      customerPhone: customerPhone,
      notes: sale.notes,
      isReprint: isReprint,
    );

    return (business: business, options: options, document: document);
  }

  Future<
    ({
      ReceiptBusinessHeader business,
      ReceiptPaperWidth paperWidth,
      ReturnReceiptDocument document,
    })
  >
  loadReturnReceipt({
    required String saleReturnId,
    bool isReprint = false,
  }) async {
    final saleReturn = await (_runner.database.select(
      _runner.database.saleReturns,
    )..where((t) => t.id.equals(saleReturnId))).getSingleOrNull();
    if (saleReturn == null) {
      throw StateError('Return not found');
    }
    final sale = await _sales.getSaleById(saleReturn.saleId);
    if (sale == null) {
      throw StateError('Original sale not found');
    }
    final invoice = sale.invoiceNumber ?? sale.saleNumber;
    final items = await _sales.listReturnItems(saleReturnId);
    final settings = await _settings.getSettings();

    final saleItems = await _sales.listSaleItems(saleReturn.saleId);
    final itemNames = {for (final i in saleItems) i.id: i.productNameSnapshot};
    final lines = items
        .map(
          (i) => ReturnReceiptLine(
            description: itemNames[i.saleItemId] ?? 'Item',
            quantityBase: i.quantityBase,
            lineTotalMinor: i.lineTotalMinor,
          ),
        )
        .toList();

    final business = ReceiptBusinessHeader(
      displayName: settings.businessDisplayName,
      address: settings.businessAddress,
      phone: settings.businessPhone,
      taxId: settings.taxRegistrationId,
      headerText: settings.headerText,
      footerText: settings.footerText,
      currencyDisplay: settings.currencyDisplay,
    );

    final document = ReturnReceiptDocument(
      returnNumber: saleReturn.returnNumber,
      originalInvoiceNumber: invoice,
      completedAtMs: saleReturn.completedAtMs ?? saleReturn.createdAtMs,
      reason: saleReturn.reason,
      lines: lines,
      totalMinor: saleReturn.totalMinor,
      accountCreditMinor: saleReturn.totalMinor,
      cashRefundMinor: 0,
      customerName: sale.customerNameSnapshot,
      isReprint: isReprint,
    );

    return (
      business: business,
      paperWidth: ReceiptPaperWidth.fromMm(settings.paperWidthMm),
      document: document,
    );
  }

  Future<List<SaleReturnRow>> listReturnsForSale(String saleId) {
    return (_runner.database.select(_runner.database.saleReturns)
          ..where((t) => t.saleId.equals(saleId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAtMs)]))
        .get();
  }
}
