import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_mobile/app/providers/business_status_provider.dart';
import 'package:pos_mobile/app/providers/database_providers.dart';
import 'package:pos_mobile/data/services/database_service.dart';
import 'package:pos_mobile/features/products/presentation/products_page.dart';

import '../../helpers/catalog_test_harness.dart';

void main() {
  testWidgets('shows bootstrap message when business database is not open', (
    tester,
  ) async {
    final bootstrap = DatabaseService.inMemory();
    addTearDown(bootstrap.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseServiceProvider.overrideWithValue(bootstrap)],
        child: const MaterialApp(home: ProductsPage()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Sign in'), findsOneWidget);
  });

  testWidgets('renders empty catalog state for provisioned business database', (
    tester,
  ) async {
    final catalog = await CatalogTestHarness.create();
    addTearDown(catalog.dispose);
    final service = DatabaseService.inMemory(
      database: catalog.harness.database,
      businessId: catalog.businessId,
    );
    addTearDown(service.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseServiceProvider.overrideWithValue(service),
          businessProvisionStatusProvider.overrideWith(
            (ref) async => const BusinessProvisionStatus(
              isProvisioned: true,
              businessName: 'Catalog Test Shop',
            ),
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: SizedBox(height: 800, width: 1200, child: ProductsPage()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('No products yet'), findsOneWidget);
  });
}
