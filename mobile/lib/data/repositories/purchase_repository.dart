import 'package:drift/drift.dart';
import 'package:pos_mobile/data/repositories/database_runner.dart';
import 'package:pos_mobile/data/repositories/document_sequence_repository.dart';
import 'package:pos_mobile/data/repositories/inventory_repository.dart';
import 'package:pos_mobile/data/repositories/product_repository.dart';
import 'package:pos_mobile/data/repositories/supplier_ledger_repository.dart';
import 'package:pos_mobile/data/repositories/supplier_repository.dart';
import 'package:pos_mobile/database/app_database.dart';
import 'package:pos_mobile/features/catalog/domain/money_amount.dart';
import 'package:pos_mobile/features/inventory/domain/stock_movement_type.dart';
import 'package:pos_mobile/features/purchasing/domain/purchase_calculations.dart';
import 'package:pos_mobile/features/purchasing/domain/purchasing_enums.dart';
import 'package:pos_mobile/features/purchasing/domain/purchasing_exceptions.dart';
import 'package:uuid/uuid.dart';

class PurchaseRepository {
  PurchaseRepository(
    this._runner, {
    InventoryRepository? inventory,
    SupplierLedgerRepository? ledger,
    DocumentSequenceRepository? sequences,
    SupplierRepository? suppliers,
    ProductRepository? products,
  }) : _inventory = inventory ?? InventoryRepository(_runner),
       _ledger = ledger ?? SupplierLedgerRepository(_runner),
       _sequences = sequences ?? DocumentSequenceRepository(_runner),
       _suppliers = suppliers ?? SupplierRepository(_runner),
       _products = products ?? ProductRepository(_runner);

  final DatabaseRunner _runner;
  final InventoryRepository _inventory;
  final SupplierLedgerRepository _ledger;
  final DocumentSequenceRepository _sequences;
  final SupplierRepository _suppliers;
  final ProductRepository _products;
  static const _uuid = Uuid();
  static const refTypePurchaseReceive = 'PURCHASE_RECEIVE';
  static const refTypePurchasePayment = 'PURCHASE_PAYMENT';
  static const refTypePurchaseReturn = 'PURCHASE_RETURN';

  Future<PurchaseRow> createDraft({
    String? supplierId,
    String? walkInSupplierName,
    String? supplierInvoiceNumber,
    String? notes,
    DateTime? purchaseDate,
  }) async {
    final supplierName = await _resolveSupplierSnapshot(
      supplierId: supplierId,
      walkInSupplierName: walkInSupplierName,
    );
    return _runner.runInTransaction(() async {
      final number = await _sequences.nextPurchaseNumber();
      final now = DateTime.now().toUtc().millisecondsSinceEpoch;
      final id = _uuid.v4();
      final dateMs = (purchaseDate ?? DateTime.now())
          .toUtc()
          .millisecondsSinceEpoch;
      await _runner.database
          .into(_runner.database.purchases)
          .insert(
            PurchasesCompanion.insert(
              id: id,
              purchaseNumber: number,
              supplierId: Value(supplierId),
              supplierNameSnapshot: supplierName,
              supplierInvoiceNumber: Value(supplierInvoiceNumber),
              status: PurchaseStatus.draft.storage,
              subtotalMinor: 0,
              discountMinor: 0,
              taxMinor: 0,
              additionalChargesMinor: 0,
              totalMinor: 0,
              amountDueMinor: 0,
              paymentStatus: PurchasePaymentStatus.unpaid.storage,
              notes: Value(notes),
              purchaseDateMs: dateMs,
              createdAtMs: now,
              updatedAtMs: now,
            ),
          );
      return (await getPurchaseById(id))!;
    });
  }

