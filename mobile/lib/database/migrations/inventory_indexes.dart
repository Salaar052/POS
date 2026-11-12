import 'package:pos_mobile/database/app_database.dart';

Future<void> applyInventoryIndexes(AppDatabase db) async {
  await db.customStatement('''
CREATE UNIQUE INDEX IF NOT EXISTS stock_movements_reference_uq
ON stock_movements (reference_type, reference_id, product_id, movement_type)
WHERE reference_id IS NOT NULL AND reference_type IS NOT NULL;
''');
  await db.customStatement('''
CREATE INDEX IF NOT EXISTS stock_movements_product_created_idx
ON stock_movements (product_id, created_at_ms DESC);
''');
  await db.customStatement('''
CREATE INDEX IF NOT EXISTS inventory_balances_qty_idx
ON inventory_balances (quantity_on_hand_base);
''');
}
