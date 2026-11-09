import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pos_mobile/data/repositories/local_business_repository.dart';
import 'package:pos_mobile/data/repositories/database_runner.dart';
import 'package:pos_mobile/data/services/database_service.dart';
import 'package:pos_mobile/database/connection/local_db_paths.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory tempRoot;

  setUp(() async {
    tempRoot = await Directory.systemTemp.createTemp('pakpos_db_service_');
  });

  tearDown(() async {
    if (tempRoot.existsSync()) {
      await tempRoot.delete(recursive: true);
    }
  });

  test('DatabaseService.open uses bootstrap file and schema', () async {
    final service = await DatabaseService.open(
      storageDirectoryOverride: tempRoot.path,
    );
    final db = service.database;

    final tables = await db
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type='table' "
          "AND name NOT LIKE 'sqlite_%'",
        )
        .get();
    final names = tables.map((r) => r.data['name'] as String).toList();
    expect(
      names,
      containsAll([
        'app_settings',
        'audit_events',
        'local_business',
        'local_device',
        'sync_conflicts',
        'sync_cursors',
        'sync_operations',
        'users_cache',
      ]),
    );

    final fk = await db.customSelect('PRAGMA foreign_keys').getSingle();
    expect(fk.data['foreign_keys'], 1);

    final business =
        await LocalBusinessRepository(DatabaseRunner(db)).getBusiness();
    expect(business, isNull);

    await service.dispose();
  });

  test('bootstrap database persists after close and reopen', () async {
    final firstPath = p.join(
      tempRoot.path,
      'pakpos',
      localBootstrapDatabaseFileName,
    );

    final first = await DatabaseService.open(
      storageDirectoryOverride: tempRoot.path,
    );
    await first.database.customSelect('PRAGMA user_version').get();
    await first.dispose();
    expect(File(firstPath).existsSync(), isTrue);

    final second = await DatabaseService.open(
      storageDirectoryOverride: tempRoot.path,
    );
    final fk =
        await second.database.customSelect('PRAGMA foreign_keys').getSingle();
    expect(fk.data['foreign_keys'], 1);
    await second.dispose();
  });
}