  Future<PurchaseItemRow> addDraftItem({
    required String purchaseId,
    required String productId,
    required int quantityBase,
    required int unitCostMinor,
    int lineDiscountMinor = 0,
    int lineTaxMinor = 0,
  }) async {
    final purchase = await _requireDraft(purchaseId);
    final product = await _products.getById(productId);
    if (product == null) {
      throw PurchasingConflictException(
        PurchasingConflictCode.notFound,
        'Product not found',
      );
    }
    MoneyAmount.assertNonNegativeMinor(unitCostMinor);
    if (quantityBase <= 0) {
      throw PurchasingConflictException(
        PurchasingConflictCode.validation,
        'Quantity must be positive',
      );
    }
    final lineSub = PurchaseCalculations.lineSubtotalMinor(
      quantityBase: quantityBase,
      unitCostMinor: unitCostMinor,
      unit: product.unit,
    );
    final lineTotal = PurchaseCalculations.lineTotalMinor(
      lineSubtotalMinor: lineSub,
      discountMinor: lineDiscountMinor,
      taxMinor: lineTaxMinor,
    );
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    final id = _uuid.v4();
    await _runner.runInTransaction(() async {
      await _runner.database
          .into(_runner.database.purchaseItems)
          .insert(
            PurchaseItemsCompanion.insert(
              id: id,
              purchaseId: purchase.id,
              productId: productId,
              productNameSnapshot: product.name,
              skuSnapshot: Value(product.sku),
              unitSnapshot: product.unit,
              quantityBase: quantityBase,
              unitCostMinor: unitCostMinor,
              discountMinor: Value(lineDiscountMinor),
              taxMinor: Value(lineTaxMinor),
              lineTotalMinor: lineTotal,
              createdAtMs: now,
            ),
          );
      await _recomputePurchaseTotals(purchaseId);
    });
    return (await getPurchaseItemById(id))!;
  }

  Future<void> removeDraftItem({
    required String purchaseId,
    required String itemId,
  }) async {
    await _requireDraft(purchaseId);
    await _runner.runInTransaction(() async {
      await (_runner.database.delete(_runner.database.purchaseItems)..where(
            (t) => t.id.equals(itemId) & t.purchaseId.equals(purchaseId),
          ))
          .go();
      await _recomputePurchaseTotals(purchaseId);
    });
  }

  Future<PurchaseRow> receivePurchase({
    required String purchaseId,
    required String receiveIdempotencyKey,
  }) async {
    return _runner.runInTransaction(() async {
      final purchase = await getPurchaseById(purchaseId);
      if (purchase == null) {
        throw PurchasingConflictException(
          PurchasingConflictCode.notFound,
          'Purchase not found',
        );
      }
      if (purchase.status == PurchaseStatus.received.storage) {
        if (purchase.receiveIdempotencyKey == receiveIdempotencyKey) {
          return purchase;
        }
        throw PurchasingConflictException(
          PurchasingConflictCode.invalidState,
          'Purchase is already received',
        );
      }
      if (purchase.status != PurchaseStatus.draft.storage) {
        throw PurchasingConflictException(
          PurchasingConflictCode.invalidState,
          'Only draft purchases can be received',
        );
      }
      final items = await listPurchaseItems(purchaseId);
      if (items.isEmpty) {
        throw PurchasingConflictException(
          PurchasingConflictCode.validation,
          'Add at least one item before receiving',
        );
      }
      for (final item in items) {
        await _inventory.applyMovementInTransaction(
          ApplyStockMovementRequest(
            productId: item.productId,
            type: StockMovementType.purchaseReceived,
            quantityBase: item.quantityBase,
            idempotencyKey: receiveIdempotencyKey,
            referenceType: refTypePurchaseReceive,
            referenceId: '$purchaseId:${item.id}:$receiveIdempotencyKey',
            reason: 'Purchase ${purchase.purchaseNumber}',
          ),
        );
        await (_runner.database.update(
          _runner.database.purchaseItems,
        )..where((t) => t.id.equals(item.id))).write(
          PurchaseItemsCompanion(
            quantityReceivedBase: Value(item.quantityBase),
          ),
        );
      }
      if (purchase.supplierId != null && purchase.totalMinor > 0) {
        await _ledger.appendEntry(
          supplierId: purchase.supplierId!,
          type: SupplierLedgerEntryType.purchasePayable,
          debitMinor: purchase.totalMinor,
          creditMinor: 0,
          referenceType: refTypePurchaseReceive,
          referenceId: '$purchaseId:$receiveIdempotencyKey',
          notes: purchase.purchaseNumber,
        );
      }
      final now = DateTime.now().toUtc().millisecondsSinceEpoch;
      await (_runner.database.update(
        _runner.database.purchases,
      )..where((t) => t.id.equals(purchaseId))).write(
        PurchasesCompanion(
          status: Value(PurchaseStatus.received.storage),
          receivedAtMs: Value(now),
          updatedAtMs: Value(now),
          receiveIdempotencyKey: Value(receiveIdempotencyKey),
          amountDueMinor: Value(purchase.totalMinor - purchase.amountPaidMinor),
          paymentStatus: Value(
            PurchaseCalculations.paymentStatus(
              totalMinor: purchase.totalMinor,
              amountPaidMinor: purchase.amountPaidMinor,
            ).storage,
          ),
        ),
      );
      return (await getPurchaseById(purchaseId))!;
    });
  }

