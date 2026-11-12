import 'package:drift/drift.dart';
import 'package:pos_mobile/database/migrations/catalog_indexes.dart';
import 'package:pos_mobile/database/migrations/database_triggers.dart'
    show applyDatabaseTriggers, applyInstallationProfileTriggers;
import 'package:pos_mobile/database/migrations/inventory_indexes.dart';
import 'package:pos_mobile/database/migrations/purchasing_indexes.dart';
import 'package:pos_mobile/database/tables/app_settings.dart';
import 'package:pos_mobile/database/tables/audit_events.dart';
import 'package:pos_mobile/database/tables/document_sequences.dart';
import 'package:pos_mobile/database/tables/installation_profile.dart';
import 'package:pos_mobile/database/tables/inventory_balances.dart';
import 'package:pos_mobile/database/tables/known_businesses.dart';
import 'package:pos_mobile/database/tables/local_business.dart';
import 'package:pos_mobile/database/tables/local_device.dart';
import 'package:pos_mobile/database/tables/product_categories.dart';
import 'package:pos_mobile/database/tables/products.dart';
import 'package:pos_mobile/database/tables/purchase_items.dart';
import 'package:pos_mobile/database/tables/purchase_payments.dart';
import 'package:pos_mobile/database/tables/purchase_return_items.dart';
import 'package:pos_mobile/database/tables/purchase_returns.dart';
import 'package:pos_mobile/database/tables/purchases.dart';
import 'package:pos_mobile/database/tables/stock_movements.dart';
import 'package:pos_mobile/database/tables/supplier_ledger_entries.dart';
import 'package:pos_mobile/database/tables/suppliers.dart';
import 'package:pos_mobile/database/tables/sync_conflicts.dart';
import 'package:pos_mobile/database/tables/sync_cursors.dart';
import 'package:pos_mobile/database/tables/sync_operations.dart';
import 'package:pos_mobile/database/tables/users_cache.dart';

part 'legacy_v5_app_database.g.dart';

/// Frozen schema-v5 Drift definition for genuine v5→v6 migration tests.
@DriftDatabase(
  tables: [
    LocalBusiness,
    LocalDevice,
    UsersCache,
    AppSettings,
    SyncOperations,
    SyncCursors,
    SyncConflicts,
    AuditEvents,
    InstallationProfile,
    KnownBusinesses,
    ProductCategories,
    Products,
    InventoryBalances,
    StockMovements,
    Suppliers,
    DocumentSequences,
    Purchases,
    PurchaseItems,
    PurchasePayments,
    SupplierLedgerEntries,
    PurchaseReturns,
    PurchaseReturnItems,
  ],
)
class LegacyV5AppDatabase extends _$LegacyV5AppDatabase {
  LegacyV5AppDatabase(super.e);

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
    onCreate: (Migrator m) async {
      await m.createAll();
      await applyDatabaseTriggers(this);
      await applyCatalogIndexes(this);
      await applyInventoryIndexes(this);
      await applyPurchasingIndexes(this);
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2 && to >= 2) {
        await m.createTable(installationProfile);
        await m.createTable(knownBusinesses);
        await applyInstallationProfileTriggers(this);
      }
      if (from < 3 && to >= 3) {
        await m.createTable(productCategories);
        await m.createTable(products);
        await applyCatalogIndexes(this);
      }
      if (from < 4 && to >= 4) {
        await m.createTable(inventoryBalances);
        await m.createTable(stockMovements);
        await applyInventoryIndexes(this);
      }
      if (from < 5 && to >= 5) {
        await m.createTable(suppliers);
        await m.createTable(documentSequences);
        await m.createTable(purchases);
        await m.createTable(purchaseItems);
        await m.createTable(purchasePayments);
        await m.createTable(supplierLedgerEntries);
        await m.createTable(purchaseReturns);
        await m.createTable(purchaseReturnItems);
        await applyPurchasingIndexes(this);
      }
    },
  );
}
