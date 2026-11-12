import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pos_mobile/database/connection/local_db_paths.dart';
import 'package:pos_mobile/database/connection/open_database.dart';
import 'package:pos_mobile/app/bootstrap/app_runtime.dart';
import 'package:pos_mobile/core/network/business_registration_models.dart';
import 'package:pos_mobile/features/onboarding/application/business_registration_controller.dart';
import 'package:pos_mobile/features/onboarding/data/onboarding_recovery_store.dart';
import 'package:pos_mobile/features/onboarding/data/onboarding_storage_outcomes.dart';
import 'package:pos_mobile/features/onboarding/domain/registration_form_validator.dart';
import 'package:pos_mobile/core/network/business_registration_api.dart';

import '../../fakes/fake_secure_storage_service.dart';

void main() {
  late String storageRoot;
  late FakeSecureStorageService secureStorage;
  late OnboardingRecoveryStore recoveryStore;

  setUp(() async {
    storageRoot =
        '${Directory.systemTemp.path}/pakpos_onboard_${DateTime.now().microsecondsSinceEpoch}';
    secureStorage = FakeSecureStorageService();
    recoveryStore = OnboardingRecoveryStore(secureStorage);
    await AppRuntime.shutdown();
    await AppRuntime.start(storageDirectoryOverride: storageRoot);
  });

  tearDown(() async {
    await AppRuntime.shutdown();
  });

  test(
    'uses server UUID for local provisioning without storing password',
    () async {
      const businessId = '550e8400-e29b-41d4-a716-446655440000';
      final api = _StubRegistrationApi(
        RegisterBusinessResult(
          business: RegisteredBusiness(
            id: businessId,
            name: 'Remote Shop',
            phone: null,
            email: null,
            currencyCode: 'PKR',
            timezone: 'Asia/Karachi',
            status: 'ACTIVE',
            createdAt: DateTime.utc(2026, 11, 10),
          ),
          owner: RegisteredOwner(
            id: '6ba7b810-9dad-11d1-80b4-00c04fd430c8',
            name: 'Owner',
            email: 'owner@example.com',
            status: 'PENDING_VERIFICATION',
            createdAt: DateTime.utc(2026, 11, 10),
          ),
          membership: RegisteredMembership(
            id: '6ba7b811-9dad-11d1-80b4-00c04fd430c8',
            role: 'OWNER',
            status: 'ACTIVE',
          ),
        ),
      );

      final controller = BusinessRegistrationController(
        api: api,
        recoveryStore: recoveryStore,
      );

      final outcome = await controller.submit(
        const RegistrationFormValues(
          businessName: 'Remote Shop',
          ownerName: 'Owner',
          ownerEmail: 'owner@example.com',
          password: 'secure-pass-12',
        ),
      );

      expect(outcome, RegistrationFlowOutcome.success);
      expect(secureStorage.snapshot().containsValue('secure-pass-12'), isFalse);
      expect(
        await recoveryStore.readProvisioningRecovery(),
        isA<OnboardingSnapshotAbsent<ProvisioningRecoverySnapshot>>(),
      );
      final pending = await recoveryStore.readOwnerPending();
      expect(pending, isA<OnboardingSnapshotPresent<OwnerPendingSnapshot>>());
      expect(
        (pending as OnboardingSnapshotPresent<OwnerPendingSnapshot>)
            .value
            .businessId,
        businessId,
      );
      expect(AppRuntime.container, isNotNull);
    },
  );

  test('preserves recovery snapshot when provisioning fails', () async {
    const businessId = '550e8400-e29b-41d4-a716-446655440001';
    final api = _StubRegistrationApi(
      RegisterBusinessResult(
        business: RegisteredBusiness(
          id: businessId,
          name: 'Broken',
          phone: null,
          email: null,
          currencyCode: 'PKR',
          timezone: 'Asia/Karachi',
          status: 'ACTIVE',
          createdAt: DateTime.utc(2026, 11, 10),
        ),
        owner: RegisteredOwner(
          id: '6ba7b810-9dad-11d1-80b4-00c04fd430c8',
          name: 'Owner',
          email: 'broken@example.com',
          status: 'PENDING_VERIFICATION',
          createdAt: DateTime.utc(2026, 11, 10),
        ),
        membership: RegisteredMembership(
          id: '6ba7b811-9dad-11d1-80b4-00c04fd430c8',
          role: 'OWNER',
          status: 'ACTIVE',
        ),
      ),
    );
    final dir = await resolvePakposDirectory(overrideDirectory: storageRoot);
    final corruptFile = File('$dir/${businessDatabaseFileName(businessId)}');
    await corruptFile.parent.create(recursive: true);
    await corruptFile.writeAsString('corrupt');

    final controller = BusinessRegistrationController(
      api: api,
      recoveryStore: recoveryStore,
    );

    final outcome = await controller.submit(
      const RegistrationFormValues(
        businessName: 'Broken',
        ownerName: 'Owner',
        ownerEmail: 'broken@example.com',
        password: 'secure-pass-12',
      ),
    );

    expect(outcome, RegistrationFlowOutcome.provisioningFailed);
    final recovery = await recoveryStore.readProvisioningRecovery();
    expect(
      recovery,
      isA<OnboardingSnapshotPresent<ProvisioningRecoverySnapshot>>(),
    );
    expect(
      (recovery as OnboardingSnapshotPresent<ProvisioningRecoverySnapshot>)
          .value
          .businessId,
      businessId,
    );
    expect(secureStorage.snapshot().containsValue('secure-pass-12'), isFalse);
  });
}

class _StubRegistrationApi implements BusinessRegistrationApi {
  _StubRegistrationApi(this._result);

  final RegisterBusinessResult _result;

  @override
  Future<RegisterBusinessResult> register(
    RegisterBusinessRequest request,
  ) async {
    return _result;
  }
}
