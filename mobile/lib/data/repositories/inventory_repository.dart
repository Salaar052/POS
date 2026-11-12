import 'package:drift/drift.dart';
import 'package:pos_mobile/data/repositories/database_runner.dart';
import 'package:pos_mobile/data/repositories/product_repository.dart';
import 'package:pos_mobile/database/app_database.dart';
import 'package:pos_mobile/features/inventory/domain/inventory_exceptions.dart';
import 'package:pos_mobile/features/inventory/domain/stock_movement_type.dart';
import 'package:uuid/uuid.dart';

class InventoryOverviewRow {
  const InventoryOverviewRow({
    required this.product,
    required this.quantityOnHandBase,
    required this.minimumStockBase,
    required this.status,
  });

  final ProductRow product;
  final int quantityOnHandBase;
  final int? minimumStockBase;
  final StockStatus status;
}

class ApplyStockMovementRequest {
  const ApplyStockMovementRequest({
    required this.productId,
    required this.type,
    required this.quantityBase,
    required this.idempotencyKey,
    this.referenceType,
    this.referenceId,
    this.reason,
    this.notes,
    this.createdBy,
  });

  final String productId;
  final StockMovementType type;
  final int quantityBase;
  final String idempotencyKey;
  final String? referenceType;
  final String? referenceId;
  final String? reason;
  final String? notes;
  final String? createdBy;
}

class InventoryRepository {
  InventoryRepository(this._runner);

  final DatabaseRunner _runner;
  static const _uuid = Uuid();
  static const refTypeManual = 'MANUAL_IDEMPOTENCY';

  Future<StockMovementRow> recordOpeningStock({
    required String productId,
    required int quantityBase,
    required String idempotencyKey,
    String? reason,
    String? createdBy,
  }) {
    return applyMovement(
      ApplyStockMovementRequest(
        productId: productId,
        type: StockMovementType.openingStock,
        quantityBase: quantityBase,
        idempotencyKey: idempotencyKey,
        reason: reason ?? 'Opening stock',
        createdBy: createdBy,
      ),
    );
  }

  Future<StockMovementRow> recordAdjustmentIn({
    required String productId,
    required int quantityBase,
    required String idempotencyKey,
    required String reason,
    String? createdBy,
  }) {
    return applyMovement(
      ApplyStockMovementRequest(
        productId: productId,
        type: StockMovementType.adjustmentIn,
        quantityBase: quantityBase,
        idempotencyKey: idempotencyKey,
        reason: reason,
        createdBy: createdBy,
      ),
    );
  }

  Future<StockMovementRow> recordAdjustmentOut({
    required String productId,
    required int quantityBase,
    required String idempotencyKey,
    required String reason,
    String? createdBy,
  }) {
    return applyMovement(
      ApplyStockMovementRequest(
        productId: productId,
        type: StockMovementType.adjustmentOut,
        quantityBase: quantityBase,
        idempotencyKey: idempotencyKey,
        reason: reason,
        createdBy: createdBy,
      ),
    );
  }

  Future<StockMovementRow> recordDamage({
    required String productId,
    required int quantityBase,
    required String idempotencyKey,
    required String reason,
    String? createdBy,
  }) {
    return applyMovement(
      ApplyStockMovementRequest(
        productId: productId,
        type: StockMovementType.damage,
        quantityBase: quantityBase,
        idempotencyKey: idempotencyKey,
        reason: reason,
        createdBy: createdBy,
      ),
    );
  }

  Future<StockMovementRow> recordExpired({
    required String productId,
    required int quantityBase,
    required String idempotencyKey,
    required String reason,
    String? createdBy,
  }) {
    return applyMovement(
      ApplyStockMovementRequest(
        productId: productId,
        type: StockMovementType.expired,
        quantityBase: quantityBase,
        idempotencyKey: idempotencyKey,
        reason: reason,
        createdBy: createdBy,
      ),
    );
  }

  Future<StockMovementRow> applyMovement(
    ApplyStockMovementRequest request,
  ) async {
    if (request.quantityBase <= 0) {
      throw InventoryConflictException(
        InventoryConflictCode.invalidQuantity,
        'Movement quantity must be positive',
      );
    }
    return _runner.runInTransaction(() => applyMovementInTransaction(request));
  }

  /// Applies a movement when the caller already holds a [DatabaseRunner] transaction.
  Future<StockMovementRow> applyMovementInTransaction(
    ApplyStockMovementRequest request,
  ) async {
    if (request.quantityBase <= 0) {
      throw InventoryConflictException(
        InventoryConflictCode.invalidQuantity,
        'Movement quantity must be positive',
      );
    }
    final product = await (_runner.database.select(
      _runner.database.products,
    )..where((t) => t.id.equals(request.productId))).getSingleOrNull();
    if (product == null) {
      throw InventoryConflictException(
        InventoryConflictCode.productNotFound,
        'Product not found',
      );
    }

    final refType = request.referenceType ?? refTypeManual;
    final refId = request.referenceId ?? request.idempotencyKey;
    final dup = await _findDuplicateReference(
      productId: request.productId,
      movementType: request.type,
      referenceType: refType,
      referenceId: refId,
    );
    if (dup != null) {
      return dup;
    }

    final balance = await _getOrCreateBalance(request.productId);
    final previous = balance.quantityOnHandBase;
    final delta = _signedDelta(request.type, request.quantityBase);
    final resulting = previous + delta;
    if (resulting < 0) {
      throw InventoryConflictException(
        InventoryConflictCode.insufficientStock,
        'Insufficient stock for this operation',
      );
    }

    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    final movementId = _uuid.v4();
    await _runner.database
        .into(_runner.database.stockMovements)
        .insert(
          StockMovementsCompanion.insert(
            id: movementId,
            productId: request.productId,
            movementType: request.type.storageValue,
            quantityBase: request.quantityBase,
            previousQuantityBase: previous,
            resultingQuantityBase: resulting,
            referenceType: Value(refType),
            referenceId: Value(refId),
            reason: Value(request.reason),
            notes: Value(request.notes),
            createdBy: Value(request.createdBy),
            createdAtMs: now,
          ),
        );

    await (_runner.database.update(
      _runner.database.inventoryBalances,
    )..where((t) => t.productId.equals(request.productId))).write(
      InventoryBalancesCompanion(
        quantityOnHandBase: Value(resulting),
        updatedAtMs: Value(now),
      ),
    );

    return (await _movementById(movementId))!;
  }

