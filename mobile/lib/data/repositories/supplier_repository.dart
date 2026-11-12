import 'package:drift/drift.dart';
import 'package:pos_mobile/data/repositories/database_runner.dart';
import 'package:pos_mobile/database/app_database.dart';
import 'package:pos_mobile/features/catalog/domain/catalog_normalization.dart';
import 'package:pos_mobile/features/purchasing/domain/purchasing_exceptions.dart';
import 'package:uuid/uuid.dart';

class SupplierRepository {
  SupplierRepository(this._runner);

  final DatabaseRunner _runner;
  static const _uuid = Uuid();

  Future<SupplierRow> createSupplier({
    required String name,
    String? contactPerson,
    String? phone,
    String? email,
    String? address,
    String? taxRegistrationNumber,
    String? notes,
  }) async {
    final displayName = CatalogNormalization.requireCategoryName(name);
    final normalized = CatalogNormalization.normalizeCategoryName(displayName);
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    final id = _uuid.v4();
    await _runner.database
        .into(_runner.database.suppliers)
        .insert(
          SuppliersCompanion.insert(
            id: id,
            name: displayName,
            normalizedName: normalized,
            contactPerson: Value(_trimOrNull(contactPerson)),
            phone: Value(_trimOrNull(phone)),
            email: Value(_trimOrNull(email)),
            address: Value(_trimOrNull(address)),
            taxRegistrationNumber: Value(_trimOrNull(taxRegistrationNumber)),
            notes: Value(_trimOrNull(notes)),
            createdAtMs: now,
            updatedAtMs: now,
          ),
        );
    return (await getById(id))!;
  }

  Future<SupplierRow> updateSupplier({
    required String id,
    required String name,
    String? contactPerson,
    String? phone,
    String? email,
    String? address,
    String? taxRegistrationNumber,
    String? notes,
  }) async {
    final existing = await getById(id);
    if (existing == null) {
      throw PurchasingConflictException(
        PurchasingConflictCode.notFound,
        'Supplier not found',
      );
    }
    final displayName = CatalogNormalization.requireCategoryName(name);
    final normalized = CatalogNormalization.normalizeCategoryName(displayName);
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    await (_runner.database.update(
      _runner.database.suppliers,
    )..where((t) => t.id.equals(id))).write(
      SuppliersCompanion(
        name: Value(displayName),
        normalizedName: Value(normalized),
        contactPerson: Value(_trimOrNull(contactPerson)),
        phone: Value(_trimOrNull(phone)),
        email: Value(_trimOrNull(email)),
        address: Value(_trimOrNull(address)),
        taxRegistrationNumber: Value(_trimOrNull(taxRegistrationNumber)),
        notes: Value(_trimOrNull(notes)),
        updatedAtMs: Value(now),
      ),
    );
    return (await getById(id))!;
  }

  Future<SupplierRow?> getById(String id) {
    return (_runner.database.select(
      _runner.database.suppliers,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<List<SupplierRow>> listSuppliers({
    String? query,
    bool includeArchived = false,
    int limit = 100,
    int offset = 0,
  }) async {
    final select = _runner.database.select(_runner.database.suppliers)
      ..orderBy([(t) => OrderingTerm.asc(t.name)])
      ..limit(limit, offset: offset);
    if (!includeArchived) {
      select.where((t) => t.archivedAtMs.isNull() & t.isActive.equals(true));
    }
    if (query != null && query.trim().isNotEmpty) {
      final pattern = '%${query.trim().toLowerCase()}%';
      select.where(
        (t) =>
            t.normalizedName.like(pattern) |
            t.phone.like(pattern) |
            t.email.like(pattern),
      );
    }
    return select.get();
  }

  Future<SupplierRow> archiveSupplier(String id) async {
    final existing = await getById(id);
    if (existing == null) {
      throw PurchasingConflictException(
        PurchasingConflictCode.notFound,
        'Supplier not found',
      );
    }
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    await (_runner.database.update(
      _runner.database.suppliers,
    )..where((t) => t.id.equals(id))).write(
      SuppliersCompanion(
        isActive: const Value(false),
        archivedAtMs: Value(now),
        updatedAtMs: Value(now),
      ),
    );
    return (await getById(id))!;
  }

  String? _trimOrNull(String? v) {
    if (v == null) {
      return null;
    }
    final t = v.trim();
    return t.isEmpty ? null : t;
  }
}
