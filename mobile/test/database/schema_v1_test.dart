import 'package:flutter_test/flutter_test.dart';
import '../helpers/test_database.dart';

void main() {
  late TestDatabaseHarness harness;

  setUp(() {
    harness = TestDatabaseHarness.memory();
  });

  tearDown(() async {
    await harness.close();
  });

  test('creates v1 tables and indexes', () async {
    final tables = await harness.database
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type='table' "
          "AND name NOT LIKE 'sqlite_%' ORDER BY name",
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

    final indexes = await harness.database
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type='index' AND name NOT LIKE 'sqlite_%'",
        )
        .get();
    final indexNames = indexes.map((r) => r.data['name'] as String).toList();
    expect(indexNames, contains('sync_ops_status_created'));
    expect(indexNames, contains('sync_ops_entity'));
  });

  test('foreign keys are enabled', () async {
    final result = await harness.database
        .customSelect('PRAGMA foreign_keys')
        .getSingle();
    expect(result.data['foreign_keys'], 1);
  });
}
