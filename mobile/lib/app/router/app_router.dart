import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_mobile/app/layout/app_shell.dart';
import 'package:pos_mobile/app/router/app_routes.dart';
import 'package:pos_mobile/features/customers/presentation/customers_page.dart';
import 'package:pos_mobile/features/dashboard/presentation/dashboard_page.dart';
import 'package:pos_mobile/features/expenses/presentation/expenses_page.dart';
import 'package:pos_mobile/features/inventory/presentation/inventory_page.dart';
import 'package:pos_mobile/features/pos/presentation/pos_page.dart';
import 'package:pos_mobile/features/products/presentation/products_page.dart';
import 'package:pos_mobile/features/purchases/presentation/purchases_page.dart';
import 'package:pos_mobile/features/reports/presentation/reports_page.dart';
import 'package:pos_mobile/features/settings/presentation/settings_page.dart';
import 'package:pos_mobile/features/suppliers/presentation/suppliers_page.dart';
import 'package:pos_mobile/shared/widgets/placeholder_feature_body.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.dashboard,
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
});
