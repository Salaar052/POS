import 'package:drift/drift.dart';
import 'package:pos_mobile/data/repositories/customer_ledger_repository.dart';
import 'package:pos_mobile/data/repositories/customer_repository.dart';
import 'package:pos_mobile/data/repositories/database_runner.dart';
import 'package:pos_mobile/data/repositories/document_sequence_repository.dart';
import 'package:pos_mobile/data/repositories/inventory_repository.dart';
import 'package:pos_mobile/data/repositories/product_repository.dart';
import 'package:pos_mobile/database/app_database.dart';
import 'package:pos_mobile/features/catalog/domain/money_amount.dart';
import 'package:pos_mobile/features/inventory/domain/stock_movement_type.dart';
import 'package:pos_mobile/features/sales/domain/sale_calculations.dart';
import 'package:pos_mobile/features/sales/domain/sales_enums.dart';
import 'package:pos_mobile/features/sales/domain/sales_exceptions.dart';
import 'package:uuid/uuid.dart';

class CheckoutPaymentInput {
  const CheckoutPaymentInput({
    required this.method,
    required this.amountMinor,
    required this.idempotencyKey,
    this.referenceNumber,
    this.notes,
  });

  final SalePaymentMethod method;
  final int amountMinor;
  final String idempotencyKey;
  final String? referenceNumber;
  final String? notes;
}

class SaleReturnLineInput {
  const SaleReturnLineInput({
    required this.saleItemId,
    required this.quantityBase,
  });

  final String saleItemId;
  final int quantityBase;
}

class SalesSummarySnapshot {
  const SalesSummarySnapshot({
    required this.todayCompletedSalesMinor,
    required this.todayCompletedSaleCount,
    required this.todayPaymentsReceivedMinor,
    required this.outstandingReceivablesMinor,
    required this.todayReturnsMinor,
  });

  final int todayCompletedSalesMinor;
  final int todayCompletedSaleCount;
  final int todayPaymentsReceivedMinor;
  final int outstandingReceivablesMinor;
  final int todayReturnsMinor;
}

class SalesRepository {
  SalesRepository(
    this._runner, {
    InventoryRepository? inventory,
    CustomerLedgerRepository? ledger,
    DocumentSequenceRepository? sequences,
    CustomerRepository? customers,
    ProductRepository? products,
  }) : _inventory = inventory ?? InventoryRepository(_runner),
       _ledger = ledger ?? CustomerLedgerRepository(_runner),
       _sequences = sequences ?? DocumentSequenceRepository(_runner),
       _customers = customers ?? CustomerRepository(_runner),
       _products = products ?? ProductRepository(_runner);

  final DatabaseRunner _runner;
  final InventoryRepository _inventory;
  final CustomerLedgerRepository _ledger;
  final DocumentSequenceRepository _sequences;
  final CustomerRepository _customers;
  final ProductRepository _products;
  static const _uuid = Uuid();
  static const refTypeSaleCheckout = 'SALE_CHECKOUT';
  static const refTypeSalePayment = 'SALE_PAYMENT';
  static const refTypeSaleReturn = 'SALE_RETURN';

  Future<SaleRow> createDraft({String? customerId, String? notes}) async {
    final customerName = await _resolveCustomerSnapshot(customerId: customerId);
    return _runner.runInTransaction(() async {
      final number = await _sequences.nextSaleNumber();
      final now = DateTime.now().toUtc().millisecondsSinceEpoch;
      final id = _uuid.v4();
      await _runner.database
          .into(_runner.database.sales)
          .insert(
            SalesCompanion.insert(
              id: id,
              saleNumber: number,
              customerId: Value(customerId),
              customerNameSnapshot: Value(customerName),
              status: SaleStatus.draft.storage,
              subtotalMinor: 0,
              discountMinor: 0,
              totalMinor: 0,
              amountDueMinor: 0,
              notes: Value(notes),
              createdAtMs: now,
              updatedAtMs: now,
            ),
          );
      return (await getSaleById(id))!;
    });
  }

