import 'package:drift/drift.dart';

@DataClassName('ProductCategoryRow')
class ProductCategories extends Table {
  TextColumn get id => text()();

  TextColumn get name => text()();

  TextColumn get normalizedName => text()();

  TextColumn get description => text().nullable()();

  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  IntColumn get createdAtMs => integer()();

  IntColumn get updatedAtMs => integer()();

  IntColumn get archivedAtMs => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
