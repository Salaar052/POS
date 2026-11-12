import 'package:drift/drift.dart';

@DataClassName('PrintAttemptRow')
class PrintAttempts extends Table {
  TextColumn get id => text()();

  TextColumn get referenceType => text()();

  TextColumn get referenceId => text()();

  TextColumn get documentNumber => text()();

  TextColumn get printerId => text().nullable()();

  IntColumn get paperWidthMm => integer()();

  TextColumn get printType => text()();

  TextColumn get result => text()();

  TextColumn get errorDetail => text().nullable()();

  IntColumn get createdAtMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
