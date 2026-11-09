import 'package:drift/drift.dart';
import 'package:pos_mobile/database/app_database.dart';
import 'package:pos_mobile/database/validators/json_validator.dart';
import 'package:pos_mobile/data/repositories/database_runner.dart';

class LocalBusinessRepository {
  LocalBusinessRepository(this._runner, {JsonValidator? jsonValidator})
    : _json = jsonValidator ?? JsonValidator();

  final DatabaseRunner _runner;
  final JsonValidator _json;

  static const singletonId = 1;

  Future<void> provisionBusiness({
    required String businessId,
    required String name,
    String? legalName,
    String? phone,
    String? address,
    String timezoneId = 'Asia/Karachi',
    String currencyCode = 'PKR',
    Map<String, Object?> settings = const {},
  }) async {
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    final settingsJson = _json.encodeObject(settings);
    await _runner.runInTransaction(() async {
      final existing = await (_runner.database.select(
        _runner.database.localBusiness,
      )..where((t) => t.singletonId.equals(singletonId))).getSingleOrNull();
      if (existing != null) {
        throw BusinessProvisionException('Business already provisioned');
      }
      await _runner.database
          .into(_runner.database.localBusiness)
          .insert(
            LocalBusinessCompanion.insert(
              singletonId: Value(singletonId),
              businessId: businessId,
              name: name,
              legalName: Value(legalName),
              phone: Value(phone),
              address: Value(address),
              timezoneId: Value(timezoneId),
              currencyCode: Value(currencyCode),
              settingsJson: Value(settingsJson),
              createdAtMs: now,
              updatedAtMs: now,
            ),
          );
    });
  }

  Future<LocalBusinessRow?> getBusiness() {
    return (_runner.database.select(
      _runner.database.localBusiness,
    )..where((t) => t.singletonId.equals(singletonId))).getSingleOrNull();
  }

  Future<String> requireBusinessId() async {
    final row = await getBusiness();
    if (row == null) {
      throw BusinessProvisionException('Business not provisioned');
    }
    return row.businessId;
  }
}

class BusinessProvisionException implements Exception {
  BusinessProvisionException(this.message);

  final String message;

  @override
  String toString() => message;
}
