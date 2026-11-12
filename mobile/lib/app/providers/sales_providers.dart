import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_mobile/app/providers/catalog_providers.dart';
import 'package:pos_mobile/app/providers/database_providers.dart';
import 'package:pos_mobile/data/repositories/customer_ledger_repository.dart';
import 'package:pos_mobile/data/repositories/customer_repository.dart';
import 'package:pos_mobile/data/repositories/sales_repository.dart';

final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  assertCatalogDatabaseReady(ref.read(databaseServiceProvider));
  return CustomerRepository(ref.watch(databaseRunnerProvider));
});

final customerLedgerRepositoryProvider = Provider<CustomerLedgerRepository>((
  ref,
) {
  assertCatalogDatabaseReady(ref.read(databaseServiceProvider));
  return CustomerLedgerRepository(ref.watch(databaseRunnerProvider));
});

final salesRepositoryProvider = Provider<SalesRepository>((ref) {
  assertCatalogDatabaseReady(ref.read(databaseServiceProvider));
  return SalesRepository(ref.watch(databaseRunnerProvider));
});
