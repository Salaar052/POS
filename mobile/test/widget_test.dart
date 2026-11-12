import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_mobile/app/providers/business_status_provider.dart';
import 'package:pos_mobile/app/providers/database_providers.dart';
import 'package:pos_mobile/app/providers/theme_provider.dart';
import 'package:pos_mobile/app/theme/app_theme.dart';
import 'package:pos_mobile/data/services/database_service.dart';
import 'package:pos_mobile/features/dashboard/presentation/dashboard_page.dart';
import 'package:pos_mobile/features/settings/presentation/settings_page.dart';

void main() {
  testWidgets('Dashboard shows database ready and unprovisioned business', (
    tester,
  ) async {
    final service = DatabaseService.inMemory();
    addTearDown(() => service.dispose());

    final container = ProviderContainer(
      overrides: [databaseServiceProvider.overrideWithValue(service)],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: DashboardPage()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    final status = await container.read(businessProvisionStatusProvider.future);
    expect(status.isProvisioned, isFalse);

    expect(find.textContaining('Welcome to Pak POS'), findsOneWidget);
    expect(find.textContaining('Connected (schema v6)'), findsOneWidget);
  });

  testWidgets('Settings toggles dark theme', (tester) async {
    final service = DatabaseService.inMemory();
    addTearDown(() => service.dispose());

    final container = ProviderContainer(
      overrides: [databaseServiceProvider.overrideWithValue(service)],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: container.read(themeProvider),
          home: const SettingsPage(),
        ),
      ),
    );
    await tester.pump();

    expect(container.read(themeProvider), ThemeMode.light);

    await tester.tap(find.byType(SwitchListTile));
    await tester.pump();

    expect(container.read(themeProvider), ThemeMode.dark);
  });
}
