import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:pos_mobile/app/providers/secure_storage_provider.dart';
import 'package:pos_mobile/core/network/business_registration_api.dart';
import 'package:pos_mobile/features/onboarding/application/business_registration_controller.dart';
import 'package:pos_mobile/features/onboarding/data/onboarding_recovery_store.dart';
import 'package:pos_mobile/features/onboarding/data/onboarding_storage_outcomes.dart';

final onboardingRecoveryStoreProvider = Provider<OnboardingRecoveryStore>((
  ref,
) {
  final secureStorage = ref.watch(secureStorageServiceProvider);
  return OnboardingRecoveryStore(secureStorage);
});

final businessRegistrationApiProvider = Provider<BusinessRegistrationApi>((
  ref,
) {
  return HttpBusinessRegistrationApi();
});

final businessRegistrationControllerProvider =
    ChangeNotifierProvider.autoDispose<BusinessRegistrationController>((ref) {
      return BusinessRegistrationController(
        api: ref.watch(businessRegistrationApiProvider),
        recoveryStore: ref.watch(onboardingRecoveryStoreProvider),
      );
    });

final ownerPendingSnapshotProvider =
    FutureProvider<OnboardingSnapshotRead<OwnerPendingSnapshot>>((ref) async {
      return ref.watch(onboardingRecoveryStoreProvider).readOwnerPending();
    });

final provisioningRecoverySnapshotProvider =
    FutureProvider<OnboardingSnapshotRead<ProvisioningRecoverySnapshot>>((
      ref,
    ) async {
      return ref
          .watch(onboardingRecoveryStoreProvider)
          .readProvisioningRecovery();
    });
