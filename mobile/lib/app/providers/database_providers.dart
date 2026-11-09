import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_mobile/data/repositories/database_runner.dart';
import 'package:pos_mobile/data/repositories/local_business_repository.dart';
import 'package:pos_mobile/data/services/database_service.dart';
import 'package:pos_mobile/database/app_database.dart';

/// Long-lived database service; must be overridden in [main] before [runApp].
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  throw StateError(
    'databaseServiceProvider is not initialized. '
    'Override it with the opened DatabaseService in main().',
  );
});

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  return ref.watch(databaseServiceProvider).database;
});

final databaseRunnerProvider = Provider<DatabaseRunner>((ref) {
  return DatabaseRunner(ref.watch(appDatabaseProvider));
});

final localBusinessRepositoryProvider = Provider<LocalBusinessRepository>((ref) {
  return LocalBusinessRepository(ref.watch(databaseRunnerProvider));
});