  Future<PurchasePaymentRow> recordPayment({
    required String purchaseId,
    required int amountMinor,
    required PurchasePaymentMethod method,
    required String idempotencyKey,
    String? referenceNumber,
    String? notes,
  }) async {
    MoneyAmount.assertNonNegativeMinor(amountMinor);
    if (amountMinor <= 0) {
      throw PurchasingConflictException(
        PurchasingConflictCode.validation,
        'Payment amount must be positive',
      );
    }
    return _runner.runInTransaction(() async {
      final purchase = await getPurchaseById(purchaseId);
      if (purchase == null) {
        throw PurchasingConflictException(
          PurchasingConflictCode.notFound,
          'Purchase not found',
        );
      }
      if (purchase.status != PurchaseStatus.received.storage) {
        throw PurchasingConflictException(
          PurchasingConflictCode.invalidState,
          'Payments apply to received purchases only',
        );
      }
      final existing =
          await (_runner.database.select(_runner.database.purchasePayments)
                ..where((t) => t.idempotencyKey.equals(idempotencyKey)))
              .getSingleOrNull();
      if (existing != null) {
        return existing;
      }
      final due = purchase.totalMinor - purchase.amountPaidMinor;
      if (amountMinor > due) {
        throw PurchasingConflictException(
          PurchasingConflictCode.paymentExceedsDue,
          'Payment exceeds outstanding amount',
        );
      }
      if (purchase.supplierId == null) {
        throw PurchasingConflictException(
          PurchasingConflictCode.supplierRequired,
          'Cannot record supplier payment without a supplier',
        );
      }
      final now = DateTime.now().toUtc().millisecondsSinceEpoch;
      final paymentId = _uuid.v4();
      await _runner.database
          .into(_runner.database.purchasePayments)
          .insert(
            PurchasePaymentsCompanion.insert(
              id: paymentId,
              purchaseId: purchaseId,
              paymentMethod: method.storage,
              amountMinor: amountMinor,
              referenceNumber: Value(referenceNumber),
              notes: Value(notes),
              idempotencyKey: idempotencyKey,
              createdAtMs: now,
            ),
          );
      await _ledger.appendEntry(
        supplierId: purchase.supplierId!,
        type: SupplierLedgerEntryType.payment,
        debitMinor: 0,
        creditMinor: amountMinor,
        referenceType: refTypePurchasePayment,
        referenceId: idempotencyKey,
        notes: purchase.purchaseNumber,
      );
      final paid = purchase.amountPaidMinor + amountMinor;
      final newDue = purchase.totalMinor - paid;
      await (_runner.database.update(
        _runner.database.purchases,
      )..where((t) => t.id.equals(purchaseId))).write(
        PurchasesCompanion(
          amountPaidMinor: Value(paid),
          amountDueMinor: Value(newDue),
          paymentStatus: Value(
            PurchaseCalculations.paymentStatus(
              totalMinor: purchase.totalMinor,
              amountPaidMinor: paid,
            ).storage,
          ),
          updatedAtMs: Value(now),
        ),
      );
      return (await (_runner.database.select(
        _runner.database.purchasePayments,
      )..where((t) => t.id.equals(paymentId))).getSingle());
    });
  }

