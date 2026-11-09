import 'package:drift/drift.dart';
import 'package:pos_mobile/database/app_database.dart';
import 'package:pos_mobile/database/enums/activation_status.dart';
import 'package:pos_mobile/data/repositories/database_runner.dart';
import 'package:pos_mobile/data/repositories/local_business_repository.dart';

class LocalDeviceRepository {
  LocalDeviceRepository(this._runner);

  final DatabaseRunner _runner;

  static const singletonId = 1;

  Future<void> registerDevice({
    required String deviceId,
    required String businessId,
    required String platform,
    String? label,
    String activationStatus = ActivationStatus.unregistered,
  }) async {
    final active = await LocalBusinessRepository(_runner).getBusiness();
    if (active == null || active.businessId != businessId) {
      throw DeviceBusinessMismatchException(
        'Device business_id must match provisioned local_business',
      );
    }
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    if (!ActivationStatus.isValid(activationStatus)) {
      throw ArgumentError('Invalid activation_status');
    }
    await _runner.database
        .into(_runner.database.localDevice)
        .insertOnConflictUpdate(
          LocalDeviceCompanion.insert(
            singletonId: Value(singletonId),
            deviceId: deviceId,
            businessId: businessId,
            platform: platform,
            label: Value(label),
            activationStatus: activationStatus,
            createdAtMs: now,
            updatedAtMs: now,
          ),
        );
  }
}

class DeviceBusinessMismatchException implements Exception {
  DeviceBusinessMismatchException(this.message);

  final String message;

  @override
  String toString() => message;
}
