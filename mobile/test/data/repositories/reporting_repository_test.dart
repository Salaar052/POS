import 'package:flutter_test/flutter_test.dart';
import 'package:pos_mobile/data/repositories/customer_repository.dart';
import 'package:pos_mobile/data/repositories/purchase_repository.dart';
import 'package:pos_mobile/data/repositories/reporting_repository.dart';
import 'package:pos_mobile/data/repositories/sales_repository.dart';
import 'package:pos_mobile/data/repositories/supplier_repository.dart';
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
    final product = await catalog.products.createProduct(
      name: 'Report Biscuit',
      costPriceMinor: 5000,
      sellingPriceMinor: 10000,
      unit: 'each',
    );
    return product.id;
  }

  Future<void> stockIn(String productId, {int qty = 20}) async {
    final supplier = await SupplierRepository(catalog.runner)
        .createSupplier(name: 'Report Supplier');
    final purchases = PurchaseRepository(catalog.runner);
    final draft = await purchases.createDraft(supplierId: supplier.id);
    await purchases.addDraftItem(
      purchaseId: draft.id,
      productId: productId,
      quantityBase: qty,
      unitCostMinor: 100,
    );
    await purchases.receivePurchase(
      purchaseId: draft.id,
      receiveIdempotencyKey: const Uuid().v4(),
    );
  }

  test('draft and cancelled sales excluded from revenue', () async {
    final sales = SalesRepository(catalog.runner);
    final reporting = ReportingRepository(catalog.runner);
    final productId = await seedProduct();
    await stockIn(productId);

    final draft = await sales.createDraft();
    await sales.addDraftItem(
      saleId: draft.id,
      productId: productId,
      quantityBase: 1,
    );

    final cancelled = await sales.createDraft();
    await sales.addDraftItem(
      saleId: cancelled.id,
      productId: productId,
      quantityBase: 1,
    );
    await sales.cancelDraft(cancelled.id);

    final completed = await sales.createDraft();
    await sales.addDraftItem(
      saleId: completed.id,
      productId: productId,
      quantityBase: 2,
    );
    await sales.checkout(
      saleId: completed.id,
      checkoutIdempotencyKey: 'rep-1',
      payments: [
        const CheckoutPaymentInput(
          method: SalePaymentMethod.cash,
          amountMinor: 20000,
          idempotencyKey: 'pay-1',
        ),
      ],
    );

    final period = ReportPeriod.fromPreset(ReportPeriodPreset.last30Days);
    final metrics = await reporting.salesPeriodMetrics(period);
    expect(metrics.saleCount, 1);
    expect(metrics.netSalesMinor, 20000);
    expect(metrics.checkoutCollectionsMinor, 20000);
  });

  test('customer account payment is not sales revenue', () async {
    final sales = SalesRepository(catalog.runner);
    final customers = CustomerRepository(catalog.runner);
    final reporting = ReportingRepository(catalog.runner);
    final productId = await seedProduct();
    await stockIn(productId);

    final customer = await customers.createCustomer(
      name: 'Credit Customer',
      phone: '03009998877',
    );
    final draft = await sales.createDraft(customerId: customer.id);
    await sales.addDraftItem(
      saleId: draft.id,
      productId: productId,
      quantityBase: 1,
    );
    await sales.checkout(
      saleId: draft.id,
      checkoutIdempotencyKey: 'cr-1',
      payments: const [],
    );

    await customers.recordCustomerPayment(
      customerId: customer.id,
      amountMinor: 10000,
      method: SalePaymentMethod.cash,
      idempotencyKey: const Uuid().v4(),
    );

    final period = ReportPeriod.fromPreset(ReportPeriodPreset.last30Days);
    final metrics = await reporting.salesPeriodMetrics(period);
    expect(metrics.netSalesMinor, 10000);
    expect(metrics.customerAccountPaymentsMinor, 10000);
    expect(metrics.checkoutCollectionsMinor, 0);
  });
}
