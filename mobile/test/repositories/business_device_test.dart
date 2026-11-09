import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_mobile/data/repositories/local_business_repository.dart';
import 'package:pos_mobile/data/repositories/local_device_repository.dart';
import 'package:pos_mobile/database/app_database.dart';
import 'package:pos_mobile/database/enums/activation_status.dart';

import '../helpers/test_database.dart';

void main() {
  late TestDatabaseHarness harness;
  late LocalBusinessRepository businessRepo;
  late LocalDeviceRepository deviceRepo;

  setUp(() {
    harness = TestDatabaseHarness.memory();
    businessRepo = LocalBusinessRepository(harness.runner);
    deviceRepo = LocalDeviceRepository(harness.runner);
  });

  tearDown(() async {
    await harness.close();
  });

  test('open database does not create business', () async {
    expect(await businessRepo.getBusiness(), isNull);
  });

  test('provisionBusiness enforces singleton', () async {
    await businessRepo.provisionBusiness(businessId: 'biz-a', name: 'Shop A');
    expect(await businessRepo.getBusiness(), isNotNull);
    expect(
      () => businessRepo.provisionBusiness(businessId: 'biz-b', name: 'Shop B'),
      throwsA(isA<BusinessProvisionException>()),
    );
    expect(
      () => harness.database
          .into(harness.database.localBusiness)
          .insert(
            LocalBusinessCompanion.insert(
              singletonId: const Value(2),
              businessId: 'biz-c',
              name: 'Other',
              createdAtMs: 0,
              updatedAtMs: 0,
            ),
          ),
      throwsA(anything),
    );
  });

  test('device rejects business_id FK mismatch', () async {
    await businessRepo.provisionBusiness(businessId: 'biz-a', name: 'Shop A');
    await expectLater(() async {
      await harness.database
          .into(harness.database.localDevice)
          .insert(
            LocalDeviceCompanion.insert(
              singletonId: const Value(1),
              deviceId: 'dev-1',
              businessId: 'wrong-id',
              platform: 'windows',
              activationStatus: ActivationStatus.unregistered,
              createdAtMs: 0,
              updatedAtMs: 0,
            ),
          );
    }, throwsA(isA<Exception>()));
  });

  test('registerDevice rejects mismatch vs provisioned business', () async {
    await businessRepo.provisionBusiness(businessId: 'biz-a', name: 'Shop A');
    expect(
      () => deviceRepo.registerDevice(
        deviceId: 'dev-1',
        businessId: 'wrong',
        platform: 'windows',
      ),
      throwsA(isA<DeviceBusinessMismatchException>()),
    );
  });
}