  Future<StockMovementRow> reverseMovement({
    required String movementId,
    required String idempotencyKey,
    String? reason,
    String? createdBy,
  }) async {
    final original = await _movementById(movementId);
    if (original == null) {
      throw InventoryConflictException(
        InventoryConflictCode.movementNotFound,
        'Movement not found',
      );
    }
    final originalType = StockMovementType.fromStorage(original.movementType);
    final compensating = StockMovementType.inboundPartner(originalType);
    return applyMovement(
      ApplyStockMovementRequest(
        productId: original.productId,
        type: compensating,
        quantityBase: original.quantityBase,
        idempotencyKey: idempotencyKey,
        referenceType: 'STOCK_MOVEMENT_REVERSAL',
        referenceId: movementId,
        reason: reason ?? 'Reversal of ${originalType.storageValue}',
        createdBy: createdBy,
        notes: 'Compensates movement $movementId',
      ),
    );
  }

  Future<void> setMinimumStock({
    required String productId,
    int? minimumStockBase,
  }) async {
    await _getOrCreateBalance(productId);
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    await (_runner.database.update(
      _runner.database.inventoryBalances,
    )..where((t) => t.productId.equals(productId))).write(
      InventoryBalancesCompanion(
        minimumStockBase: Value(minimumStockBase),
        updatedAtMs: Value(now),
      ),
    );
  }

  Future<int> getOnHandBase(String productId) async {
    final row = await (_runner.database.select(
      _runner.database.inventoryBalances,
    )..where((t) => t.productId.equals(productId))).getSingleOrNull();
    return row?.quantityOnHandBase ?? 0;
  }

  Future<List<StockMovementRow>> listMovements(
    String productId, {
    int limit = 100,
    int offset = 0,
  }) {
    return (_runner.database.select(_runner.database.stockMovements)
          ..where((t) => t.productId.equals(productId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAtMs)])
          ..limit(limit, offset: offset))
        .get();
  }

  Future<List<InventoryOverviewRow>> listOverview({
    String? nameQuery,
    String? categoryId,
    StockStatus? statusFilter,
    int limit = 50,
    int offset = 0,
  }) async {
    final productQuery = ProductListQuery(
      nameQuery: nameQuery,
      categoryId: categoryId,
      limit: limit,
      offset: offset,
    );
    final products = await ProductRepository(_runner)
        .listProducts(productQuery);
    final rows = <InventoryOverviewRow>[];
    for (final product in products) {
      final balance = await (_runner.database.select(
        _runner.database.inventoryBalances,
      )..where((t) => t.productId.equals(product.id))).getSingleOrNull();
      final qty = balance?.quantityOnHandBase ?? 0;
      final min = balance?.minimumStockBase;
      final status = _statusFor(qty, min);
      if (statusFilter != null && status != statusFilter) {
        continue;
      }
      rows.add(
        InventoryOverviewRow(
          product: product,
          quantityOnHandBase: qty,
          minimumStockBase: min,
          status: status,
        ),
      );
    }
    return rows;
  }

  StockStatus _statusFor(int onHand, int? minimum) {
    if (onHand <= 0) {
      return StockStatus.outOfStock;
    }
    if (minimum == null) {
      return StockStatus.notConfigured;
    }
    if (onHand <= minimum) {
      return StockStatus.lowStock;
    }
    return StockStatus.inStock;
  }

  int _signedDelta(StockMovementType type, int quantityBase) {
    if (type == StockMovementType.reversal) {
      throw InventoryConflictException(
        InventoryConflictCode.invalidQuantity,
        'Use reverseMovement() for reversals',
      );
    }
    return type.isInbound ? quantityBase : -quantityBase;
  }

  Future<StockMovementRow?> _findDuplicateReference({
    required String productId,
    required StockMovementType movementType,
    required String referenceType,
    required String referenceId,
  }) {
    return (_runner.database.select(_runner.database.stockMovements)..where(
          (t) =>
              t.productId.equals(productId) &
              t.movementType.equals(movementType.storageValue) &
              t.referenceType.equals(referenceType) &
              t.referenceId.equals(referenceId),
        ))
        .getSingleOrNull();
  }

  Future<InventoryBalanceRow> _getOrCreateBalance(String productId) async {
    final existing = await (_runner.database.select(
      _runner.database.inventoryBalances,
    )..where((t) => t.productId.equals(productId))).getSingleOrNull();
    if (existing != null) {
      return existing;
    }
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    await _runner.database
        .into(_runner.database.inventoryBalances)
        .insert(
          InventoryBalancesCompanion.insert(
            productId: productId,
            quantityOnHandBase: const Value(0),
            updatedAtMs: now,
          ),
        );
    return (await (_runner.database.select(
      _runner.database.inventoryBalances,
    )..where((t) => t.productId.equals(productId))).getSingle());
  }

  Future<StockMovementRow?> _movementById(String id) {
    return (_runner.database.select(
      _runner.database.stockMovements,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }
}
