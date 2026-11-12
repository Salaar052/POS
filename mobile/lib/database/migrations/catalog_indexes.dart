import 'package:pos_mobile/database/app_database.dart';

/// Partial unique indexes for active catalog rows (SQLite).
Future<void> applyCatalogIndexes(AppDatabase db) async {
  await db.customStatement('''
CREATE UNIQUE INDEX IF NOT EXISTS product_categories_active_name_uq
ON product_categories (normalized_name)
WHERE archived_at_ms IS NULL AND is_active = 1;
''');
  await db.customStatement('''
CREATE UNIQUE INDEX IF NOT EXISTS products_active_sku_uq
ON products (sku_normalized)
WHERE sku_normalized IS NOT NULL AND archived_at_ms IS NULL AND is_active = 1;
''');
  await db.customStatement('''
CREATE UNIQUE INDEX IF NOT EXISTS products_active_barcode_uq
ON products (barcode_normalized)
WHERE barcode_normalized IS NOT NULL AND archived_at_ms IS NULL AND is_active = 1;
''');
}
