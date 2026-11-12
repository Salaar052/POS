import 'package:flutter_test/flutter_test.dart';
import 'package:pos_mobile/data/repositories/customer_ledger_repository.dart';
import 'package:pos_mobile/data/repositories/customer_repository.dart';
import 'package:pos_mobile/data/repositories/purchase_repository.dart';
import 'package:pos_mobile/data/repositories/sales_repository.dart';
import 'package:pos_mobile/data/repositories/supplier_repository.dart';
import 'package:pos_mobile/features/sales/domain/sales_enums.dart';
import 'package:pos_mobile/features/sales/domain/sales_exceptions.dart';
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

  Future<String> customerWithBalance() async {
    final customer = await CustomerRepository(catalog.runner)
        .createCustomer(name: 'Pay Customer');
    final product = await catalog.products.createProduct(
      name: 'Item',
      costPriceMinor: 100,
      sellingPriceMinor: 5000,
    );
    final supplier = await SupplierRepository(catalog.runner)
        .createSupplier(name: 'S');
    final purchases = PurchaseRepository(catalog.runner);
    final pDraft = await purchases.createDraft(supplierId: supplier.id);
    await purchases.addDraftItem(
      purchaseId: pDraft.id,
      productId: product.id,
      quantityBase: 10,
      unitCostMinor: 100,
    );
    await purchases.receivePurchase(
      purchaseId: pDraft.id,
      receiveIdempotencyKey: const Uuid().v4(),
    );
    final sales = SalesRepository(catalog.runner);
    final sale = await sales.createDraft(customerId: customer.id);
    await sales.addDraftItem(
      saleId: sale.id,
      productId: product.id,
      quantityBase: 1,
    );
    await sales.checkout(
      saleId: sale.id,
      checkoutIdempotencyKey: 'bal',
      payments: const [],
    );
    return customer.id;
  }

  test('cash payment persists method and reference', () async {
    final customerId = await customerWithBalance();
    const key = 'cust-pay-1';
    await CustomerRepository(catalog.runner).recordCustomerPayment(
      customerId: customerId,
      amountMinor: 2000,
      method: SalePaymentMethod.cash,
      idempotencyKey: key,
      referenceNumber: 'RCPT-100',
      notes: 'Counter collection',
    );
    final entry = await CustomerLedgerRepository(catalog.runner)
        .findByReference(
          type: CustomerLedgerEntryType.customerPayment,
          referenceType: 'CUSTOMER_PAYMENT',
          referenceId: key,
        );
    expect(entry?.paymentMethod, SalePaymentMethod.cash.storage);
    expect(entry?.referenceNumber, 'RCPT-100');
    expect(entry?.notes, 'Counter collection');
  });

  test('card payment persists method', () async {
    final customerId = await customerWithBalance();
    await CustomerRepository(catalog.runner).recordCustomerPayment(
      customerId: customerId,
      amountMinor: 1000,
      method: SalePaymentMethod.card,
      idempotencyKey: 'cust-pay-card',
    );
    final rows = await CustomerRepository(catalog.runner)
        .listLedger(customerId, limit: 5);
    final payment = rows.firstWhere(
      (e) => e.entryType == CustomerLedgerEntryType.customerPayment.storage,
    );
    expect(payment.paymentMethod, SalePaymentMethod.card.storage);
  });

  test('identical payment retry does not duplicate', () async {
    final customerId = await customerWithBalance();
    const key = 'cust-pay-dup';
    final repo = CustomerRepository(catalog.runner);
    await repo.recordCustomerPayment(
      customerId: customerId,
      amountMinor: 500,
      method: SalePaymentMethod.bankTransfer,
      idempotencyKey: key,
      referenceNumber: 'BNK-1',
    );
    await repo.recordCustomerPayment(
      customerId: customerId,
      amountMinor: 500,
      method: SalePaymentMethod.bankTransfer,
      idempotencyKey: key,
      referenceNumber: 'BNK-1',
    );
    final ledger = await repo.listLedger(customerId);
    final payments = ledger
        .where(
          (e) =>
              e.referenceId == key &&
              e.entryType == CustomerLedgerEntryType.customerPayment.storage,
        )
        .toList();
    expect(payments, hasLength(1));
  });

  test('conflicting payment idempotency rejected', () async {
    final customerId = await customerWithBalance();
    const key = 'cust-pay-conflict';
    final repo = CustomerRepository(catalog.runner);
    await repo.recordCustomerPayment(
      customerId: customerId,
      amountMinor: 500,
      method: SalePaymentMethod.cash,
      idempotencyKey: key,
    );
    await expectLater(
      () => repo.recordCustomerPayment(
        customerId: customerId,
        amountMinor: 600,
        method: SalePaymentMethod.cash,
        idempotencyKey: key,
      ),
      throwsA(
        predicate<SalesConflictException>(
          (e) => e.code == SalesConflictCode.idempotencyConflict,
        ),
      ),
    );
  });
}
