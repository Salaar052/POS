import 'package:drift/drift.dart';
import 'package:pos_mobile/data/repositories/database_runner.dart';
import 'package:pos_mobile/database/app_database.dart';

class ReceiptSettingsRepository {
  ReceiptSettingsRepository(this._runner);

  final DatabaseRunner _runner;

  static const singletonKey = 1;

  Future<ReceiptSettingsRow> getSettings() async {
    final row = await (_runner.database.select(
      _runner.database.receiptSettings,
    )..where((t) => t.singletonId.equals(singletonKey))).getSingleOrNull();
    if (row != null) {
      return row;
    }
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    await _runner.database
        .into(_runner.database.receiptSettings)
        .insert(
          ReceiptSettingsCompanion.insert(
            singletonId: Value(singletonKey),
            updatedAtMs: now,
          ),
        );
    return (_runner.database.select(
      _runner.database.receiptSettings,
    )..where((t) => t.singletonId.equals(singletonKey))).getSingle();
  }

  Future<ReceiptSettingsRow> getSettingsInTransaction() => getSettings();

  Future<ReceiptSettingsRow> updateSettings(
    ReceiptSettingsCompanion patch,
  ) async {
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    await getSettings();
    await (_runner.database.update(_runner.database.receiptSettings)
          ..where((t) => t.singletonId.equals(singletonKey)))
        .write(patch.copyWith(updatedAtMs: Value(now)));
    return getSettings();
  }
}
