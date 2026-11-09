import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pos_mobile/app/bootstrap/app_runtime.dart';
import 'package:pos_mobile/app/providers/database_providers.dart';
import 'package:pos_mobile/data/repositories/installation_repository.dart';
import 'package:pos_mobile/data/repositories/local_business_repository.dart';

void main() {
  tearDown(() async {
    await AppRuntime.shutdown();
  });

  test('startup uses bootstrap database', () async {
    final storage =
        '${Directory.systemTemp.path}/pakpos_runtime_boot_${DateTime.now().microsecondsSinceEpoch}';
    final container = await AppRuntime.start(storageDirectoryOverride: storage);
    final service = container.read(databaseServiceProvider);
    expect(service.isBootstrap, isTrue);
    expect(
      await InstallationRepository(
        container.read(databaseRunnerProvider),
      ).getProfile(),
      isNotNull,
    );
  });

  test('switches to business database and back without leaking', () async {
    final storage =
        '${Directory.systemTemp.path}/pakpos_runtime_switch_${DateTime.now().microsecondsSinceEpoch}';
    await AppRuntime.start(storageDirectoryOverride: storage);

    const businessId = '550e8400-e29b-41d4-a716-446655440000';
    final businessContainer = await AppRuntime.provisionAndSwitchToBusiness(
      businessId: businessId,
      displayName: 'Switch Test',
    );
    expect(AppRuntime.container, same(businessContainer));

    final active = businessContainer.read(databaseServiceProvider);
    expect(active.isBootstrap, isFalse);
    expect(active.businessId, businessId);
    final repo = LocalBusinessRepository(
      businessContainer.read(databaseRunnerProvider),
    );
    expect((await repo.getBusiness())?.businessId, businessId);

    final bootstrapContainer = await AppRuntime.switchToBootstrap();
    final bootstrapService = bootstrapContainer.read(databaseServiceProvider);
    expect(bootstrapService.isBootstrap, isTrue);
    final bootstrapRepo = LocalBusinessRepository(
      bootstrapContainer.read(databaseRunnerProvider),
    );
    expect(await bootstrapRepo.getBusiness(), isNull);
  });

  test('failed business switch leaves bootstrap startup usable', () async {
    final storage =
        '${Directory.systemTemp.path}/pakpos_runtime_fail_${DateTime.now().microsecondsSinceEpoch}';
    await AppRuntime.start(storageDirectoryOverride: storage);

    await expectLater(
      () => AppRuntime.openReadyBusinessAndSwitch(
        businessId: '550e8400-e29b-41d4-a716-446655440000',
      ),
      throwsA(anything),
    );

    final container = AppRuntime.container;
    expect(container, isNotNull);
    expect(container!.read(databaseServiceProvider).isBootstrap, isTrue);
  });
}
