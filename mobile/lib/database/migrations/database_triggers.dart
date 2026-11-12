import 'package:drift/drift.dart';

/// Phase 2 core triggers (schema v1).
Future<void> applyPhase2CoreTriggers(GeneratedDatabase db) async {
  await db.customStatement('''
CREATE TRIGGER IF NOT EXISTS local_business_singleton_insert
BEFORE INSERT ON local_business
WHEN (SELECT COUNT(*) FROM local_business) >= 1
BEGIN
  SELECT RAISE(ABORT, 'local_business allows only one row');
END;
''');

  await db.customStatement('''
CREATE TRIGGER IF NOT EXISTS local_device_singleton_insert
BEFORE INSERT ON local_device
WHEN (SELECT COUNT(*) FROM local_device) >= 1
BEGIN
  SELECT RAISE(ABORT, 'local_device allows only one row');
END;
''');
}

/// All triggers for a fresh schema-v2 database (v1 core + installation).
Future<void> applyDatabaseTriggers(GeneratedDatabase db) async {
  await applyPhase2CoreTriggers(db);
  await applyInstallationProfileTriggers(db);
}

/// v2 installation tables only (used from [AppDatabase] v1→v2 upgrade).
Future<void> applyInstallationProfileTriggers(GeneratedDatabase db) async {
  await db.customStatement('''
CREATE TRIGGER IF NOT EXISTS installation_profile_singleton_insert
BEFORE INSERT ON installation_profile
WHEN (SELECT COUNT(*) FROM installation_profile) >= 1
BEGIN
  SELECT RAISE(ABORT, 'installation_profile allows only one row');
END;
''');

  await db.customStatement('''
CREATE TRIGGER IF NOT EXISTS sync_operations_no_self_dep_insert
BEFORE INSERT ON sync_operations
WHEN NEW.depends_on_operation_id IS NOT NULL
  AND NEW.depends_on_operation_id = NEW.operation_id
BEGIN
  SELECT RAISE(ABORT, 'sync operation cannot depend on itself');
END;
''');

  await db.customStatement('''
CREATE TRIGGER IF NOT EXISTS sync_operations_no_self_dep_update
BEFORE UPDATE ON sync_operations
WHEN NEW.depends_on_operation_id IS NOT NULL
  AND NEW.depends_on_operation_id = NEW.operation_id
BEGIN
  SELECT RAISE(ABORT, 'sync operation cannot depend on itself');
END;
''');

  await db.customStatement('''
CREATE TRIGGER IF NOT EXISTS audit_events_no_update
BEFORE UPDATE ON audit_events
BEGIN
  SELECT RAISE(ABORT, 'audit_events are append-only');
END;
''');

  await db.customStatement('''
CREATE TRIGGER IF NOT EXISTS audit_events_no_delete
BEFORE DELETE ON audit_events
BEGIN
  SELECT RAISE(ABORT, 'audit_events cannot be deleted');
END;
''');

  await db.customStatement('''
CREATE TRIGGER IF NOT EXISTS sync_operations_no_delete
BEFORE DELETE ON sync_operations
BEGIN
  SELECT RAISE(ABORT, 'sync_operations cannot be deleted');
END;
''');

  await db.customStatement('''
CREATE TRIGGER IF NOT EXISTS sync_operations_identity_immutable
BEFORE UPDATE ON sync_operations
BEGIN
  SELECT
    CASE
      WHEN OLD.operation_id != NEW.operation_id
        OR OLD.business_id != NEW.business_id
        OR OLD.device_id != NEW.device_id
        OR OLD.entity_type != NEW.entity_type
        OR OLD.entity_id != NEW.entity_id
        OR OLD.operation_type != NEW.operation_type
        OR OLD.payload_json != NEW.payload_json
        OR OLD.depends_on_operation_id IS NOT NEW.depends_on_operation_id
        OR OLD.created_at_ms != NEW.created_at_ms
      THEN RAISE(ABORT, 'sync_operations identity fields are immutable')
    END;
END;
''');
}
