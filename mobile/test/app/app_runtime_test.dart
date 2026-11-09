import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pos_mobile/app/bootstrap/app_runtime.dart';
import 'package:pos_mobile/app/providers/database_providers.dart';

void main() {
  tearDown(() async {
    await AppRuntime.shutdown();
  });

  test('shutdown is idempotent', () async {
    await expectLater(AppRuntime.shutdown(), completes);
    await expectLater(AppRuntime.shutdown(), completes);
    expect(AppRuntime.container, isNull);
  });

  test('start after shutdown returns a new ProviderContainer', () async {
    final storage =
        '${Directory.systemTemp.path}/pakpos_runtime_${DateTime.now().microsecondsSinceEpoch}';

    final first = await AppRuntime.start(storageDirectoryOverride: storage);
    expect(AppRuntime.container, same(first));
    expect(
      first.read(databaseServiceProvider).businessId,
      isNull,
    );

    await AppRuntime.shutdown();

    final second = await AppRuntime.start(storageDirectoryOverride: storage);
    expect(second, isNot(same(first)));
    expect(
      second.read(databaseServiceProvider).database,
      isNotNull,
    );

    await AppRuntime.shutdown();
    expect(AppRuntime.container, isNull);
  });

  test('consecutive start replaces the active container', () async {
    final storage =
        '${Directory.systemTemp.path}/pakpos_runtime2_${DateTime.now().microsecondsSinceEpoch}';

    final first = await AppRuntime.start(storageDirectoryOverride: storage);
    final second = await AppRuntime.start(storageDirectoryOverride: storage);

    expect(second, isNot(same(first)));
    expect(AppRuntime.container, same(second));

    await AppRuntime.shutdown();
  });
}
