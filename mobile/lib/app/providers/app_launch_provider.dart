import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_mobile/app/bootstrap/app_bootstrap_launch.dart';
import 'package:pos_mobile/app/bootstrap/app_runtime.dart';
import 'package:pos_mobile/app/launch/app_launch_resolver.dart';
import 'package:pos_mobile/database/enums/provisioning_status.dart';
import 'package:pos_mobile/features/auth/domain/auth_session_launch_state.dart';
import 'package:pos_mobile/app/providers/auth_providers.dart';
import 'package:pos_mobile/app/providers/onboarding_providers.dart';

typedef AppLaunchResolutionResult = AppLaunchResolution;

final routerRefreshListenableProvider = Provider<ValueNotifier<int>>((ref) {
  final notifier = ValueNotifier<int>(0);

  void requestRouterRefresh() {
    unawaited(Future<void>.microtask(() => notifier.value++));
  }

  void onRuntimeChange() {
    requestRouterRefresh();
    ref.invalidate(appLaunchResolutionProvider);
  }

  ref.listen<AsyncValue<AppLaunchResolution>>(appLaunchResolutionProvider, (
    previous,
    next,
  ) {
    final prevDest = previous?.value?.destination;
    final nextDest = next.value?.destination;
    if (previous?.isLoading == next.isLoading && prevDest == nextDest) {
      return;
    }
    requestRouterRefresh();
  });

  AppRuntime.containerRevision.addListener(onRuntimeChange);
  ref.onDispose(() {
    AppRuntime.containerRevision.removeListener(onRuntimeChange);
    notifier.dispose();
  });
  return notifier;
});

final appLaunchResolutionProvider = FutureProvider<AppLaunchResolution>((
  ref,
) async {
  final _ = AppRuntime.containerRevision.value;
  final store = ref.watch(onboardingRecoveryStoreProvider);
  final known = await AppRuntime.coordinator.listKnownBusinesses();
  final ready = known
      .where((b) => b.provisioningStatus == ProvisioningStatus.ready)
      .toList();

  AuthSessionLaunchContext sessionContext = AuthSessionLaunchContext.none;
  if (ready.isNotEmpty) {
    final primary = ready.reduce(
      (a, b) => (b.lastOpenedAtMs ?? 0) > (a.lastOpenedAtMs ?? 0) ? b : a,
    );
    sessionContext = await ref
        .read(authSessionLaunchServiceProvider)
        .resolveForBusiness(businessId: primary.businessId);
  }

  final resolution = await AppLaunchResolver.resolve(
    store: store,
    knownBusinesses: Future.value(known),
    sessionContext: sessionContext,
    bootstrapIssue: AppBootstrapLaunch.lastIssue,
  );

  if (resolution.destination == AppLaunchDestination.mainApp &&
      resolution.sessionBusinessId != null) {
    try {
      await AppRuntime.openReadyBusinessAndSwitch(
        businessId: resolution.sessionBusinessId!,
      );
    } on Object {
      return AppLaunchResolution(
        destination: AppLaunchDestination.loginRequired,
        sessionBusinessId: resolution.sessionBusinessId,
        sessionBusinessName: resolution.sessionBusinessName,
        userMessage:
            'The local business database could not be opened for this account.',
      );
    }
  }

  return resolution;
});

/// Convenience destination for router redirects.
final appLaunchDestinationProvider = Provider<AsyncValue<AppLaunchDestination>>(
  (ref) {
    final resolution = ref.watch(appLaunchResolutionProvider);
    return resolution.whenData((value) => value.destination);
  },
);

bool shellAccessAllowed(AppLaunchDestination destination) {
  return destination == AppLaunchDestination.mainApp;
}
