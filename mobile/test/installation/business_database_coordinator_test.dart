import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pos_mobile/data/repositories/database_runner.dart';
import 'package:pos_mobile/data/repositories/installation_repository.dart';
import 'package:pos_mobile/data/repositories/local_business_repository.dart';
import 'package:pos_mobile/data/services/business_database_coordinator.dart';
import 'package:pos_mobile/data/services/database_service.dart';
import 'package:pos_mobile/database/connection/local_db_paths.dart';
import 'package:pos_mobile/database/connection/open_database.dart';
import 'package:pos_mobile/database/enums/provisioning_status.dart';
import 'package:drift/drift.dart' show Value;
import 'package:pos_mobile/database/app_database.dart';

void main() {
  late String storageRoot;
  late BusinessDatabaseCoordinator coordinator;

  setUp(() {
    storageRoot =
        '${Directory.systemTemp.path}/pakpos_coord_${DateTime.now().microsecondsSinceEpoch}';
    coordinator = BusinessDatabaseCoordinator(storageRoot);
  });

  const businessId = '550e8400-e29b-41d4-a716-446655440000';
  const displayName = 'Coordinator Test Shop';

  Future<void> expectBootstrapHasNoBusinessRow() async {
    final bootstrap = await DatabaseService.open(
      storageDirectoryOverride: storageRoot,
    );
    try {
      expect(
        await LocalBusinessRepository(DatabaseRunner(bootstrap.database))
            .getBusiness(),
        isNull,
      );
    } finally {
      await bootstrap.dispose();
    }
  }

  test(
    'provisions separate business file with expected business row',
    () async {
      final service = await coordinator.provisionBusinessDatabase(
        businessId: businessId,
        displayName: displayName,
      );
      addTearDown(() => service.dispose());

      final row = await LocalBusinessRepository(
        DatabaseRunner(service.database),
      ).getBusiness();
      expect(row?.businessId, businessId);
      expect(row?.name, displayName);

      await expectBootstrapHasNoBusinessRow();

      final known = await coordinator.listKnownBusinesses();
      expect(known.single.provisioningStatus, ProvisioningStatus.ready);

      final dir = await resolvePakposDirectory(overrideDirectory: storageRoot);
      expect(
        File('$dir/${businessDatabaseFileName(businessId)}').existsSync(),
        isTrue,
      );
    },
  );

  test('rejects duplicate ready provisioning', () async {
    final first = await coordinator.provisionBusinessDatabase(
      businessId: businessId,
      displayName: displayName,
    );
    await first.dispose();
    await expectLater(
      () => coordinator.provisionBusinessDatabase(
        businessId: businessId,
        displayName: displayName,
      ),
      throwsA(isA<BusinessDatabaseException>()),
    );
  });

  test('opens existing business without modifying data', () async {
    final provisioned = await coordinator.provisionBusinessDatabase(
      businessId: businessId,
      displayName: displayName,
    );
    await provisioned.dispose();

    final opened = await coordinator.openReadyBusiness(businessId: businessId);
    addTearDown(() => opened.dispose());
    final row = await LocalBusinessRepository(DatabaseRunner(opened.database))
        .getBusiness();
    expect(row?.name, displayName);
  });

  test('rejects opening business not present in registry', () async {
    await expectLater(
      () => coordinator.openReadyBusiness(businessId: businessId),
      throwsA(isA<BusinessDatabaseException>()),
    );
  });

  test('does not overwrite incomplete existing file', () async {
    final dir = await resolvePakposDirectory(overrideDirectory: storageRoot);
    final path = '$dir/${businessDatabaseFileName(businessId)}';
    await File(path).create(recursive: true);

    final bootstrap = await DatabaseService.open(
      storageDirectoryOverride: storageRoot,
    );
    try {
      final repo = InstallationRepository(DatabaseRunner(bootstrap.database));
      await repo.ensureProfile();
      await repo.registerProvisioningBusiness(
        businessId: businessId,
        displayName: displayName,
      );
    } finally {
      await bootstrap.dispose();
    }

    await expectLater(
      () => coordinator.provisionBusinessDatabase(
        businessId: businessId,
        displayName: displayName,
      ),
      throwsA(isA<BusinessDatabaseException>()),
    );

    final partial = await DatabaseService.openForBusiness(
      businessId: businessId,
      storageDirectoryOverride: storageRoot,
    );
    try {
      expect(
        await LocalBusinessRepository(DatabaseRunner(partial.database))
            .getBusiness(),
        isNull,
      );
    } finally {
      await partial.dispose();
    }
  });

  test(
    'recovers ready business from stale PROVISIONING registry entry',
    () async {
      final provisioned = await coordinator.provisionBusinessDatabase(
        businessId: businessId,
        displayName: displayName,
      );
      await provisioned.dispose();

      final bootstrap = await DatabaseService.open(
        storageDirectoryOverride: storageRoot,
      );
      try {
        await (bootstrap.database.update(
          bootstrap.database.knownBusinesses,
        )..where((t) => t.businessId.equals(businessId))).write(
          const KnownBusinessesCompanion(
            provisioningStatus: Value(ProvisioningStatus.provisioning),
          ),
        );
      } finally {
        await bootstrap.dispose();
      }

      final opened = await coordinator.openReadyBusiness(
        businessId: businessId,
      );
      addTearDown(() => opened.dispose());
      final known = await coordinator.listKnownBusinesses();
      expect(known.single.provisioningStatus, ProvisioningStatus.ready);
    },
  );
}
