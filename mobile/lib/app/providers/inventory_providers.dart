import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_mobile/app/providers/catalog_providers.dart';
import 'package:pos_mobile/app/providers/database_providers.dart';
import 'package:pos_mobile/data/repositories/inventory_repository.dart';

final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  assertCatalogDatabaseReady(ref.read(databaseServiceProvider));
  return InventoryRepository(ref.watch(databaseRunnerProvider));
});