  Future<void> setDraftCustomer({
    required String saleId,
    String? customerId,
  }) async {
    await _requireDraft(saleId);
    final name = await _resolveCustomerSnapshot(customerId: customerId);
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    await (_runner.database.update(
      _runner.database.sales,
    )..where((t) => t.id.equals(saleId))).write(
      SalesCompanion(
        customerId: Value(customerId),
        customerNameSnapshot: Value(name),
        updatedAtMs: Value(now),
      ),
    );
  }

  Future<void> setDraftDiscount({
    required String saleId,
    required int discountMinor,
  }) async {
    final sale = await _requireDraft(saleId);
    MoneyAmount.assertNonNegativeMinor(discountMinor);
    final items = await listSaleItems(saleId);
    final totals = SaleCalculations.saleTotals(
      lineTotalsMinor: items.map((i) => i.lineTotalMinor),
      saleDiscountMinor: discountMinor,
    );
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    await (_runner.database.update(
      _runner.database.sales,
    )..where((t) => t.id.equals(saleId))).write(
      SalesCompanion(
        subtotalMinor: Value(totals.subtotalMinor),
        discountMinor: Value(totals.discountMinor),
        totalMinor: Value(totals.totalMinor),
        amountDueMinor: Value(totals.totalMinor - sale.amountPaidMinor),
        updatedAtMs: Value(now),
      ),
    );
  }

  /// Unit selling price is snapshotted from the product when the line is added.
  Future<SaleItemRow> addDraftItem({
    required String saleId,
    required String productId,
    required int quantityBase,
    int? unitPriceMinor,
    int lineDiscountMinor = 0,
  }) async {
    await _requireDraft(saleId);
    final product = await _products.getById(productId);
    if (product == null || !product.isActive || product.archivedAtMs != null) {
      throw SalesConflictException(
        SalesConflictCode.notFound,
        'Product not found or inactive',
      );
    }
    if (quantityBase <= 0) {
      throw SalesConflictException(
        SalesConflictCode.validation,
        'Quantity must be positive',
      );
    }
    final price = unitPriceMinor ?? product.sellingPriceMinor;
    MoneyAmount.assertNonNegativeMinor(price);
    final lineSub = SaleCalculations.lineSubtotalMinor(
      quantityBase: quantityBase,
      unitPriceMinor: price,
      unit: product.unit,
    );
    final lineTotal = SaleCalculations.lineTotalMinor(
      lineSubtotalMinor: lineSub,
      discountMinor: lineDiscountMinor,
    );
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    final id = _uuid.v4();
    await _runner.runInTransaction(() async {
      await _runner.database
          .into(_runner.database.saleItems)
          .insert(
            SaleItemsCompanion.insert(
              id: id,
              saleId: saleId,
              productId: productId,
              productNameSnapshot: product.name,
              skuSnapshot: Value(product.sku),
              barcodeSnapshot: Value(product.barcode),
              unitSnapshot: product.unit,
              quantityBase: quantityBase,
              unitPriceMinor: price,
              discountMinor: Value(lineDiscountMinor),
              lineTotalMinor: lineTotal,
              createdAtMs: now,
            ),
          );
      await _recomputeSaleTotals(saleId);
    });
    return (await getSaleItemById(id))!;
  }

  Future<SaleItemRow> updateDraftItem({
    required String saleId,
    required String itemId,
    required int quantityBase,
    int? lineDiscountMinor,
  }) async {
    await _requireDraft(saleId);
    final item = await getSaleItemById(itemId);
    if (item == null || item.saleId != saleId) {
      throw SalesConflictException(
        SalesConflictCode.notFound,
        'Sale item not found',
      );
    }
    if (quantityBase <= 0) {
      throw SalesConflictException(
        SalesConflictCode.validation,
        'Quantity must be positive',
      );
    }
    final discount = lineDiscountMinor ?? item.discountMinor;
    final lineSub = SaleCalculations.lineSubtotalMinor(
      quantityBase: quantityBase,
      unitPriceMinor: item.unitPriceMinor,
      unit: item.unitSnapshot,
    );
    final lineTotal = SaleCalculations.lineTotalMinor(
      lineSubtotalMinor: lineSub,
      discountMinor: discount,
    );
    await _runner.runInTransaction(() async {
      await (_runner.database.update(
        _runner.database.saleItems,
      )..where((t) => t.id.equals(itemId))).write(
        SaleItemsCompanion(
          quantityBase: Value(quantityBase),
          discountMinor: Value(discount),
          lineTotalMinor: Value(lineTotal),
        ),
      );
      await _recomputeSaleTotals(saleId);
    });
    return (await getSaleItemById(itemId))!;
  }

