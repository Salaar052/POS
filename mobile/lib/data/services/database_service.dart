import 'package:flutter/foundation.dart';
import 'package:pos_mobile/database/app_database.dart';
import 'package:pos_mobile/database/connection/open_database.dart';

/// Holds the app database for the process lifetime.
class DatabaseService {
  DatabaseService._(this._database, {this.businessId});

  final AppDatabase _database;

  /// Set when opening [openForBusiness]; null for bootstrap (pre-provision).
  final String? businessId;

  AppDatabase get database => _database;

  /// In-memory service for widget/unit tests (no file I/O).
  @visibleForTesting
  factory DatabaseService.inMemory({AppDatabase? database}) {
    return DatabaseService._(database ?? openMemoryDatabase());
  }

  /// Opens the bootstrap SQLite file (schema only; no auto-provision).
  static Future<DatabaseService> open({
    String? storageDirectoryOverride,
  }) async {
    final db = await openLocalBootstrapDatabase(
      storageDirectoryOverride: storageDirectoryOverride,
    );
    return DatabaseService._(db);
  }

  /// Opens the per-business database file after provisioning (Phase 4+).
  static Future<DatabaseService> openForBusiness({
    required String businessId,
    String? storageDirectoryOverride,
  }) async {
    final db = await openBusinessDatabase(
      businessId: businessId,
      storageDirectoryOverride: storageDirectoryOverride,
    );
    return DatabaseService._(db, businessId: businessId);
  }

  Future<void> dispose() async {
    await _database.close();
  }
}
