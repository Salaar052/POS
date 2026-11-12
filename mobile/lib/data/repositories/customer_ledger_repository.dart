import 'package:drift/drift.dart';
import 'package:pos_mobile/data/repositories/database_runner.dart';
import 'package:pos_mobile/database/app_database.dart';
import 'package:pos_mobile/features/sales/domain/sales_enums.dart';
import 'package:pos_mobile/features/sales/domain/sales_exceptions.dart';
import 'package:uuid/uuid.dart';

/// Receivable convention: outstanding = sum(debitMinor) - sum(creditMinor).
class CustomerLedgerRepository {
  CustomerLedgerRepository(this._runner);

  final DatabaseRunner _runner;
  static const _uuid = Uuid();

  Future<CustomerLedgerEntryRow?> findByReference({
    required CustomerLedgerEntryType type,
    required String referenceType,
    required String referenceId,
  }) {
    return (_runner.database.select(_runner.database.customerLedgerEntries)
          ..where(
            (t) =>
                t.entryType.equals(type.storage) &
                t.referenceType.equals(referenceType) &
                t.referenceId.equals(referenceId),
          ))
        .getSingleOrNull();
  }

  Future<CustomerLedgerEntryRow> appendEntry({
    required String customerId,
    required CustomerLedgerEntryType type,
    required int debitMinor,
    required int creditMinor,
    required String referenceType,
    required String referenceId,
    String? notes,
  }) async {
    if (debitMinor < 0 || creditMinor < 0) {
      throw SalesConflictException(
        SalesConflictCode.validation,
        'Ledger amounts cannot be negative',
      );
    }
    if (debitMinor == 0 && creditMinor == 0) {
      throw SalesConflictException(
        SalesConflictCode.validation,
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
        .into(_runner.database.customerLedgerEntries)
        .insert(
          CustomerLedgerEntriesCompanion.insert(
            id: id,
            customerId: customerId,
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
      _runner.database.customerLedgerEntries,
    )..where((t) => t.id.equals(id))).getSingle());
  }

  Future<int> outstandingBalanceMinor(String customerId) async {
    final query =
        _runner.database.selectOnly(_runner.database.customerLedgerEntries)
          ..addColumns([
            _runner.database.customerLedgerEntries.debitMinor.sum(),
            _runner.database.customerLedgerEntries.creditMinor.sum(),
          ]);
    query.where(
      _runner.database.customerLedgerEntries.customerId.equals(customerId),
    );
    final row = await query.getSingle();
    final debit =
        row.read(_runner.database.customerLedgerEntries.debitMinor.sum()) ?? 0;
    final credit =
        row.read(_runner.database.customerLedgerEntries.creditMinor.sum()) ?? 0;
    return debit - credit;
  }

  Future<List<CustomerLedgerEntryRow>> listForCustomer(
    String customerId, {
    int limit = 100,
  }) {
    return (_runner.database.select(_runner.database.customerLedgerEntries)
          ..where((t) => t.customerId.equals(customerId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAtMs)])
          ..limit(limit))
        .get();
  }
}
