import 'package:drift/drift.dart';
import 'package:pos_mobile/core/ids/uuid_generator.dart';
import 'package:pos_mobile/database/app_database.dart';
import 'package:pos_mobile/database/validators/json_validator.dart';
import 'package:pos_mobile/data/repositories/database_runner.dart';
import 'package:pos_mobile/data/repositories/local_business_repository.dart';

class AuditRepository {
  AuditRepository(
    this._runner, {
    JsonValidator? jsonValidator,
    UuidGenerator? uuid,
  }) : _json = jsonValidator ?? JsonValidator(),
       _uuid = uuid ?? UuidGenerator();

  final DatabaseRunner _runner;
  final JsonValidator _json;
  final UuidGenerator _uuid;

  Future<void> recordEvent({
    required String deviceId,
    required String eventType,
    String? actorUserId,
    String? entityType,
    String? entityId,
    Map<String, Object?> metadata = const {},
  }) async {
    final businessId = await LocalBusinessRepository(_runner)
        .requireBusinessId();
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    final metadataJson = _json.encodeObject(metadata);
    await _runner.database
        .into(_runner.database.auditEvents)
        .insert(
          AuditEventsCompanion.insert(
            eventId: _uuid.v4(),
            businessId: businessId,
            deviceId: deviceId,
            actorUserId: Value(actorUserId),
            eventType: eventType,
            entityType: Value(entityType),
            entityId: Value(entityId),
            metadataJson: Value(metadataJson),
            createdAtMs: now,
          ),
        );
  }
}
