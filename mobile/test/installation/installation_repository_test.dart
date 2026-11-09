import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_mobile/data/repositories/database_runner.dart';
import 'package:pos_mobile/data/repositories/installation_repository.dart';
import 'package:pos_mobile/data/services/database_service.dart';
import 'package:pos_mobile/database/app_database.dart';
import 'package:pos_mobile/database/enums/provisioning_status.dart';

void main() {
  late String storageRoot;
  late DatabaseService bootstrapService;
  late InstallationRepository repository;

  setUp(() async {
    storageRoot =
        '${Directory.systemTemp.path}/pakpos_install_${DateTime.now().microsecondsSinceEpoch}';
    bootstrapService = await DatabaseService.open(
      storageDirectoryOverride: storageRoot,
    );
    repository = InstallationRepository(
      DatabaseRunner(bootstrapService.database),
    );
  });

  tearDown(() async {
    await bootstrapService.dispose();
  });

  test('creates installation profile once', () async {
    final first = await repository.ensureProfile();
    final second = await repository.ensureProfile();
    expect(first.appInstallId, second.appInstallId);
    expect(first.singletonId, InstallationRepository.profileSingletonId);
  });

  test('rejects duplicate singleton profile row at trigger level', () async {
    await repository.ensureProfile();
    await expectLater(
      () => bootstrapService.database
          .into(bootstrapService.database.installationProfile)
          .insert(
            InstallationProfileCompanion.insert(
              singletonId: const Value(2),
              appInstallId: 'other',
              createdAtMs: 0,
              updatedAtMs: 0,
            ),
          ),
      throwsA(anything),
    );
  });

  test('registers provisioning and transitions to ready', () async {
    await repository.ensureProfile();
    const businessId = '550e8400-e29b-41d4-a716-446655440000';
    await repository.registerProvisioningBusiness(
      businessId: businessId,
      displayName: 'Test Shop',
    );
    var row = await repository.getKnownBusiness(businessId);
    expect(row?.provisioningStatus, ProvisioningStatus.provisioning);

    await repository.markBusinessReady(businessId);
    row = await repository.getKnownBusiness(businessId);
    expect(row?.provisioningStatus, ProvisioningStatus.ready);

    await repository.setActiveBusinessId(businessId);
    final profile = await repository.getProfile();
    expect(profile?.activeBusinessId, businessId);
  });

  test('persists registry after reopening bootstrap database', () async {
    const businessId = '6ba7b810-9dad-11d1-80b4-00c04fd430c8';
    await repository.ensureProfile();
    await repository.registerProvisioningBusiness(
      businessId: businessId,
      displayName: 'Persisted Shop',
    );
    await repository.markBusinessReady(businessId);
    await bootstrapService.dispose();

    final reopened = await DatabaseService.open(
      storageDirectoryOverride: storageRoot,
    );
    addTearDown(() => reopened.dispose());
    final reopenedRepo = InstallationRepository(
      DatabaseRunner(reopened.database),
    );
    final businesses = await reopenedRepo.listKnownBusinesses();
    expect(businesses.single.businessId, businessId);
    expect(businesses.single.provisioningStatus, ProvisioningStatus.ready);
  });
}
