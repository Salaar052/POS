import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_mobile/app/app.dart';
import 'package:pos_mobile/app/layout/app_shell.dart';
import 'package:pos_mobile/app/layout/desktop_sidebar.dart';
import 'package:pos_mobile/app/providers/business_status_provider.dart';
import 'package:pos_mobile/app/providers/theme_provider.dart';
import 'package:pos_mobile/app/router/app_router.dart';
import 'package:pos_mobile/app/router/app_routes.dart';
import 'package:pos_mobile/data/services/database_service.dart';

import '../helpers/test_app_container.dart';

void main() {
  Future<void> pumpPakPosApp(
    WidgetTester tester, {
    required ProviderContainer container,
    Size size = const Size(1280, 800),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const PakPosApp()),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  group('GoRouter', () {
    late ProviderContainer container;
    late DatabaseService service;

    setUp(() async {
      final handle = createInMemoryAppContainer();
      container = handle.container;
      service = handle.service;
      await container.read(businessProvisionStatusProvider.future);
    });

    tearDown(() async {
      container.dispose();
      await service.dispose();
    });

    testWidgets('renders each shell route destination', (tester) async {
      await pumpPakPosApp(tester, container: container);
      final router = container.read(routerProvider);

      const expectations = <String, String>{
        AppRoutes.dashboard: 'Welcome to Pak POS',
        AppRoutes.pos: 'Point of Sale',
        AppRoutes.products: 'Products',
        AppRoutes.inventory: 'Inventory',
        AppRoutes.customers: 'Customers',
        AppRoutes.suppliers: 'Suppliers',
        AppRoutes.purchases: 'Purchases',
        AppRoutes.expenses: 'Expenses',
        AppRoutes.reports: 'Reports',
        AppRoutes.settings: 'Settings',
      };

      for (final entry in expectations.entries) {
        router.go(entry.key);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));
        expect(find.text(entry.value), findsWidgets);
        expect(find.byType(AppShell), findsOneWidget);
      }
    });

    testWidgets('desktop sidebar reflects the active route', (tester) async {
      await pumpPakPosApp(tester, container: container);

      container.read(routerProvider).go(AppRoutes.products);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      final productsTile = tester.widget<ListTile>(
        find.descendant(
          of: find.byType(DesktopSidebar),
          matching: find.widgetWithText(ListTile, 'Products'),
        ),
      );
      expect(productsTile.selected, isTrue);
    });

    testWidgets('compact drawer navigates and closes', (tester) async {
      await pumpPakPosApp(
        tester,
        container: container,
        size: const Size(600, 800),
      );

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ListTile, 'Reports'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Reports'), findsWidgets);

      final scaffold = tester.state<ScaffoldState>(find.byType(Scaffold).first);
      expect(scaffold.isDrawerOpen, isFalse);
    });

    testWidgets('unknown route shows error page', (tester) async {
      await pumpPakPosApp(tester, container: container);
      container.read(routerProvider).go('/does-not-exist');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Unknown route'), findsOneWidget);
      expect(find.text('Page not found'), findsOneWidget);
    });

    testWidgets('theme toggle updates theme provider', (tester) async {
      await pumpPakPosApp(tester, container: container);

      container.read(routerProvider).go(AppRoutes.settings);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(container.read(themeProvider), ThemeMode.light);

      await tester.tap(find.byType(SwitchListTile));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(container.read(themeProvider), ThemeMode.dark);
    });
  });
}
