import 'package:pos_mobile/database/app_database.dart';

Future<void> applySalesIndexes(AppDatabase db) async {
  await db.customStatement('''
CREATE UNIQUE INDEX IF NOT EXISTS sales_number_uq ON sales (sale_number);
''');
  await db.customStatement('''
CREATE UNIQUE INDEX IF NOT EXISTS sales_checkout_idempotency_uq
ON sales (checkout_idempotency_key)
WHERE checkout_idempotency_key IS NOT NULL;
''');
  await db.customStatement('''
CREATE INDEX IF NOT EXISTS sales_customer_created_idx
ON sales (customer_id, created_at_ms DESC);
''');
  await db.customStatement('''
CREATE UNIQUE INDEX IF NOT EXISTS sale_payments_idempotency_uq
ON sale_payments (idempotency_key);
''');
  await db.customStatement('''
CREATE UNIQUE INDEX IF NOT EXISTS customer_ledger_reference_uq
ON customer_ledger_entries (reference_type, reference_id, entry_type);
''');
  await db.customStatement('''
CREATE INDEX IF NOT EXISTS customers_search_idx ON customers (normalized_name);
''');
  await db.customStatement('''
CREATE UNIQUE INDEX IF NOT EXISTS sale_returns_idempotency_uq
ON sale_returns (idempotency_key);
''');
}
