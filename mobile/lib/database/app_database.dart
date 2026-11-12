import 'package:drift/drift.dart';
import 'package:pos_mobile/database/migrations/database_triggers.dart'
    show applyDatabaseTriggers, applyInstallationProfileTriggers;
import 'package:pos_mobile/database/tables/app_settings.dart';
import 'package:pos_mobile/database/tables/audit_events.dart';
import 'package:pos_mobile/database/tables/local_business.dart';
import 'package:pos_mobile/database/tables/local_device.dart';
import 'package:pos_mobile/database/tables/sync_conflicts.dart';
import 'package:pos_mobile/database/tables/sync_cursors.dart';
import 'package:pos_mobile/database/tables/sync_operations.dart';
import 'package:pos_mobile/database/tables/installation_profile.dart';
import 'package:pos_mobile/database/tables/known_businesses.dart';
import 'package:pos_mobile/database/tables/product_categories.dart';
import 'package:pos_mobile/database/tables/products.dart';
import 'package:pos_mobile/database/tables/users_cache.dart';
import 'package:pos_mobile/database/migrations/catalog_indexes.dart';
import 'package:pos_mobile/database/migrations/inventory_indexes.dart';
import 'package:pos_mobile/database/tables/inventory_balances.dart';
import 'package:pos_mobile/database/tables/stock_movements.dart';
import 'package:pos_mobile/database/migrations/purchasing_indexes.dart';
import 'package:pos_mobile/database/tables/document_sequences.dart';
import 'package:pos_mobile/database/tables/purchase_items.dart';
import 'package:pos_mobile/database/tables/purchase_payments.dart';
import 'package:pos_mobile/database/tables/purchase_return_items.dart';
import 'package:pos_mobile/database/tables/purchase_returns.dart';
import 'package:pos_mobile/database/tables/purchases.dart';
import 'package:pos_mobile/database/tables/supplier_ledger_entries.dart';
import 'package:pos_mobile/database/tables/suppliers.dart';
import 'package:pos_mobile/database/migrations/sales_indexes.dart';
import 'package:pos_mobile/database/migrations/schema_migration_helpers.dart';
import 'package:pos_mobile/database/tables/customers.dart';
import 'package:pos_mobile/database/tables/customer_ledger_entries.dart';
import 'package:pos_mobile/database/tables/sales.dart';
import 'package:pos_mobile/database/tables/sale_items.dart';
import 'package:pos_mobile/database/tables/sale_payments.dart';
import 'package:pos_mobile/database/tables/sale_returns.dart';
import 'package:pos_mobile/database/tables/sale_return_items.dart';

part 'app_database.g.dart';

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
    Customers,
    Sales,
    SaleItems,
    SalePayments,
    CustomerLedgerEntries,
    SaleReturns,
    SaleReturnItems,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 7;

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
      await applySalesIndexes(this);
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
      if (from < 6 && to >= 6) {
        await m.createTable(customers);
        await m.createTable(sales);
        await m.createTable(saleItems);
        await m.createTable(salePayments);
        await m.createTable(customerLedgerEntries);
        await m.createTable(saleReturns);
        await m.createTable(saleReturnItems);
        await applySalesIndexes(this);
      }
      if (from < 7 && to >= 7) {
        await addCustomerLedgerPaymentColumnsIfNeeded(this);
      }
    },
  );
}
