import 'package:flutter_test/flutter_test.dart';
import 'package:pos_mobile/app/launch/app_launch_resolver.dart';
import 'package:pos_mobile/database/app_database.dart';
import 'package:pos_mobile/database/enums/provisioning_status.dart';
import 'package:pos_mobile/core/security/secure_storage_keys.dart';
import 'package:pos_mobile/features/auth/domain/auth_session_launch_state.dart';
import 'package:pos_mobile/features/onboarding/data/onboarding_recovery_store.dart';
import 'package:pos_mobile/features/onboarding/data/onboarding_storage_outcomes.dart';

import '../fakes/fake_secure_storage_service.dart';

void main() {
  const businessId = '550e8400-e29b-41d4-a716-446655440000';

  late FakeSecureStorageService secureStorage;
  late OnboardingRecoveryStore store;

  const noSession = AuthSessionLaunchContext.none;

  setUp(() {
    secureStorage = FakeSecureStorageService();
    store = OnboardingRecoveryStore(secureStorage);
  });

  Future<List<KnownBusinessRow>> emptyRegistry() async => [];

  KnownBusinessRow readyRow() => KnownBusinessRow(
    businessId: businessId,
    displayName: 'Shop',
    databaseFileName: 'business_$businessId.sqlite',
    provisioningStatus: ProvisioningStatus.ready,
    createdAtMs: 0,
    lastOpenedAtMs: null,
  );

  test('no known business resolves to welcome', () async {
    final resolution = await AppLaunchResolver.resolve(
      store: store,
      knownBusinesses: emptyRegistry(),
      sessionContext: noSession,
    );
    expect(resolution.destination, AppLaunchDestination.onboardingWelcome);
  });

  test('READY without session resolves to login', () async {
    final resolution = await AppLaunchResolver.resolve(
      store: store,
      knownBusinesses: Future.value([readyRow()]),
      sessionContext: noSession,
    );
    expect(resolution.destination, AppLaunchDestination.loginRequired);
    expect(resolution.sessionBusinessId, businessId);
  });

  test('READY with valid session resolves to mainApp', () async {
    final resolution = await AppLaunchResolver.resolve(
      store: store,
      knownBusinesses: Future.value([readyRow()]),
      sessionContext: const AuthSessionLaunchContext(
        state: AuthSessionLaunchState.valid,
        businessId: businessId,
      ),
    );
    expect(resolution.destination, AppLaunchDestination.mainApp);
  });

  test('network unavailable does not grant mainApp', () async {
    final resolution = await AppLaunchResolver.resolve(
      store: store,
      knownBusinesses: Future.value([readyRow()]),
      sessionContext: const AuthSessionLaunchContext(
        state: AuthSessionLaunchState.unavailable,
        businessId: businessId,
      ),
    );
    expect(resolution.destination, AppLaunchDestination.loginRequired);
  });

  test('provisioning recovery takes precedence over owner pending', () async {
    await store.saveProvisioningRecovery(
      const ProvisioningRecoverySnapshot(
        businessId: businessId,
        displayName: 'Shop',
        ownerName: 'Owner',
        ownerEmail: 'owner@example.com',
      ),
    );
    await store.saveOwnerPending(
      const OwnerPendingSnapshot(
        businessId: businessId,
        businessName: 'Shop',
        ownerEmail: 'owner@example.com',
        ownerName: 'Owner',
      ),
    );

    final resolution = await AppLaunchResolver.resolve(
      store: store,
      knownBusinesses: Future.value([readyRow()]),
      sessionContext: noSession,
    );
    expect(resolution.destination, AppLaunchDestination.provisioningRecover);
  });

  test('corrupt JSON fails closed without deleting stored value', () async {
    await secureStorage.write(
      key: SecureStorageKeys.ownerPendingVerification,
      value: '{not-json',
    );
    final resolution = await AppLaunchResolver.resolve(
      store: store,
      knownBusinesses: emptyRegistry(),
      sessionContext: noSession,
    );
    expect(
      resolution.destination,
      AppLaunchDestination.onboardingSnapshotError,
    );
    expect(
      await secureStorage.read(key: SecureStorageKeys.ownerPendingVerification),
      isNotNull,
    );
  });

  test('invalid UUID in snapshot fails closed', () async {
    await secureStorage.write(
      key: SecureStorageKeys.provisioningRecovery,
      value: '{"businessId":"bad","displayName":"x","ownerName":"o","ownerEmail":"o@example.com"}',
    );
    final resolution = await AppLaunchResolver.resolve(
      store: store,
      knownBusinesses: emptyRegistry(),
      sessionContext: noSession,
    );
    expect(
      resolution.destination,
      AppLaunchDestination.onboardingSnapshotError,
    );
    expect(resolution.invalidReason, InvalidSnapshotReason.invalidBusinessId);
  });

  test(
    'owner pending with matching READY registry resolves to complete',
    () async {
      await store.saveOwnerPending(
        const OwnerPendingSnapshot(
          businessId: businessId,
          businessName: 'Shop',
          ownerEmail: 'owner@example.com',
          ownerName: 'Owner',
        ),
      );
      final resolution = await AppLaunchResolver.resolve(
        store: store,
        knownBusinesses: Future.value([readyRow()]),
        sessionContext: noSession,
      );
      expect(
        resolution.destination,
        AppLaunchDestination.ownerPendingVerification,
      );
    },
  );

  test('owner pending with registry mismatch fails closed', () async {
    await store.saveOwnerPending(
      const OwnerPendingSnapshot(
        businessId: businessId,
        businessName: 'Shop',
        ownerEmail: 'owner@example.com',
        ownerName: 'Owner',
      ),
    );
    final resolution = await AppLaunchResolver.resolve(
      store: store,
      knownBusinesses: emptyRegistry(),
      sessionContext: noSession,
    );
    expect(
      resolution.destination,
      AppLaunchDestination.onboardingSnapshotError,
    );
  });

  test('secure storage read failure fails closed', () async {
    secureStorage.simulateFailure = true;
    final resolution = await AppLaunchResolver.resolve(
      store: store,
      knownBusinesses: emptyRegistry(),
      sessionContext: noSession,
    );
    expect(
      resolution.destination,
      AppLaunchDestination.secureStorageUnavailable,
    );
  });
}
