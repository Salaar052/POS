import 'package:drift/drift.dart';
import 'package:pos_mobile/data/repositories/database_runner.dart';
import 'package:pos_mobile/database/app_database.dart';
import 'package:pos_mobile/features/catalog/domain/catalog_exceptions.dart';
import 'package:pos_mobile/features/catalog/domain/catalog_normalization.dart';
import 'package:pos_mobile/features/catalog/domain/money_amount.dart';
import 'package:uuid/uuid.dart';

class ProductListQuery {
  const ProductListQuery({
    this.nameQuery,
    this.categoryId,
    this.archiveFilter = ProductArchiveFilter.activeOnly,
    this.limit = 50,
    this.offset = 0,
  });

  final String? nameQuery;
  final String? categoryId;
  final ProductArchiveFilter archiveFilter;
  final int limit;
  final int offset;
}

class ProductRepository {
  ProductRepository(this._runner);

  final DatabaseRunner _runner;
  static const _uuid = Uuid();

  Future<ProductRow> createProduct({
    required String name,
    String? description,
    String? sku,
    String? barcode,
    String? categoryId,
    required int costPriceMinor,
    required int sellingPriceMinor,
    String unit = 'each',
  }) async {
    final displayName = CatalogNormalization.requireProductName(name);
    MoneyAmount.assertNonNegativeMinor(costPriceMinor);
    MoneyAmount.assertNonNegativeMinor(sellingPriceMinor);
    final skuNorm = CatalogNormalization.normalizeSku(sku);
    final barcodeNorm = CatalogNormalization.normalizeBarcode(barcode);
    await _validateCategoryId(categoryId);
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    final id = _uuid.v4();

    return _runner.runInTransaction(() async {
      await _assertUniqueActiveIdentifiers(
        skuNormalized: skuNorm,
        barcodeNormalized: barcodeNorm,
        ignoreProductId: null,
      );
      await _runner.database
          .into(_runner.database.products)
          .insert(
            ProductsCompanion.insert(
              id: id,
              name: displayName,
              description: Value(_optionalText(description)),
              sku: Value(skuNorm != null ? sku?.trim() : null),
              skuNormalized: Value(skuNorm),
              barcode: Value(barcodeNorm != null ? barcode?.trim() : null),
              barcodeNormalized: Value(barcodeNorm),
              categoryId: Value(categoryId),
              costPriceMinor: costPriceMinor,
              sellingPriceMinor: sellingPriceMinor,
              unit: Value(_normalizeUnit(unit)),
              createdAtMs: now,
              updatedAtMs: now,
            ),
          );
      return (await getById(id))!;
    });
  }

  Future<ProductRow> updateProduct({
    required String id,
    required String name,
    String? description,
    String? sku,
    String? barcode,
    String? categoryId,
    required int costPriceMinor,
    required int sellingPriceMinor,
    String unit = 'each',
  }) async {
    final existing = await getById(id);
    if (existing == null) {
      throw CatalogConflictException(
        CatalogConflictCode.productNotFound,
        'Product not found',
      );
    }
    final displayName = CatalogNormalization.requireProductName(name);
    MoneyAmount.assertNonNegativeMinor(costPriceMinor);
    MoneyAmount.assertNonNegativeMinor(sellingPriceMinor);
    final skuNorm = CatalogNormalization.normalizeSku(sku);
    final barcodeNorm = CatalogNormalization.normalizeBarcode(barcode);
    await _validateCategoryId(categoryId);
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;

    return _runner.runInTransaction(() async {
      await _assertUniqueActiveIdentifiers(
        skuNormalized: skuNorm,
        barcodeNormalized: barcodeNorm,
        ignoreProductId: id,
      );
      await (_runner.database.update(
        _runner.database.products,
      )..where((t) => t.id.equals(id))).write(
        ProductsCompanion(
          name: Value(displayName),
          description: Value(_optionalText(description)),
          sku: Value(skuNorm != null ? sku?.trim() : null),
          skuNormalized: Value(skuNorm),
          barcode: Value(barcodeNorm != null ? barcode?.trim() : null),
          barcodeNormalized: Value(barcodeNorm),
          categoryId: Value(categoryId),
          costPriceMinor: Value(costPriceMinor),
          sellingPriceMinor: Value(sellingPriceMinor),
          unit: Value(_normalizeUnit(unit)),
          updatedAtMs: Value(now),
        ),
      );
      return (await getById(id))!;
    });
  }