  Future<void> removeDraftItem({
    required String saleId,
    required String itemId,
  }) async {
    await _requireDraft(saleId);
    await _runner.runInTransaction(() async {
      await (_runner.database.delete(
        _runner.database.saleItems,
      )..where((t) => t.id.equals(itemId) & t.saleId.equals(saleId))).go();
      await _recomputeSaleTotals(saleId);
    });
  }

  Future<void> cancelDraft(String saleId) async {
    await _requireDraft(saleId);
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    await (_runner.database.update(
      _runner.database.sales,
    )..where((t) => t.id.equals(saleId))).write(
      SalesCompanion(
        status: Value(SaleStatus.cancelled.storage),
        cancelledAtMs: Value(now),
        updatedAtMs: Value(now),
      ),
    );
  }

  Future<SaleRow> checkout({
    required String saleId,
    required String checkoutIdempotencyKey,
    required List<CheckoutPaymentInput> payments,
  }) async {
    return _runner.runInTransaction(() async {
      final sale = await getSaleById(saleId);
      if (sale == null) {
        throw SalesConflictException(
          SalesConflictCode.notFound,
          'Sale not found',
        );
      }
      if (sale.status == SaleStatus.completed.storage) {
        if (sale.checkoutIdempotencyKey == checkoutIdempotencyKey) {
          return sale;
        }
        throw SalesConflictException(
          SalesConflictCode.invalidState,
          'Sale is already completed',
        );
      }
      if (sale.status != SaleStatus.draft.storage) {
        throw SalesConflictException(
          SalesConflictCode.invalidState,
          'Only draft sales can be checked out',
        );
      }
      final items = await listSaleItems(saleId);
      if (items.isEmpty) {
        throw SalesConflictException(
          SalesConflictCode.validation,
          'Add at least one item before checkout',
        );
      }

      await _recomputeSaleTotals(saleId);
      final refreshed = (await getSaleById(saleId))!;
      final totalMinor = refreshed.totalMinor;

      if (payments.isEmpty && refreshed.customerId != null) {
        // Credit sale with no payments at checkout is allowed.
      } else if (payments.isEmpty && refreshed.customerId == null) {
        throw SalesConflictException(
          SalesConflictCode.walkInRequiresFullPayment,
          'Walk-in sales must be fully paid at checkout',
        );
      }

      var paid = 0;
      for (final payment in payments) {
        MoneyAmount.assertNonNegativeMinor(payment.amountMinor);
        if (payment.amountMinor <= 0) {
          throw SalesConflictException(
            SalesConflictCode.validation,
            'Payment amounts must be positive',
          );
        }
        paid += await _validatedCheckoutPaymentAmountMinor(
          saleId: saleId,
          payment: payment,
        );
      }
      if (paid > totalMinor) {
        throw SalesConflictException(
          SalesConflictCode.paymentExceedsDue,
          'Payments exceed sale total',
        );
      }
      if (refreshed.customerId == null && paid != totalMinor) {
        throw SalesConflictException(
          SalesConflictCode.walkInRequiresFullPayment,
          'Walk-in sales must be fully paid at checkout',
        );
      }

      for (final item in items) {
        final product = await _products.getById(item.productId);
        if (product == null ||
            !product.isActive ||
            product.archivedAtMs != null) {
          throw SalesConflictException(
            SalesConflictCode.notFound,
            'Product ${item.productNameSnapshot} is no longer available',
          );
        }
        final onHand = await _inventory.getOnHandBase(item.productId);
        if (onHand < item.quantityBase) {
          throw SalesConflictException(
            SalesConflictCode.insufficientStock,
            'Insufficient stock for ${item.productNameSnapshot}',
          );
        }
      }

      for (final item in items) {
        await _inventory.applyMovementInTransaction(
          ApplyStockMovementRequest(
            productId: item.productId,
            type: StockMovementType.sale,
            quantityBase: item.quantityBase,
            idempotencyKey: checkoutIdempotencyKey,
            referenceType: refTypeSaleCheckout,
            referenceId: '$saleId:${item.id}:$checkoutIdempotencyKey',
            reason: 'Sale ${refreshed.saleNumber}',
          ),
        );
      }

      final now = DateTime.now().toUtc().millisecondsSinceEpoch;
      for (final payment in payments) {
        await _persistCheckoutPayment(
          saleId: saleId,
          payment: payment,
          createdAtMs: now,
          customerId: refreshed.customerId,
          saleNumber: refreshed.saleNumber,
        );
      }
      paid = 0;
      for (final payment in payments) {
        final row =
            await (_runner.database.select(_runner.database.salePayments)
                  ..where(
                    (t) => t.idempotencyKey.equals(payment.idempotencyKey),
                  ))
                .getSingle();
        paid += row.amountMinor;
      }

      if (refreshed.customerId != null && totalMinor > 0) {
        await _ledger.appendEntry(
          customerId: refreshed.customerId!,
          type: CustomerLedgerEntryType.saleReceivable,
          debitMinor: totalMinor,
          creditMinor: 0,
          referenceType: refTypeSaleCheckout,
          referenceId: '$saleId:$checkoutIdempotencyKey',
          notes: refreshed.saleNumber,
        );
      }

      final amountDue = totalMinor - paid;
      await (_runner.database.update(
        _runner.database.sales,
      )..where((t) => t.id.equals(saleId))).write(
        SalesCompanion(
          status: Value(SaleStatus.completed.storage),
          amountPaidMinor: Value(paid),
          amountDueMinor: Value(amountDue),
          checkoutIdempotencyKey: Value(checkoutIdempotencyKey),
          completedAtMs: Value(now),
          updatedAtMs: Value(now),
        ),
      );
      return (await getSaleById(saleId))!;
    });
  }

