import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_mobile/app/layout/app_shell.dart';
import 'package:pos_mobile/app/launch/app_launch_resolver.dart';
import 'package:pos_mobile/app/providers/app_launch_provider.dart';
import 'package:pos_mobile/app/router/app_routes.dart';
import 'package:pos_mobile/features/customers/presentation/customers_page.dart';
import 'package:pos_mobile/features/dashboard/presentation/dashboard_page.dart';
import 'package:pos_mobile/features/expenses/presentation/expenses_page.dart';
import 'package:pos_mobile/features/inventory/presentation/inventory_page.dart';
import 'package:pos_mobile/features/onboarding/presentation/business_registration_page.dart';
import 'package:pos_mobile/features/onboarding/presentation/launch_resolving_page.dart';
import 'package:pos_mobile/features/auth/presentation/login_page.dart';
import 'package:pos_mobile/features/onboarding/presentation/legacy_access_page.dart';
import 'package:pos_mobile/features/onboarding/presentation/local_database_recovery_page.dart';
import 'package:pos_mobile/features/onboarding/presentation/onboarding_launch_issue_page.dart';
import 'package:pos_mobile/features/onboarding/presentation/onboarding_welcome_page.dart';
import 'package:pos_mobile/features/onboarding/presentation/provisioning_recovery_page.dart';
import 'package:pos_mobile/features/onboarding/presentation/registration_complete_page.dart';
import 'package:pos_mobile/features/pos/presentation/pos_page.dart';
import 'package:pos_mobile/features/products/presentation/product_categories_page.dart';
import 'package:pos_mobile/features/products/presentation/products_page.dart';
import 'package:pos_mobile/features/purchases/presentation/purchases_page.dart';
import 'package:pos_mobile/features/reports/presentation/reports_page.dart';
import 'package:pos_mobile/features/settings/presentation/settings_page.dart';
import 'package:pos_mobile/features/suppliers/presentation/suppliers_page.dart';
import 'package:pos_mobile/shared/widgets/placeholder_feature_body.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

bool _isOnboardingPath(String path) => path.startsWith('/onboarding');

bool _isProtectedShellPath(String path) {
  if (_isOnboardingPath(path)) {
    return false;
  }
  if (path == AppRoutes.launchResolving) {
    return false;
  }
  return true;
}

String _routeForDestination(AppLaunchDestination destination) {
  return switch (destination) {
    AppLaunchDestination.resolving => AppRoutes.launchResolving,
    AppLaunchDestination.onboardingWelcome => AppRoutes.onboardingWelcome,
    AppLaunchDestination.provisioningRecover => AppRoutes.onboardingRecover,
    AppLaunchDestination.ownerPendingVerification =>
      AppRoutes.onboardingComplete,
    AppLaunchDestination.legacyAccessRequired =>
      AppRoutes.onboardingLegacyAccess,
    AppLaunchDestination.loginRequired => AppRoutes.onboardingLogin,
    AppLaunchDestination.localDatabaseRecovery =>
      AppRoutes.onboardingLocalDatabaseRecovery,
    AppLaunchDestination.onboardingSnapshotError =>
      AppRoutes.onboardingSnapshotError,
    AppLaunchDestination.secureStorageUnavailable =>
      AppRoutes.onboardingSecureStorageError,
    AppLaunchDestination.mainApp => AppRoutes.dashboard,
  };
}

String? _launchRedirectFor(
  AsyncValue<AppLaunchResolution> resolutionAsync,
  String path,
) {
  if (!resolutionAsync.hasValue) {
    if (path != AppRoutes.launchResolving) {
      return AppRoutes.launchResolving;
    }
    return null;
  }

  final destination = resolutionAsync.requireValue.destination;
  final allowedPath = _routeForDestination(destination);

  if (path == AppRoutes.launchResolving &&
      destination != AppLaunchDestination.resolving) {
    return allowedPath;
  }

  if (_isProtectedShellPath(path) && !shellAccessAllowed(destination)) {
    return allowedPath;
  }

  if (destination != AppLaunchDestination.onboardingWelcome &&
      destination != AppLaunchDestination.mainApp &&
      path != allowedPath) {
    return allowedPath;
  }

  if (destination == AppLaunchDestination.onboardingWelcome) {
    if (!_isOnboardingPath(path)) {
      return AppRoutes.onboardingWelcome;
    }
    return null;
  }

  if (destination == AppLaunchDestination.mainApp && _isOnboardingPath(path)) {
    return AppRoutes.dashboard;
  }

  return null;
}

