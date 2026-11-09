import 'package:pos_mobile/database/app_database.dart';

class DatabaseRunner {
  DatabaseRunner(this._db);

  final AppDatabase _db;

  Future<T> runInTransaction<T>(Future<T> Function() action) {
    return _db.transaction(action);
  }

  AppDatabase get database => _db;
}
