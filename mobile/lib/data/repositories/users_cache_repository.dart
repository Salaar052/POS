import 'package:drift/drift.dart';
import 'package:pos_mobile/database/app_database.dart';
import 'package:pos_mobile/database/enums/user_role.dart';
import 'package:pos_mobile/data/repositories/database_runner.dart';
import 'package:pos_mobile/data/repositories/local_business_repository.dart';

class UsersCacheRepository {
  UsersCacheRepository(this._runner);

  final DatabaseRunner _runner;

  Future<void> upsertUser({
    required String userId,
    required String displayName,
    required String role,
    bool isActive = true,
    int? lastSyncedAtMs,
  }) async {
    final businessId = await LocalBusinessRepository(_runner)
        .requireBusinessId();
    if (!UserRole.isValid(role)) {
      throw ArgumentError('Invalid role');
    }
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    await _runner.database
        .into(_runner.database.usersCache)
        .insertOnConflictUpdate(
          UsersCacheCompanion.insert(
            userId: userId,
            businessId: businessId,
            displayName: displayName,
            role: role,
            isActive: Value(isActive),
            lastSyncedAtMs: Value(lastSyncedAtMs),
            createdAtMs: now,
            updatedAtMs: now,
          ),
        );
  }
}