final routerProvider = Provider<GoRouter>((ref) {
  final refreshListenable = ref.watch(routerRefreshListenableProvider);

  final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.launchResolving,
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      final resolutionAsync = ref.read(appLaunchResolutionProvider);
      return _launchRedirectFor(resolutionAsync, state.uri.path);
    },
    errorBuilder: (context, state) {
      return Scaffold(
        appBar: AppBar(title: const Text('Page not found')),
        body: PlaceholderFeatureBody(
          title: 'Unknown route',
          description: 'The requested page does not exist in this build.',
          comingInPhase: state.uri.path,
        ),
      );
    },
    routes: [
      GoRoute(
        path: AppRoutes.launchResolving,
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: LaunchResolvingPage()),
      ),
      GoRoute(
        path: AppRoutes.onboardingWelcome,
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: OnboardingWelcomePage()),
        routes: [
          GoRoute(
            path: 'register',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: BusinessRegistrationPage()),
          ),
          GoRoute(
            path: 'complete',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: RegistrationCompletePage()),
          ),
          GoRoute(
            path: 'recover',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ProvisioningRecoveryPage()),
          ),
          GoRoute(
            path: 'legacy-access',
            pageBuilder: (context, state) => NoTransitionPage(
              child: Consumer(
                builder: (context, ref, _) {
                  final msg = ref
                      .watch(appLaunchResolutionProvider)
                      .value
                      ?.userMessage;
                  return LegacyAccessPage(message: msg);
                },
              ),
            ),
          ),
          GoRoute(
            path: 'login',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: LoginPage()),
          ),
          GoRoute(
            path: 'local-database',
            pageBuilder: (context, state) => NoTransitionPage(
              child: Consumer(
                builder: (context, ref, _) {
                  final msg =
                      ref
                          .watch(appLaunchResolutionProvider)
                          .value
                          ?.userMessage ??
                      'The local business database could not be opened.';
                  return LocalDatabaseRecoveryPage(message: msg);
                },
              ),
            ),
          ),
          GoRoute(
            path: 'snapshot-error',
            pageBuilder: (context, state) => NoTransitionPage(
              child: Consumer(
                builder: (context, ref, _) {
                  final msg =
                      ref
                          .watch(appLaunchResolutionProvider)
                          .value
                          ?.userMessage ??
                      'Onboarding state on this device could not be verified.';
                  return OnboardingLaunchIssuePage(
                    title: 'Onboarding data error',
                    message: msg,
                  );
                },
              ),
            ),
          ),
          GoRoute(
            path: 'secure-storage-error',
            pageBuilder: (context, state) => NoTransitionPage(
              child: Consumer(
                builder: (context, ref, _) {
                  final msg =
                      ref
                          .watch(appLaunchResolutionProvider)
                          .value
                          ?.userMessage ??
                      'Secure storage is unavailable.';
                  return OnboardingLaunchIssuePage(
                    title: 'Secure storage unavailable',
                    message: msg,
                  );
                },
              ),
            ),
          ),
        ],
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.dashboard,
            name: AppRoutes.dashboardName,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: DashboardPage()),
          ),
          GoRoute(
            path: AppRoutes.pos,
            name: AppRoutes.posName,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: PosPage()),
          ),
          GoRoute(
            path: AppRoutes.products,
            name: AppRoutes.productsName,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ProductsPage()),
            routes: [
              GoRoute(
                path: 'categories',
                name: AppRoutes.productCategoriesName,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: ProductCategoriesPage()),
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.inventory,
            name: AppRoutes.inventoryName,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: InventoryPage()),
          ),
          GoRoute(
            path: AppRoutes.customers,
            name: AppRoutes.customersName,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: CustomersPage()),
          ),
          GoRoute(
            path: AppRoutes.suppliers,
            name: AppRoutes.suppliersName,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: SuppliersPage()),
          ),
          GoRoute(
            path: AppRoutes.purchases,
            name: AppRoutes.purchasesName,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: PurchasesPage()),
          ),
          GoRoute(
            path: AppRoutes.expenses,
            name: AppRoutes.expensesName,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ExpensesPage()),
          ),
          GoRoute(
            path: AppRoutes.reports,
            name: AppRoutes.reportsName,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ReportsPage()),
          ),
          GoRoute(
            path: AppRoutes.settings,
            name: AppRoutes.settingsName,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: SettingsPage()),
          ),
        ],
      ),
    ],
  );

  ref.onDispose(router.dispose);

  return router;
});
