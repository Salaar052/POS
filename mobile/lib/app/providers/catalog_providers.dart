import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_mobile/app/providers/auth_providers.dart';
import 'package:pos_mobile/app/providers/database_providers.dart';
import 'package:pos_mobile/data/repositories/product_category_repository.dart';
import 'package:pos_mobile/data/repositories/product_repository.dart';
import 'package:pos_mobile/data/services/database_service.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  assertCatalogDatabaseReady(ref.read(databaseServiceProvider));
  return ProductRepository(ref.watch(databaseRunnerProvider));
});

final productCategoryRepositoryProvider = Provider<ProductCategoryRepository>((
  ref,
) {
  assertCatalogDatabaseReady(ref.read(databaseServiceProvider));
  return ProductCategoryRepository(ref.watch(databaseRunnerProvider));
});

/// Ensures catalog repositories only run against the active business database file.
void assertCatalogDatabaseReady(DatabaseService service) {
  if (service.isBootstrap) {
    throw StateError(
      'Catalog requires an open business database. '
      'Complete sign-in and business selection first.',
    );
  }
  if (service.businessId == null || service.businessId!.isEmpty) {
    throw StateError('Business database identity is missing.');
  }
}

/// Validates the opened SQLite file matches the authenticated business id when known.
final catalogSessionAlignmentProvider = Provider<void>((ref) {
  final service = ref.watch(databaseServiceProvider);
  final sessionBusinessId = ref
      .watch(authSessionControllerProvider)
      .activeBusinessId;
  if (service.businessId != null &&
      sessionBusinessId != null &&
      service.businessId != sessionBusinessId) {
    throw StateError(
      'Catalog database does not match the signed-in business. '
      'Sign out and open the correct business.',
    );
  }
});
