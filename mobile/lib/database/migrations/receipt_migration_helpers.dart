import 'package:drift/drift.dart';
import 'package:pos_mobile/database/app_database.dart';

Future<void> addSaleInvoiceNumberColumnIfNeeded(AppDatabase db) async {
  final columns = await db
      .customSelect('PRAGMA table_info(sales)')
      .get();
  final names = columns.map((r) => r.data['name'] as String).toList();
  if (names.contains('invoice_number')) {
    return;
  }
  await db.customStatement(
    'ALTER TABLE sales ADD COLUMN invoice_number TEXT NULL',
  );
}

/// Backfills invoice numbers for sales completed before Phase 5.1.
Future<void> backfillLegacySaleInvoices(AppDatabase db) async {
  await db.customStatement('''
UPDATE sales
SET invoice_number = 'INV-LEG-' || sale_number
WHERE status = 'COMPLETED'
  AND (invoice_number IS NULL OR invoice_number = '');
''');
}

Future<void> applyReceiptIndexes(GeneratedDatabase db) async {
  await db.customStatement('''
CREATE UNIQUE INDEX IF NOT EXISTS sales_invoice_number_uq
ON sales (invoice_number)
WHERE invoice_number IS NOT NULL;
''');
  await db.customStatement('''
CREATE INDEX IF NOT EXISTS print_attempts_reference_idx
ON print_attempts (reference_type, reference_id, created_at_ms DESC);
''');
}
