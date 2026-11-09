import 'package:pos_mobile/data/repositories/database_runner.dart';
import 'package:pos_mobile/database/app_database.dart';
import 'package:pos_mobile/database/connection/open_database.dart';

class TestDatabaseHarness {
  TestDatabaseHarness(this.database) : runner = DatabaseRunner(database);

  final AppDatabase database;
  final DatabaseRunner runner;

  static TestDatabaseHarness memory() {
    final db = openMemoryDatabase();
    return TestDatabaseHarness(db);
  }

  Future<void> close() async {
    await database.close();
  }
}
