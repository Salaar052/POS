import 'package:drift/drift.dart';
import 'package:pos_mobile/database/tables/products.dart';

@DataClassName('StockMovementRow')
class StockMovements extends Table {
  TextColumn get id => text()();

  TextColumn get productId => text().references(Products, #id)();

  TextColumn get movementType => text()();

  IntColumn get quantityBase => integer()();

  IntColumn get previousQuantityBase => integer()();

  IntColumn get resultingQuantityBase => integer()();

  TextColumn get referenceType => text().nullable()();

  TextColumn get referenceId => text().nullable()();

  TextColumn get reason => text().nullable()();

  TextColumn get notes => text().nullable()();

  TextColumn get createdBy => text().nullable()();

  IntColumn get createdAtMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
