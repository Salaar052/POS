import 'package:drift/drift.dart';
import 'package:pos_mobile/database/app_database.dart';
import 'package:pos_mobile/database/validators/json_validator.dart';
import 'package:pos_mobile/data/repositories/database_runner.dart';
import 'package:pos_mobile/data/repositories/local_business_repository.dart';
import 'package:pos_mobile/database/enums/sync_operation_type.dart';
import 'package:pos_mobile/data/repositories/sync_queue_repository.dart';

class SettingsRepository {
  SettingsRepository(
    this._runner,
    this._syncQueue, {
    JsonValidator? jsonValidator,
  }) : _json = jsonValidator ?? JsonValidator();

  final DatabaseRunner _runner;
  final SyncQueueRepository _syncQueue;
  final JsonValidator _json;

  Future<void> setSetting({
    required String settingKey,
    required Map<String, Object?> value,
    required String deviceId,
    String? updatedByUserId,
    bool enqueueSync = true,
  }) async {
    final businessId =
        await LocalBusinessRepository(_runner).requireBusinessId();
    final valueJson = _json.encodeObject(value);
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    await _runner.runInTransaction(() async {
      await _runner.database.into(_runner.database.appSettings).insertOnConflictUpdate(
            AppSettingsCompanion.insert(
              settingKey: settingKey,
              businessId: businessId,
              valueJson: valueJson,
              updatedAtMs: now,
              updatedByUserId: Value(updatedByUserId),
            ),
          );
      if (enqueueSync) {
        await _syncQueue.enqueueInTransaction(
          businessId: businessId,
          deviceId: deviceId,
          entityType: 'app_setting',
          entityId: settingKey,
          operationType: SyncOperationType.update,
          payload: {
            'setting_key': settingKey,
            'value': value,
          },
        );
      }
    });
  }

  Future<AppSettingRow?> getSetting(String settingKey) {
    return (_runner.database.select(_runner.database.appSettings)
          ..where((t) => t.settingKey.equals(settingKey)))
        .getSingleOrNull();
  }
}