  Future<SaleReturnRow> returnSale({
    required String saleId,
    required String idempotencyKey,
    required String reason,
    required List<SaleReturnLineInput> lines,
  }) async {
    if (lines.isEmpty) {
      throw SalesConflictException(
        SalesConflictCode.validation,
        'Select at least one return line',
      );
    }
    return _runner.runInTransaction(() async {
      final aggregated = _aggregateReturnLines(lines);

      final existingReturn =
          await (_runner.database.select(_runner.database.saleReturns)
                ..where((t) => t.idempotencyKey.equals(idempotencyKey)))
              .getSingleOrNull();
      if (existingReturn != null) {
        await _assertReturnIdempotency(
          existing: existingReturn,
          saleId: saleId,
          reason: reason,
          aggregatedLines: aggregated,
        );
        return existingReturn;
      }

      final sale = await getSaleById(saleId);
      if (sale == null) {
        throw SalesConflictException(
          SalesConflictCode.notFound,
          'Sale not found',
        );
      }
      if (sale.status != SaleStatus.completed.storage) {
        throw SalesConflictException(
          SalesConflictCode.invalidState,
          'Only completed sales can be returned',
        );
      }

      final returnNumber = await _sequences.nextSaleReturnNumber();
      final returnId = _uuid.v4();
      final now = DateTime.now().toUtc().millisecondsSinceEpoch;
      var totalMinor = 0;
      final planned = <_PlannedReturnLine>[];

      for (final entry in aggregated.entries) {
        final returnQty = entry.value;
        if (returnQty <= 0) {
          throw SalesConflictException(
            SalesConflictCode.validation,
            'Return quantity must be positive',
          );
        }
        final item = await getSaleItemById(entry.key);
        if (item == null || item.saleId != saleId) {
          throw SalesConflictException(
            SalesConflictCode.notFound,
            'Sale item not found',
          );
        }
        final maxReturn = item.quantityBase - item.quantityReturnedBase;
        if (returnQty > maxReturn) {
          throw SalesConflictException(
            SalesConflictCode.returnExceedsEligible,
            'Return quantity exceeds sold quantity for ${item.productNameSnapshot}',
          );
        }
        final lineAfterDiscount =
            (item.lineTotalMinor * returnQty) ~/ item.quantityBase;
        totalMinor += lineAfterDiscount;
        planned.add(
          _PlannedReturnLine(
            item: item,
            quantityBase: returnQty,
            lineTotalMinor: lineAfterDiscount,
          ),
        );
      }

      await _runner.database
          .into(_runner.database.saleReturns)
          .insert(
            SaleReturnsCompanion.insert(
              id: returnId,
              returnNumber: returnNumber,
              saleId: saleId,
              customerId: Value(sale.customerId),
              reason: reason,
              totalMinor: totalMinor,
              status: SaleReturnStatus.completed.storage,
              idempotencyKey: idempotencyKey,
              createdAtMs: now,
              completedAtMs: Value(now),
            ),
          );

      for (final plannedLine in planned) {
        final item = plannedLine.item;
        await _inventory.applyMovementInTransaction(
          ApplyStockMovementRequest(
            productId: item.productId,
            type: StockMovementType.saleReturn,
            quantityBase: plannedLine.quantityBase,
            idempotencyKey: idempotencyKey,
            referenceType: refTypeSaleReturn,
            referenceId: '$returnId:${item.id}',
            reason: reason,
          ),
        );
        await (_runner.database.update(
          _runner.database.saleItems,
        )..where((t) => t.id.equals(item.id))).write(
          SaleItemsCompanion(
            quantityReturnedBase: Value(
              item.quantityReturnedBase + plannedLine.quantityBase,
            ),
          ),
        );
        await _runner.database
            .into(_runner.database.saleReturnItems)
            .insert(
              SaleReturnItemsCompanion.insert(
                id: _uuid.v4(),
                saleReturnId: returnId,
                saleItemId: item.id,
                productId: item.productId,
                quantityBase: plannedLine.quantityBase,
                unitPriceMinor: item.unitPriceMinor,
                lineTotalMinor: plannedLine.lineTotalMinor,
              ),
            );
      }

      if (sale.customerId != null && totalMinor > 0) {
        await _ledger.appendEntry(
          customerId: sale.customerId!,
          type: CustomerLedgerEntryType.saleReturn,
          debitMinor: 0,
          creditMinor: totalMinor,
          referenceType: refTypeSaleReturn,
          referenceId: returnId,
          notes: returnNumber,
        );
      }

      return (await (_runner.database.select(
        _runner.database.saleReturns,
      )..where((t) => t.id.equals(returnId))).getSingle());
    });
  }

