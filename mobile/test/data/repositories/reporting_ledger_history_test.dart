import 'package:flutter_test/flutter_test.dart';
import 'package:pos_mobile/data/repositories/customer_repository.dart';
import 'package:pos_mobile/data/repositories/purchase_repository.dart';
import 'package:pos_mobile/data/repositories/reporting_repository.dart';
import 'package:pos_mobile/data/repositories/sales_repository.dart';
import 'package:pos_mobile/data/repositories/supplier_repository.dart';
import 'package:pos_mobile/features/purchasing/domain/purchasing_enums.dart';
import 'package:pos_mobile/features/reporting/domain/report_period.dart';
import 'package:pos_mobile/features/sales/domain/sales_enums.dart';
import 'package:uuid/uuid.dart';

import '../../helpers/catalog_test_harness.dart';

void main() {
  late CatalogTestHarness catalog;

  setUp(() async {
    catalog = await CatalogTestHarness.create();
  });

  tearDown(() async {
    await catalog.dispose();
  });

  Future<String> seedProduct() async {
    return (await catalog.products.createProduct(
      name: 'Ledger Item',
      costPriceMinor: 1000,
      sellingPriceMinor: 2000,
      unit: 'each',
    )).id;
  }

  Future<void> stockIn(String productId) async {
    final supplier = await SupplierRepository(catalog.runner)
        .createSupplier(name: 'Ledger Supplier');
    final purchases = PurchaseRepository(catalog.runner);
    final draft = await purchases.createDraft(supplierId: supplier.id);
    await purchases.addDraftItem(
      purchaseId: draft.id,
      productId: productId,
      quantityBase: 50,
      unitCostMinor: 100,
    );
    await purchases.receivePurchase(
      purchaseId: draft.id,
      receiveIdempotencyKey: const Uuid().v4(),
    );
  }

  test('customer ledger history order and running balance', () async {
    final sales = SalesRepository(catalog.runner);
    final customers = CustomerRepository(catalog.runner);
    final reporting = ReportingRepository(catalog.runner);
    final productId = await seedProduct();
    await stockIn(productId);

    final customer = await customers.createCustomer(
      name: 'Ledger Customer',
      phone: '03001112233',
    );
    final draft = await sales.createDraft(customerId: customer.id);
    await sales.addDraftItem(
      saleId: draft.id,
      productId: productId,
      quantityBase: 2,
    );
    await sales.checkout(
      saleId: draft.id,
      checkoutIdempotencyKey: 'lh-1',
      payments: const [],
    );
    await customers.recordCustomerPayment(
      customerId: customer.id,
      amountMinor: 2000,
      method: SalePaymentMethod.cash,
      idempotencyKey: 'cp-1',
    );

    final period = ReportPeriod.fromPreset(ReportPeriodPreset.last30Days);
    final page = await reporting.customerLedgerHistory(
      customerId: customer.id,
      period: period,
    );
    expect(page.entries.length, greaterThanOrEqualTo(2));
    expect(
      page.entries.first.createdAtMs,
      greaterThanOrEqualTo(page.entries.last.createdAtMs),
    );
    expect(page.authoritativeBalanceMinor, 2000);
    final labels = page.entries.map((e) => e.typeLabel).toSet();
    expect(labels.contains('Sale on account'), isTrue);
    expect(labels.contains('Customer payment'), isTrue);
  });

  test('sale return credit appears in customer ledger history', () async {
    final sales = SalesRepository(catalog.runner);
    final customers = CustomerRepository(catalog.runner);
    final reporting = ReportingRepository(catalog.runner);
    final productId = await seedProduct();
    await stockIn(productId);

    final customer = await customers.createCustomer(
      name: 'Return Customer',
      phone: '03004445566',
    );
    final draft = await sales.createDraft(customerId: customer.id);
    await sales.addDraftItem(
      saleId: draft.id,
      productId: productId,
      quantityBase: 2,
    );
    await sales.checkout(
      saleId: draft.id,
      checkoutIdempotencyKey: 'lh-r1',
      payments: const [],
    );
    final items = await sales.listSaleItems(draft.id);
    await sales.returnSale(
      saleId: draft.id,
      idempotencyKey: 'ret-lh',
      reason: 'Test',
      lines: [
        SaleReturnLineInput(saleItemId: items.single.id, quantityBase: 1),
      ],
    );

    final period = ReportPeriod.fromPreset(ReportPeriodPreset.last30Days);
    final metrics = await reporting.salesPeriodMetrics(period);
    expect(metrics.returnsMinor, 2000);
    expect(metrics.netSalesAfterReturnsMinor, metrics.netSalesMinor - 2000);

    final page = await reporting.customerLedgerHistory(
      customerId: customer.id,
      period: period,
    );
    expect(
      page.entries.any((e) => e.typeLabel == 'Sale return credit'),
      isTrue,
    );
  });

  test(
    'supplier ledger includes payable, payment and purchase return',
    () async {
      final purchases = PurchaseRepository(catalog.runner);
      final suppliers = SupplierRepository(catalog.runner);
      final reporting = ReportingRepository(catalog.runner);
      final productId = await seedProduct();

      final supplier = await suppliers.createSupplier(name: 'Hist Supplier');
      final draft = await purchases.createDraft(supplierId: supplier.id);
      await purchases.addDraftItem(
        purchaseId: draft.id,
        productId: productId,
        quantityBase: 10,
        unitCostMinor: 500,
      );
      await purchases.receivePurchase(
        purchaseId: draft.id,
        receiveIdempotencyKey: 'recv-h1',
      );
      final received = await purchases.getPurchaseById(draft.id);
      await purchases.recordPayment(
        purchaseId: draft.id,
        amountMinor: 2000,
        method: PurchasePaymentMethod.cash,
        idempotencyKey: 'sp-1',
      );
      final items = await purchases.listPurchaseItems(draft.id);
      await purchases.completePurchaseReturn(
        purchaseId: draft.id,
        reason: 'Damaged',
        idempotencyKey: 'pr-1',
        lines: [
          PurchaseReturnLineRequest(
            purchaseItemId: items.first.id,
            quantityBase: 2,
          ),
        ],
      );

      final period = ReportPeriod.fromPreset(ReportPeriodPreset.last30Days);
      final purchaseMetrics = await reporting.purchasePeriodMetrics(period);
      expect(purchaseMetrics.grossPurchasesMinor, received!.totalMinor);
      expect(purchaseMetrics.purchaseReturnsMinor, greaterThan(0));
      expect(purchaseMetrics.supplierPaymentsMinor, 2000);

      final page = await reporting.supplierLedgerHistory(
        supplierId: supplier.id,
        period: period,
      );
      final labels = page.entries.map((e) => e.typeLabel).toSet();
      expect(labels.contains('Purchase payable'), isTrue);
      expect(labels.contains('Supplier payment'), isTrue);
      expect(labels.contains('Purchase return'), isTrue);
    },
  );

  test('draft purchase is excluded from purchase period metrics', () async {
    final purchases = PurchaseRepository(catalog.runner);
    final suppliers = SupplierRepository(catalog.runner);
    final reporting = ReportingRepository(catalog.runner);
    final productId = await seedProduct();
    final supplier = await suppliers.createSupplier(name: 'Draft Sup');
    final draft = await purchases.createDraft(supplierId: supplier.id);
    await purchases.addDraftItem(
      purchaseId: draft.id,
      productId: productId,
      quantityBase: 5,
      unitCostMinor: 100,
    );
    final period = ReportPeriod.fromPreset(ReportPeriodPreset.last30Days);
    final metrics = await reporting.purchasePeriodMetrics(period);
    expect(metrics.purchaseCount, 0);
    expect(metrics.grossPurchasesMinor, 0);
  });
}
