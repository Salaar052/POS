import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_mobile/app/providers/catalog_providers.dart';
import 'package:pos_mobile/app/providers/database_providers.dart';
import 'package:pos_mobile/data/repositories/purchase_repository.dart';
import 'package:pos_mobile/data/repositories/supplier_ledger_repository.dart';
import 'package:pos_mobile/data/repositories/supplier_repository.dart';

final supplierRepositoryProvider = Provider<SupplierRepository>((ref) {
  assertCatalogDatabaseReady(ref.read(databaseServiceProvider));
  return SupplierRepository(ref.watch(databaseRunnerProvider));
});

final supplierLedgerRepositoryProvider = Provider<SupplierLedgerRepository>((
  ref,
) {
  assertCatalogDatabaseReady(ref.read(databaseServiceProvider));
  return SupplierLedgerRepository(ref.watch(databaseRunnerProvider));
});

final purchaseRepositoryProvider = Provider<PurchaseRepository>((ref) {
  assertCatalogDatabaseReady(ref.read(databaseServiceProvider));
  return PurchaseRepository(ref.watch(databaseRunnerProvider));
});
