import 'package:drift/drift.dart';
import 'package:pos_mobile/data/repositories/database_runner.dart';
import 'package:pos_mobile/database/app_database.dart';
import 'package:pos_mobile/features/catalog/domain/catalog_exceptions.dart';
import 'package:pos_mobile/features/catalog/domain/catalog_normalization.dart';
import 'package:uuid/uuid.dart';

class CategoryWithProductCount {
  const CategoryWithProductCount({
    required this.category,
    required this.productCount,
    required this.activeProductCount,
  });

  final ProductCategoryRow category;
  final int productCount;
  final int activeProductCount;
}

class ProductCategoryRepository {
  ProductCategoryRepository(this._runner);

  final DatabaseRunner _runner;
  static const _uuid = Uuid();

  Future<ProductCategoryRow> createCategory({
    required String name,
    String? description,
  }) async {
    final displayName = CatalogNormalization.requireCategoryName(name);
    final normalizedName = CatalogNormalization.normalizeCategoryName(
      displayName,
    );
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    final id = _uuid.v4();

    return _runner.runInTransaction(() async {
      await _assertNoActiveDuplicate(normalizedName, ignoreId: null);
      await _runner.database
          .into(_runner.database.productCategories)
          .insert(
            ProductCategoriesCompanion.insert(
              id: id,
              name: displayName,
              normalizedName: normalizedName,
              description: Value(
                description?.trim().isEmpty ?? true
                    ? null
                    : description!.trim(),
              ),
              createdAtMs: now,
              updatedAtMs: now,
            ),
          );
      return (await getById(id))!;
    });
  }

  Future<ProductCategoryRow> updateCategory({
    required String id,
    required String name,
    String? description,
  }) async {
    final existing = await getById(id);
    if (existing == null) {
      throw CatalogConflictException(
        CatalogConflictCode.categoryNotFound,
        'Category not found',
      );
    }
    final displayName = CatalogNormalization.requireCategoryName(name);
    final normalizedName = CatalogNormalization.normalizeCategoryName(
      displayName,
    );
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;

    return _runner.runInTransaction(() async {
      await _assertNoActiveDuplicate(normalizedName, ignoreId: id);
      await (_runner.database.update(
        _runner.database.productCategories,
      )..where((t) => t.id.equals(id))).write(
        ProductCategoriesCompanion(
          name: Value(displayName),
          normalizedName: Value(normalizedName),
          description: Value(
            description?.trim().isEmpty ?? true ? null : description?.trim(),
          ),
          updatedAtMs: Value(now),
        ),
      );
      return (await getById(id))!;
    });
  }

  Future<List<ProductCategoryRow>> listCategories({
    bool includeArchived = false,
  }) async {
    final query = _runner.database.select(_runner.database.productCategories)
      ..orderBy([(t) => OrderingTerm.asc(t.name)]);
    if (!includeArchived) {
      query.where((t) => t.archivedAtMs.isNull() & t.isActive.equals(true));
    }
    return query.get();
  }

  Future<ProductCategoryRow?> getById(String id) {
    return (_runner.database.select(
      _runner.database.productCategories,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<CategoryWithProductCount> getWithProductCounts(String id) async {
    final category = await getById(id);
    if (category == null) {
      throw CatalogConflictException(
        CatalogConflictCode.categoryNotFound,
        'Category not found',
      );
    }
    final total = await _countProducts(categoryId: id, activeOnly: false);
    final active = await _countProducts(categoryId: id, activeOnly: true);
    return CategoryWithProductCount(
      category: category,
      productCount: total,
      activeProductCount: active,
    );
  }

  Future<ProductCategoryRow> archiveCategory(String id) async {
    final existing = await getById(id);
    if (existing == null) {
      throw CatalogConflictException(
        CatalogConflictCode.categoryNotFound,
        'Category not found',
      );
    }
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    await (_runner.database.update(
      _runner.database.productCategories,
    )..where((t) => t.id.equals(id))).write(
      ProductCategoriesCompanion(
        isActive: const Value(false),
        archivedAtMs: Value(now),
        updatedAtMs: Value(now),
      ),
    );
    return (await getById(id))!;
  }

  Future<void> _assertNoActiveDuplicate(
    String normalizedName, {
    required String? ignoreId,
  }) async {
    final query = _runner.database.select(_runner.database.productCategories)
      ..where((t) {
        var expr =
            t.normalizedName.equals(normalizedName) &
            t.archivedAtMs.isNull() &
            t.isActive.equals(true);
        if (ignoreId != null) {
          expr = expr & t.id.equals(ignoreId).not();
        }
        return expr;
      });
    final match = await query.getSingleOrNull();
    if (match != null) {
      throw CatalogConflictException(
        CatalogConflictCode.duplicateCategoryName,
        'A category with this name already exists',
      );
    }
  }

  Future<int> _countProducts({
    required String categoryId,
    required bool activeOnly,
  }) async {
    final query = _runner.database.selectOnly(_runner.database.products)
      ..addColumns([_runner.database.products.id.count()]);
    query.where(_runner.database.products.categoryId.equals(categoryId));
    if (activeOnly) {
      query.where(
        _runner.database.products.archivedAtMs.isNull() &
            _runner.database.products.isActive.equals(true),
      );
    }
    final row = await query.getSingle();
    return row.read(_runner.database.products.id.count()) ?? 0;
  }
}
