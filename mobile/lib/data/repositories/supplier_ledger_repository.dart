import 'package:drift/drift.dart';
import 'package:pos_mobile/data/repositories/database_runner.dart';
import 'package:pos_mobile/database/app_database.dart';
import 'package:pos_mobile/features/purchasing/domain/purchasing_enums.dart';
import 'package:pos_mobile/features/purchasing/domain/purchasing_exceptions.dart';
import 'package:uuid/uuid.dart';

/// Payable convention: outstanding = sum(debitMinor) - sum(creditMinor).
class SupplierLedgerRepository {
  SupplierLedgerRepository(this._runner);

  final DatabaseRunner _runner;
  static const _uuid = Uuid();

  Future<SupplierLedgerEntryRow?> findByReference({
    required SupplierLedgerEntryType type,
    required String referenceType,
    required String referenceId,
  }) {
    return (_runner.database.select(_runner.database.supplierLedgerEntries)
          ..where(
            (t) =>
                t.entryType.equals(type.storage) &
                t.referenceType.equals(referenceType) &
                t.referenceId.equals(referenceId),
          ))
        .getSingleOrNull();
  }

  Future<SupplierLedgerEntryRow> appendEntry({
    required String supplierId,
    required SupplierLedgerEntryType type,
    required int debitMinor,
    required int creditMinor,
    required String referenceType,
    required String referenceId,
    String? notes,
  }) async {
    if (debitMinor < 0 || creditMinor < 0) {
      throw PurchasingConflictException(
        PurchasingConflictCode.validation,
        'Ledger amounts cannot be negative',
      );
    }
    if (debitMinor == 0 && creditMinor == 0) {
      throw PurchasingConflictException(
        PurchasingConflictCode.validation,
        'Ledger entry must have a debit or credit',
      );
    }
    final dup = await findByReference(
      type: type,
      referenceType: referenceType,
      referenceId: referenceId,
    );
    if (dup != null) {
      return dup;
    }
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    final id = _uuid.v4();
    await _runner.database
        .into(_runner.database.supplierLedgerEntries)
        .insert(
          SupplierLedgerEntriesCompanion.insert(
            id: id,
            supplierId: supplierId,
            entryType: type.storage,
            debitMinor: Value(debitMinor),
            creditMinor: Value(creditMinor),
            referenceType: referenceType,
            referenceId: referenceId,
            notes: Value(notes),
            createdAtMs: now,
          ),
        );
    return (await (_runner.database.select(
      _runner.database.supplierLedgerEntries,
    )..where((t) => t.id.equals(id))).getSingle());
  }

  Future<int> outstandingBalanceMinor(String supplierId) async {
    final query =
        _runner.database.selectOnly(_runner.database.supplierLedgerEntries)
          ..addColumns([
            _runner.database.supplierLedgerEntries.debitMinor.sum(),
            _runner.database.supplierLedgerEntries.creditMinor.sum(),
          ]);
    query.where(
      _runner.database.supplierLedgerEntries.supplierId.equals(supplierId),
    );
    final row = await query.getSingle();
    final debit =
        row.read(_runner.database.supplierLedgerEntries.debitMinor.sum()) ?? 0;
    final credit =
        row.read(_runner.database.supplierLedgerEntries.creditMinor.sum()) ?? 0;
    return debit - credit;
  }

  Future<List<SupplierLedgerEntryRow>> listForSupplier(
    String supplierId, {
    int limit = 100,
  }) {
    return (_runner.database.select(_runner.database.supplierLedgerEntries)
          ..where((t) => t.supplierId.equals(supplierId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAtMs)])
          ..limit(limit))
        .get();
  }
}
