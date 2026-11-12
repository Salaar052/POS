import 'package:pos_mobile/database/app_database.dart';

Future<void> applyPurchasingIndexes(AppDatabase db) async {
  await db.customStatement('''
CREATE UNIQUE INDEX IF NOT EXISTS purchases_number_uq
ON purchases (purchase_number);
''');
  await db.customStatement('''
CREATE INDEX IF NOT EXISTS purchases_supplier_date_idx
ON purchases (supplier_id, purchase_date_ms DESC);
''');
  await db.customStatement('''
CREATE UNIQUE INDEX IF NOT EXISTS purchase_payments_idempotency_uq
ON purchase_payments (idempotency_key);
''');
  await db.customStatement('''
CREATE UNIQUE INDEX IF NOT EXISTS supplier_ledger_reference_uq
ON supplier_ledger_entries (reference_type, reference_id, entry_type);
''');
  await db.customStatement('''
CREATE INDEX IF NOT EXISTS suppliers_search_name_idx
ON suppliers (normalized_name);
''');
  await db.customStatement('''
CREATE UNIQUE INDEX IF NOT EXISTS purchase_returns_idempotency_uq
ON purchase_returns (idempotency_key);
''');
}