  Future<ProductRow?> getById(String id) {
    return (_runner.database.select(
      _runner.database.products,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<List<ProductRow>> listProducts(ProductListQuery query) async {
    final select = _runner.database.select(_runner.database.products)
      ..orderBy([(t) => OrderingTerm.asc(t.name)])
      ..limit(query.limit, offset: query.offset)
      ..where((t) => _matchesListQuery(t, query));
    return select.get();
  }

  Future<int> countProducts(ProductListQuery query) async {
    final table = _runner.database.products;
    final select = _runner.database.selectOnly(table)
      ..addColumns([table.id.count()])
      ..where(_matchesListQuery(table, query));
    final row = await select.getSingle();
    return row.read(table.id.count()) ?? 0;
  }

  Expression<bool> _matchesListQuery($ProductsTable t, ProductListQuery query) {
    var expr = _archiveFilterClause(t, query.archiveFilter);
    if (query.categoryId != null) {
      expr = expr & t.categoryId.equals(query.categoryId!);
    }
    if (query.nameQuery != null && query.nameQuery!.trim().isNotEmpty) {
      final pattern = '%${query.nameQuery!.trim().toLowerCase()}%';
      expr = expr & t.name.lower().like(pattern);
    }
    return expr;
  }

  Future<ProductRow?> findBySku(String sku) async {
    final norm = CatalogNormalization.normalizeSku(sku);
    if (norm == null) {
      return null;
    }
    return (_runner.database.select(_runner.database.products)..where(
          (t) =>
              t.skuNormalized.equals(norm) &
              t.archivedAtMs.isNull() &
              t.isActive.equals(true),
        ))
        .getSingleOrNull();
  }

  Future<ProductRow?> findByBarcode(String barcode) async {
    final norm = CatalogNormalization.normalizeBarcode(barcode);
    if (norm == null) {
      return null;
    }
    return (_runner.database.select(_runner.database.products)..where(
          (t) =>
              t.barcodeNormalized.equals(norm) &
              t.archivedAtMs.isNull() &
              t.isActive.equals(true),
        ))
        .getSingleOrNull();
  }

  Future<List<ProductRow>> searchByName(String query, {int limit = 50}) {
    return listProducts(
      ProductListQuery(
        nameQuery: query,
        limit: limit,
        archiveFilter: ProductArchiveFilter.activeOnly,
      ),
    );
  }

  Future<ProductRow> archiveProduct(String id) async {
    final existing = await getById(id);
    if (existing == null) {
      throw CatalogConflictException(
        CatalogConflictCode.productNotFound,
        'Product not found',
      );
    }
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    await (_runner.database.update(
      _runner.database.products,
    )..where((t) => t.id.equals(id))).write(
      ProductsCompanion(
        isActive: const Value(false),
        archivedAtMs: Value(now),
        updatedAtMs: Value(now),
      ),
    );
    return (await getById(id))!;
  }

  Future<ProductRow> restoreProduct(String id) async {
    final existing = await getById(id);
    if (existing == null) {
      throw CatalogConflictException(
        CatalogConflictCode.productNotFound,
        'Product not found',
      );
    }
    final skuNorm = existing.skuNormalized;
    final barcodeNorm = existing.barcodeNormalized;
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;

    return _runner.runInTransaction(() async {
      await _assertUniqueActiveIdentifiers(
        skuNormalized: skuNorm,
        barcodeNormalized: barcodeNorm,
        ignoreProductId: id,
      );
      await (_runner.database.update(
        _runner.database.products,
      )..where((t) => t.id.equals(id))).write(
        ProductsCompanion(
          isActive: const Value(true),
          archivedAtMs: const Value(null),
          updatedAtMs: Value(now),
        ),
      );
      return (await getById(id))!;
    });
  }

  Expression<bool> _archiveFilterClause(
    $ProductsTable t,
    ProductArchiveFilter filter,
  ) {
    return switch (filter) {
      ProductArchiveFilter.activeOnly =>
        t.archivedAtMs.isNull() & t.isActive.equals(true),
      ProductArchiveFilter.archivedOnly =>
        t.archivedAtMs.isNotNull() | t.isActive.equals(false),
      ProductArchiveFilter.all => const Constant(true),
    };
  }

  String? _optionalText(String? raw) {
    if (raw == null) {
      return null;
    }
    final trimmed = raw.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  String _normalizeUnit(String unit) {
    final normalized = unit.trim().toLowerCase();
    if (!catalogProductUnits.contains(normalized)) {
      throw const CatalogValidationException('Unsupported unit');
    }
    return normalized;
  }

  Future<void> _validateCategoryId(String? categoryId) async {
    if (categoryId == null) {
      return;
    }
    final category = await (_runner.database.select(
      _runner.database.productCategories,
    )..where((t) => t.id.equals(categoryId))).getSingleOrNull();
    if (category == null) {
      throw CatalogConflictException(
        CatalogConflictCode.categoryNotFound,
        'Selected category was not found',
      );
    }
  }

  Future<void> _assertUniqueActiveIdentifiers({
    required String? skuNormalized,
    required String? barcodeNormalized,
    required String? ignoreProductId,
  }) async {
    if (skuNormalized != null) {
      final existing = await findBySku(skuNormalized);
      if (existing != null && existing.id != ignoreProductId) {
        throw CatalogConflictException(
          CatalogConflictCode.duplicateSku,
          'Another product already uses this SKU',
        );
      }
    }
    if (barcodeNormalized != null) {
      final existing = await findByBarcode(barcodeNormalized);
      if (existing != null && existing.id != ignoreProductId) {
        throw CatalogConflictException(
          CatalogConflictCode.duplicateBarcode,
          'Another product already uses this barcode',
        );
      }
    }
  }
}
