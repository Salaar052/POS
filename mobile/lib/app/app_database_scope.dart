import 'package:pos_mobile/data/services/database_service.dart';

/// Process-wide holder for the opened [DatabaseService] (Phase 2.1).
class AppDatabaseScope {
  AppDatabaseScope._();

  /// Set during [main] after successful [DatabaseService.open].
  static DatabaseService? service;

  static Future<void> dispose() async {
    await service?.dispose();
    service = null;
  }
}
