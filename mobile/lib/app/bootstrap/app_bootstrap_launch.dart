import 'package:flutter/foundation.dart';
import 'package:pos_mobile/app/bootstrap/app_runtime.dart';
import 'package:pos_mobile/app/bootstrap/bootstrap_launch_issue.dart';
import 'package:pos_mobile/data/services/business_database_coordinator.dart';
import 'package:pos_mobile/database/enums/provisioning_status.dart';
import 'package:pos_mobile/features/onboarding/data/onboarding_recovery_store.dart';
import 'package:pos_mobile/features/onboarding/data/onboarding_storage_outcomes.dart';

/// Chooses bootstrap vs business SQLite after [AppRuntime.start].
class AppBootstrapLaunch {
  const AppBootstrapLaunch._();

  static BootstrapLaunchIssue? _lastIssue;

  static BootstrapLaunchIssue? get lastIssue => _lastIssue;

  @visibleForTesting
  static void clearLastIssueForTests() {
    _lastIssue = null;
  }

  /// Opens a READY business only when onboarding policy allows shell-related DB access.
  static Future<void> openBusinessDatabaseWhenAllowed({
    required OnboardingRecoveryStore recoveryStore,
    required bool allowBusinessDatabaseForOwnerPending,
  }) async {
    _lastIssue = null;

    final provisioning = await recoveryStore.readProvisioningRecovery();
    if (provisioning
        is OnboardingSnapshotPresent<ProvisioningRecoverySnapshot>) {
      return;
    }

    if (!allowBusinessDatabaseForOwnerPending) {
      return;
    }

    final ownerPending = await recoveryStore.readOwnerPending();
    if (ownerPending is! OnboardingSnapshotPresent<OwnerPendingSnapshot>) {
      return;
    }

    final businessId = ownerPending.value.businessId;
    try {
      await AppRuntime.openReadyBusinessAndSwitch(businessId: businessId);
    } on BusinessDatabaseException catch (error) {
      _lastIssue = BootstrapLaunchIssue(
        code: BootstrapLaunchIssueCode.businessDatabaseOpenFailed,
        businessId: businessId,
        userMessage: error.message,
      );
    } catch (_) {
      _lastIssue = BootstrapLaunchIssue(
        code: BootstrapLaunchIssueCode.businessDatabaseOpenFailed,
        businessId: businessId,
        userMessage:
            'The local business database could not be opened. '
            'Your files were not modified.',
      );
    }
  }

  /// Legacy / future session path: skip automatic open until authentication exists.
  static Future<bool> hasReadyBusinessInRegistry() async {
    final known = await AppRuntime.coordinator.listKnownBusinesses();
    return known.any(
      (business) => business.provisioningStatus == ProvisioningStatus.ready,
    );
  }
}
