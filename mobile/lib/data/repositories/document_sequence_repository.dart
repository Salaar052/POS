import 'package:drift/drift.dart';
import 'package:pos_mobile/data/repositories/database_runner.dart';
import 'package:pos_mobile/database/app_database.dart';

class DocumentSequenceRepository {
  DocumentSequenceRepository(this._runner);

  final DatabaseRunner _runner;

  static const purchaseKey = 'PURCHASE';
  static const purchaseReturnKey = 'PURCHASE_RETURN';
  static const saleKey = 'SALE';
  static const saleReturnKey = 'SALE_RETURN';

  Future<String> nextPurchaseNumber() => _nextFormatted(purchaseKey, 'PO');

  Future<String> nextPurchaseReturnNumber() =>
      _nextFormatted(purchaseReturnKey, 'PR');

  Future<String> nextSaleNumber() => _nextFormatted(saleKey, 'SO');

  Future<String> nextSaleReturnNumber() => _nextFormatted(saleReturnKey, 'SR');

  Future<String> _nextFormatted(String key, String prefix) async {
    final n = await _nextValue(key);
    return '$prefix-${n.toString().padLeft(6, '0')}';
  }

  Future<int> _nextValue(String key) async {
    final existing = await (_runner.database.select(
      _runner.database.documentSequences,
    )..where((t) => t.sequenceKey.equals(key))).getSingleOrNull();
    if (existing == null) {
      await _runner.database
          .into(_runner.database.documentSequences)
          .insert(
            DocumentSequencesCompanion.insert(sequenceKey: key, nextNumber: 2),
          );
      return 1;
    }
    final current = existing.nextNumber;
    await (_runner.database.update(_runner.database.documentSequences)
          ..where((t) => t.sequenceKey.equals(key)))
        .write(DocumentSequencesCompanion(nextNumber: Value(current + 1)));
    return current;
  }

  Future<int> nextValueInTransaction(String key) => _nextValue(key);
}
