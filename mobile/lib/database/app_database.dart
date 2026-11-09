import 'package:drift/drift.dart';
import 'package:pos_mobile/database/migrations/database_triggers.dart';
import 'package:pos_mobile/database/tables/app_settings.dart';
import 'package:pos_mobile/database/tables/audit_events.dart';
import 'package:pos_mobile/database/tables/local_business.dart';
import 'package:pos_mobile/database/tables/local_device.dart';
import 'package:pos_mobile/database/tables/sync_conflicts.dart';
import 'package:pos_mobile/database/tables/sync_cursors.dart';
import 'package:pos_mobile/database/tables/sync_operations.dart';
import 'package:pos_mobile/database/tables/users_cache.dart';

part 'app_database.g.dart';

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
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
        onCreate: (Migrator m) async {
          await m.createAll();
          await applyDatabaseTriggers(this);
        },
        onUpgrade: (Migrator m, int from, int to) async {
          // Future versions add stepwise migrations here (Phase 5+).
        },
      );
}
