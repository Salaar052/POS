import 'package:pos_mobile/app/bootstrap/bootstrap_launch_issue.dart';
import 'package:pos_mobile/database/app_database.dart';
import 'package:pos_mobile/database/enums/provisioning_status.dart';
import 'package:pos_mobile/features/onboarding/data/onboarding_recovery_store.dart';
import 'package:pos_mobile/features/auth/domain/auth_session_launch_state.dart';
import 'package:pos_mobile/features/onboarding/data/onboarding_storage_outcomes.dart';

enum AppLaunchDestination {
  resolving,
  onboardingWelcome,
  provisioningRecover,
  ownerPendingVerification,
  legacyAccessRequired,
  loginRequired,
  localDatabaseRecovery,
  onboardingSnapshotError,
  secureStorageUnavailable,
  mainApp,
}

class AppLaunchResolution {
  const AppLaunchResolution({
    required this.destination,
    this.userMessage,
    this.invalidReason,
    this.sessionBusinessId,
    this.sessionBusinessName,
  });

  final AppLaunchDestination destination;
  final String? userMessage;
  final InvalidSnapshotReason? invalidReason;
  final String? sessionBusinessId;
  final String? sessionBusinessName;
}

abstract final class AppLaunchResolver {
  static Future<AppLaunchResolution> resolve({
    required OnboardingRecoveryStore store,
    required Future<List<KnownBusinessRow>> knownBusinesses,
    required AuthSessionLaunchContext sessionContext,
    BootstrapLaunchIssue? bootstrapIssue,
  }) async {
    try {
      final provisioning = await store.readProvisioningRecovery();
      final ownerPending = await store.readOwnerPending();

      final invalidReason = _invalidReasonFrom(provisioning, ownerPending);
      if (invalidReason != null) {
        return AppLaunchResolution(
          destination: AppLaunchDestination.onboardingSnapshotError,
          userMessage:
              'Onboarding recovery data on this device is not valid. '
              'Sign-in and local recovery require support assistance. '
              'Your SQLite files were not changed.',
          invalidReason: invalidReason,
        );
      }

      if (provisioning
          is OnboardingSnapshotPresent<ProvisioningRecoverySnapshot>) {
        final known = await knownBusinesses;
        final registryMessage = _registryCheck(
          snapshotId: provisioning.value.businessId,
          known: known,
          allowAbsentRegistry: true,
        );
        if (registryMessage != null) {
          return AppLaunchResolution(
            destination: AppLaunchDestination.onboardingSnapshotError,
            userMessage: registryMessage,
            invalidReason: InvalidSnapshotReason.registryStateMismatch,
          );
        }
        return const AppLaunchResolution(
          destination: AppLaunchDestination.provisioningRecover,
        );
      }

      if (ownerPending is OnboardingSnapshotPresent<OwnerPendingSnapshot>) {
        final known = await knownBusinesses;
        final registryMessage = _registryCheck(
          snapshotId: ownerPending.value.businessId,
          known: known,
          allowAbsentRegistry: false,
        );
        if (registryMessage != null) {
          return AppLaunchResolution(
            destination: AppLaunchDestination.onboardingSnapshotError,
            userMessage: registryMessage,
            invalidReason: InvalidSnapshotReason.registryStateMismatch,
          );
        }

        if (bootstrapIssue != null &&
            bootstrapIssue.businessId == ownerPending.value.businessId) {
          return AppLaunchResolution(
            destination: AppLaunchDestination.localDatabaseRecovery,
            userMessage: bootstrapIssue.userMessage,
          );
        }

        return const AppLaunchResolution(
          destination: AppLaunchDestination.ownerPendingVerification,
        );
      }

      final known = await knownBusinesses;
      final readyBusinesses = known
          .where((b) => b.provisioningStatus == ProvisioningStatus.ready)
          .toList();

      if (readyBusinesses.isEmpty) {
        return const AppLaunchResolution(
          destination: AppLaunchDestination.onboardingWelcome,
        );
      }

      final primary = _selectPrimaryReadyBusiness(readyBusinesses);

      if (sessionContext.state == AuthSessionLaunchState.valid &&
          sessionContext.businessId == primary.businessId) {
        return AppLaunchResolution(
          destination: AppLaunchDestination.mainApp,
          sessionBusinessId: primary.businessId,
          sessionBusinessName: primary.displayName,
        );
      }

      final loginMessage = switch (sessionContext.state) {
        AuthSessionLaunchState.unavailable =>
          'The authentication server could not be reached. '
              'Sign in is required before POS features are available.',
        AuthSessionLaunchState.invalid =>
          'Your previous sign-in is no longer valid. Please sign in again.',
        AuthSessionLaunchState.valid =>
          'This sign-in belongs to a different business account.',
        AuthSessionLaunchState.none => null,
      };

      return AppLaunchResolution(
        destination: AppLaunchDestination.loginRequired,
        sessionBusinessId: primary.businessId,
        sessionBusinessName: primary.displayName,
        userMessage: loginMessage,
      );
    } on OnboardingSecureStorageException catch (error) {
      return AppLaunchResolution(
        destination: AppLaunchDestination.secureStorageUnavailable,
        userMessage: error.message,
      );
    }
  }

  static InvalidSnapshotReason? _invalidReasonFrom(
    OnboardingSnapshotRead<ProvisioningRecoverySnapshot> provisioning,
    OnboardingSnapshotRead<OwnerPendingSnapshot> ownerPending,
  ) {
    if (provisioning
        is OnboardingSnapshotInvalid<ProvisioningRecoverySnapshot>) {
      return provisioning.reason;
    }
    if (ownerPending is OnboardingSnapshotInvalid<OwnerPendingSnapshot>) {
      return ownerPending.reason;
    }
    return null;
  }

  static KnownBusinessRow _selectPrimaryReadyBusiness(
    List<KnownBusinessRow> ready,
  ) {
    ready.sort(
      (a, b) => (b.lastOpenedAtMs ?? 0).compareTo(a.lastOpenedAtMs ?? 0),
    );
    return ready.first;
  }

  static String? _registryCheck({
    required String snapshotId,
    required List<KnownBusinessRow> known,
    required bool allowAbsentRegistry,
  }) {
    final match = known.where((b) => b.businessId == snapshotId).toList();
    if (match.isEmpty) {
      if (allowAbsentRegistry) {
        return null;
      }
      return 'Onboarding state does not match this installation registry.';
    }
    return null;
  }
}
