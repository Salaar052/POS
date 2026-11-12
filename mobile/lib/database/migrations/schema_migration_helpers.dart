import 'package:drift/drift.dart';

/// Adds customer ledger payment metadata when upgrading legacy schema v6 files.
Future<void> addCustomerLedgerPaymentColumnsIfNeeded(
  GeneratedDatabase db,
) async {
  final rows = await db
      .customSelect('PRAGMA table_info(customer_ledger_entries)')
      .get();
  final columns = rows.map((row) => row.data['name'] as String).toSet();
  if (!columns.contains('payment_method')) {
    await db.customStatement(
      'ALTER TABLE customer_ledger_entries '
      'ADD COLUMN payment_method TEXT NULL',
    );
  }
  if (!columns.contains('reference_number')) {
    await db.customStatement(
      'ALTER TABLE customer_ledger_entries '
      'ADD COLUMN reference_number TEXT NULL',
    );
  }
}