  Future<SaleRow?> getSaleById(String id) {
    return (_runner.database.select(
      _runner.database.sales,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<SaleItemRow?> getSaleItemById(String id) {
    return (_runner.database.select(
      _runner.database.saleItems,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<List<SaleItemRow>> listSaleItems(String saleId) {
    return (_runner.database.select(
      _runner.database.saleItems,
    )..where((t) => t.saleId.equals(saleId))).get();
  }

  Future<List<SalePaymentRow>> listSalePayments(String saleId) {
    return (_runner.database.select(
      _runner.database.salePayments,
    )..where((t) => t.saleId.equals(saleId))).get();
  }

  Future<List<SaleRow>> listSales({
    SaleStatus? status,
    String? customerId,
    int limit = 50,
    int offset = 0,
  }) {
    final query = _runner.database.select(_runner.database.sales)
      ..orderBy([(t) => OrderingTerm.desc(t.createdAtMs)])
      ..limit(limit, offset: offset);
    if (status != null) {
      query.where((t) => t.status.equals(status.storage));
    }
    if (customerId != null) {
      query.where((t) => t.customerId.equals(customerId));
    }
    return query.get();
  }

  Future<List<SaleRow>> listSalesForCustomer(String customerId) =>
      listSales(customerId: customerId, limit: 200);

  Future<SalesSummarySnapshot> salesSummaryForToday() async {
    final startOfDay = DateTime.now();
    final dayStartMs = DateTime(
      startOfDay.year,
      startOfDay.month,
      startOfDay.day,
    ).toUtc().millisecondsSinceEpoch;

    final salesToday =
        await (_runner.database.select(_runner.database.sales)..where(
              (t) =>
                  t.status.equals(SaleStatus.completed.storage) &
                  t.completedAtMs.isBiggerOrEqualValue(dayStartMs),
            ))
            .get();
    var salesTotal = 0;
    for (final s in salesToday) {
      salesTotal += s.totalMinor;
    }

    final paymentsToday = await (_runner.database.select(
      _runner.database.salePayments,
    )..where((t) => t.createdAtMs.isBiggerOrEqualValue(dayStartMs))).get();
    var paymentsTotal = 0;
    for (final p in paymentsToday) {
      paymentsTotal += p.amountMinor;
    }

    final returnsToday = await (_runner.database.select(
      _runner.database.saleReturns,
    )..where((t) => t.createdAtMs.isBiggerOrEqualValue(dayStartMs))).get();
    var returnsTotal = 0;
    for (final r in returnsToday) {
      returnsTotal += r.totalMinor;
    }

    final ledger =
        _runner.database.selectOnly(_runner.database.customerLedgerEntries)
          ..addColumns([
            _runner.database.customerLedgerEntries.debitMinor.sum(),
            _runner.database.customerLedgerEntries.creditMinor.sum(),
          ]);
    final ledgerRow = await ledger.getSingle();
    final debit =
        ledgerRow.read(
          _runner.database.customerLedgerEntries.debitMinor.sum(),
        ) ??
        0;
    final credit =
        ledgerRow.read(
          _runner.database.customerLedgerEntries.creditMinor.sum(),
        ) ??
        0;

    return SalesSummarySnapshot(
      todayCompletedSalesMinor: salesTotal,
      todayCompletedSaleCount: salesToday.length,
      todayPaymentsReceivedMinor: paymentsTotal,
      outstandingReceivablesMinor: debit - credit,
      todayReturnsMinor: returnsTotal,
    );
  }

  Future<void> _recomputeSaleTotals(String saleId) async {
    final sale = await getSaleById(saleId);
    if (sale == null) {
      return;
    }
    final items = await listSaleItems(saleId);
    final totals = SaleCalculations.saleTotals(
      lineTotalsMinor: items.map((i) => i.lineTotalMinor),
      saleDiscountMinor: sale.discountMinor,
    );
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    await (_runner.database.update(
      _runner.database.sales,
    )..where((t) => t.id.equals(saleId))).write(
      SalesCompanion(
        subtotalMinor: Value(totals.subtotalMinor),
        totalMinor: Value(totals.totalMinor),
        amountDueMinor: Value(totals.totalMinor - sale.amountPaidMinor),
        updatedAtMs: Value(now),
      ),
    );
  }

  Future<SaleRow> _requireDraft(String saleId) async {
    final sale = await getSaleById(saleId);
    if (sale == null) {
      throw SalesConflictException(
        SalesConflictCode.notFound,
        'Sale not found',
      );
    }
    if (sale.status != SaleStatus.draft.storage) {
      throw SalesConflictException(
        SalesConflictCode.invalidState,
        'Sale is not a draft',
      );
    }
    return sale;
  }

  Map<String, int> _aggregateReturnLines(List<SaleReturnLineInput> lines) {
    final aggregated = <String, int>{};
    for (final line in lines) {
      aggregated[line.saleItemId] =
          (aggregated[line.saleItemId] ?? 0) + line.quantityBase;
    }
    return aggregated;
  }

  Future<void> _assertReturnIdempotency({
    required SaleReturnRow existing,
    required String saleId,
    required String reason,
    required Map<String, int> aggregatedLines,
  }) async {
    if (existing.saleId != saleId) {
      throw SalesConflictException(
        SalesConflictCode.idempotencyConflict,
        'Return idempotency key belongs to another sale',
      );
    }
    if (existing.reason != reason) {
      throw SalesConflictException(
        SalesConflictCode.idempotencyConflict,
        'Return idempotency key reused with a different reason',
      );
    }
    final stored = await listReturnItems(existing.id);
    final storedMap = <String, int>{
      for (final row in stored) row.saleItemId: row.quantityBase,
    };
    if (!_mapsEqual(storedMap, aggregatedLines)) {
      throw SalesConflictException(
        SalesConflictCode.idempotencyConflict,
        'Return idempotency key reused with different return lines',
      );
    }
  }

  bool _mapsEqual(Map<String, int> a, Map<String, int> b) {
    if (a.length != b.length) {
      return false;
    }
    for (final entry in a.entries) {
      if (b[entry.key] != entry.value) {
        return false;
      }
    }
    return true;
  }

  Future<List<SaleReturnItemRow>> listReturnItems(String saleReturnId) {
    return (_runner.database.select(
      _runner.database.saleReturnItems,
    )..where((t) => t.saleReturnId.equals(saleReturnId))).get();
  }

  Future<int> _validatedCheckoutPaymentAmountMinor({
    required String saleId,
    required CheckoutPaymentInput payment,
  }) async {
    final existing =
        await (_runner.database.select(_runner.database.salePayments)
              ..where((t) => t.idempotencyKey.equals(payment.idempotencyKey)))
            .getSingleOrNull();
    if (existing != null) {
      _assertCheckoutPaymentIdempotency(
        existing: existing,
        saleId: saleId,
        payment: payment,
      );
      return existing.amountMinor;
    }
    return payment.amountMinor;
  }

  Future<void> _persistCheckoutPayment({
    required String saleId,
    required CheckoutPaymentInput payment,
    required int createdAtMs,
    String? customerId,
    String? saleNumber,
  }) async {
    final existing =
        await (_runner.database.select(_runner.database.salePayments)
              ..where((t) => t.idempotencyKey.equals(payment.idempotencyKey)))
            .getSingleOrNull();
    if (existing != null) {
      _assertCheckoutPaymentIdempotency(
        existing: existing,
        saleId: saleId,
        payment: payment,
      );
      return;
    }
    final paymentId = _uuid.v4();
    await _runner.database
        .into(_runner.database.salePayments)
        .insert(
          SalePaymentsCompanion.insert(
            id: paymentId,
            saleId: saleId,
            paymentMethod: payment.method.storage,
            amountMinor: payment.amountMinor,
            referenceNumber: Value(payment.referenceNumber),
            notes: Value(payment.notes),
            idempotencyKey: payment.idempotencyKey,
            createdAtMs: createdAtMs,
          ),
        );
    if (customerId != null) {
      await _ledger.appendEntry(
        customerId: customerId,
        type: CustomerLedgerEntryType.customerPayment,
        debitMinor: 0,
        creditMinor: payment.amountMinor,
        referenceType: refTypeSalePayment,
        referenceId: payment.idempotencyKey,
        paymentMethod: payment.method,
        referenceNumber: payment.referenceNumber,
        notes: saleNumber,
      );
    }
  }

  void _assertCheckoutPaymentIdempotency({
    required SalePaymentRow existing,
    required String saleId,
    required CheckoutPaymentInput payment,
  }) {
    if (existing.saleId != saleId) {
      throw SalesConflictException(
        SalesConflictCode.idempotencyConflict,
        'Payment idempotency key belongs to another sale',
      );
    }
    if (existing.amountMinor != payment.amountMinor) {
      throw SalesConflictException(
        SalesConflictCode.idempotencyConflict,
        'Payment idempotency key reused with a different amount',
      );
    }
    if (existing.paymentMethod != payment.method.storage) {
      throw SalesConflictException(
        SalesConflictCode.idempotencyConflict,
        'Payment idempotency key reused with a different method',
      );
    }
    if ((existing.referenceNumber ?? '') != (payment.referenceNumber ?? '')) {
      throw SalesConflictException(
        SalesConflictCode.idempotencyConflict,
        'Payment idempotency key reused with a different reference',
      );
    }
    if ((existing.notes ?? '') != (payment.notes ?? '')) {
      throw SalesConflictException(
        SalesConflictCode.idempotencyConflict,
        'Payment idempotency key reused with different notes',
      );
    }
  }

  Future<String?> _resolveCustomerSnapshot({String? customerId}) async {
    if (customerId == null) {
      return null;
    }
    final customer = await _customers.getById(customerId);
    if (customer == null) {
      throw SalesConflictException(
        SalesConflictCode.notFound,
        'Customer not found',
      );
    }
    return customer.name;
  }
}

class _PlannedReturnLine {
  const _PlannedReturnLine({
    required this.item,
    required this.quantityBase,
    required this.lineTotalMinor,
  });

  final SaleItemRow item;
  final int quantityBase;
  final int lineTotalMinor;
}
