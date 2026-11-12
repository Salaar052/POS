import 'package:drift/drift.dart';
import 'package:pos_mobile/database/migrations/database_triggers.dart'
    show applyPhase2CoreTriggers;
import 'package:pos_mobile/database/tables/app_settings.dart';
import 'package:pos_mobile/database/tables/audit_events.dart';
import 'package:pos_mobile/database/tables/local_business.dart';
import 'package:pos_mobile/database/tables/local_device.dart';
import 'package:pos_mobile/database/tables/sync_conflicts.dart';
import 'package:pos_mobile/database/tables/sync_cursors.dart';
import 'package:pos_mobile/database/tables/sync_operations.dart';
import 'package:pos_mobile/database/tables/users_cache.dart';

part 'legacy_v1_app_database.g.dart';

/// Frozen schema-v1 Drift definition used only to build real v1 SQLite fixtures
/// for migration tests (Phase 4.1+).
@DriftDatabase(
  tables: [
    LocalBusiness,
    LocalDevice,
    UsersCache,
    AppSettings,
    SyncOperations,
    SyncCursors,
    SyncConflicts,
    AuditEvents,
  ],
)
class LegacyV1AppDatabase extends _$LegacyV1AppDatabase {
  LegacyV1AppDatabase(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
    onCreate: (Migrator m) async {
      await m.createAll();
      await applyPhase2CoreTriggers(this);
    },
  );
}
