import 'package:drift/drift.dart';

@DataClassName('DocumentSequenceRow')
class DocumentSequences extends Table {
  TextColumn get sequenceKey => text()();

  IntColumn get nextNumber => integer()();

  @override
  Set<Column<Object>> get primaryKey => {sequenceKey};
}