  Future<PurchaseReturnRow> completePurchaseReturn({
    required String purchaseId,
    required String reason,
    required List<PurchaseReturnLineRequest> lines,
    required String idempotencyKey,
  }) async {
    if (lines.isEmpty) {
      throw PurchasingConflictException(
        PurchasingConflictCode.validation,
        'Select at least one item to return',
      );
    }
    return _runner.runInTransaction(() async {
      final existingReturn =
          await (_runner.database.select(_runner.database.purchaseReturns)
                ..where((t) => t.idempotencyKey.equals(idempotencyKey)))
              .getSingleOrNull();
      if (existingReturn != null) {
        return existingReturn;
      }
      final purchase = await getPurchaseById(purchaseId);
      if (purchase == null) {
        throw PurchasingConflictException(
          PurchasingConflictCode.notFound,
          'Purchase not found',
        );
      }
      if (purchase.status != PurchaseStatus.received.storage) {
        throw PurchasingConflictException(
          PurchasingConflictCode.invalidState,
          'Returns apply to received purchases',
        );
      }
      if (purchase.supplierId == null) {
        throw PurchasingConflictException(
          PurchasingConflictCode.supplierRequired,
          'Returns require a registered supplier',
        );
      }
      final returnNumber = await _sequences.nextPurchaseReturnNumber();
      final returnId = _uuid.v4();
      final now = DateTime.now().toUtc().millisecondsSinceEpoch;
      final planned = <_PlannedReturnLine>[];
      var totalMinor = 0;
      for (final line in lines) {
        final item = await getPurchaseItemById(line.purchaseItemId);
        if (item == null || item.purchaseId != purchaseId) {
          throw PurchasingConflictException(
            PurchasingConflictCode.notFound,
            'Purchase item not found',
          );
        }
        final eligible = item.quantityReceivedBase - item.quantityReturnedBase;
        if (line.quantityBase > eligible) {
          throw PurchasingConflictException(
            PurchasingConflictCode.returnExceedsEligible,
            'Return quantity exceeds eligible amount',
          );
        }
        final lineTotal = PurchaseCalculations.lineSubtotalMinor(
          quantityBase: line.quantityBase,
          unitCostMinor: item.unitCostMinor,
          unit: item.unitSnapshot,
        );
        totalMinor += lineTotal;
        planned.add(
          _PlannedReturnLine(
            item: item,
            quantityBase: line.quantityBase,
            lineTotalMinor: lineTotal,
          ),
        );
      }
      await _runner.database
          .into(_runner.database.purchaseReturns)
          .insert(
            PurchaseReturnsCompanion.insert(
              id: returnId,
              returnNumber: returnNumber,
              purchaseId: purchaseId,
              supplierId: purchase.supplierId!,
              reason: reason,
              totalMinor: totalMinor,
              status: PurchaseReturnStatus.completed.storage,
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
            type: StockMovementType.purchaseReturn,
            quantityBase: plannedLine.quantityBase,
            idempotencyKey: idempotencyKey,
            referenceType: refTypePurchaseReturn,
            referenceId: '$returnId:${item.id}',
            reason: reason,
          ),
        );
        await (_runner.database.update(
          _runner.database.purchaseItems,
        )..where((t) => t.id.equals(item.id))).write(
          PurchaseItemsCompanion(
            quantityReturnedBase: Value(
              item.quantityReturnedBase + plannedLine.quantityBase,
            ),
          ),
        );
        await _runner.database
            .into(_runner.database.purchaseReturnItems)
            .insert(
              PurchaseReturnItemsCompanion.insert(
                id: _uuid.v4(),
                purchaseReturnId: returnId,
                purchaseItemId: item.id,
                productId: item.productId,
                quantityBase: plannedLine.quantityBase,
                unitCostMinor: item.unitCostMinor,
                lineTotalMinor: plannedLine.lineTotalMinor,
              ),
            );
      }
      await _ledger.appendEntry(
        supplierId: purchase.supplierId!,
        type: SupplierLedgerEntryType.purchaseReturn,
        debitMinor: 0,
        creditMinor: totalMinor,
        referenceType: refTypePurchaseReturn,
        referenceId: returnId,
        notes: returnNumber,
      );
      return (await (_runner.database.select(
        _runner.database.purchaseReturns,
      )..where((t) => t.id.equals(returnId))).getSingle());
    });
  }

  Future<void> cancelDraft(String purchaseId) async {
    await _requireDraft(purchaseId);
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    await (_runner.database.update(
      _runner.database.purchases,
    )..where((t) => t.id.equals(purchaseId))).write(
      PurchasesCompanion(
        status: Value(PurchaseStatus.cancelled.storage),
        cancelledAtMs: Value(now),
        updatedAtMs: Value(now),
      ),
    );
  }

  Future<PurchaseRow?> getPurchaseById(String id) {
    return (_runner.database.select(
      _runner.database.purchases,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<PurchaseItemRow?> getPurchaseItemById(String id) {
    return (_runner.database.select(
      _runner.database.purchaseItems,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<List<PurchaseItemRow>> listPurchaseItems(String purchaseId) {
    return (_runner.database.select(
      _runner.database.purchaseItems,
    )..where((t) => t.purchaseId.equals(purchaseId))).get();
  }

  Future<List<PurchaseRow>> listPurchases({
    PurchaseStatus? status,
    String? supplierId,
    int limit = 50,
    int offset = 0,
  }) {
    final query = _runner.database.select(_runner.database.purchases)
      ..orderBy([(t) => OrderingTerm.desc(t.purchaseDateMs)])
      ..limit(limit, offset: offset);
    if (status != null) {
      query.where((t) => t.status.equals(status.storage));
    }
    if (supplierId != null) {
      query.where((t) => t.supplierId.equals(supplierId));
    }
    return query.get();
  }

  Future<List<PurchasePaymentRow>> listPayments(String purchaseId) {
    return (_runner.database.select(
      _runner.database.purchasePayments,
    )..where((t) => t.purchaseId.equals(purchaseId))).get();
  }

  Future<PurchaseRow> _requireDraft(String purchaseId) async {
    final purchase = await getPurchaseById(purchaseId);
    if (purchase == null) {
      throw PurchasingConflictException(
        PurchasingConflictCode.notFound,
        'Purchase not found',
      );
    }
    if (purchase.status != PurchaseStatus.draft.storage) {
      throw PurchasingConflictException(
        PurchasingConflictCode.invalidState,
        'Purchase is not a draft',
      );
    }
    return purchase;
  }

  Future<void> _recomputePurchaseTotals(String purchaseId) async {
    final items = await listPurchaseItems(purchaseId);
    final totals = PurchaseCalculations.purchaseTotals(
      lineTotalsMinor: items.map((i) => i.lineTotalMinor),
      purchaseDiscountMinor: 0,
      purchaseTaxMinor: 0,
      additionalChargesMinor: 0,
    );
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    await (_runner.database.update(
      _runner.database.purchases,
    )..where((t) => t.id.equals(purchaseId))).write(
      PurchasesCompanion(
        subtotalMinor: Value(totals.subtotalMinor),
        totalMinor: Value(totals.totalMinor),
        amountDueMinor: Value(totals.totalMinor),
        updatedAtMs: Value(now),
      ),
    );
  }

  Future<String> _resolveSupplierSnapshot({
    String? supplierId,
    String? walkInSupplierName,
  }) async {
    if (supplierId != null) {
      final supplier = await _suppliers.getById(supplierId);
      if (supplier == null) {
        throw PurchasingConflictException(
          PurchasingConflictCode.notFound,
          'Supplier not found',
        );
      }
      return supplier.name;
    }
    final walkIn = walkInSupplierName?.trim();
    if (walkIn == null || walkIn.isEmpty) {
      throw PurchasingConflictException(
        PurchasingConflictCode.validation,
        'Select a supplier or enter a walk-in name',
      );
    }
    return walkIn;
  }
}

class _PlannedReturnLine {
  const _PlannedReturnLine({
    required this.item,
    required this.quantityBase,
    required this.lineTotalMinor,
  });

  final PurchaseItemRow item;
  final int quantityBase;
  final int lineTotalMinor;
}

class PurchaseReturnLineRequest {
  const PurchaseReturnLineRequest({
    required this.purchaseItemId,
    required this.quantityBase,
  });

  final String purchaseItemId;
  final int quantityBase;
}
