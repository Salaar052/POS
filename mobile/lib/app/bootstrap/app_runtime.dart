import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_mobile/app/providers/database_providers.dart';
import 'package:pos_mobile/data/services/database_service.dart';

/// Process-level ownership of [DatabaseService] and [ProviderContainer].
class AppRuntime {
  AppRuntime._();

  static DatabaseService? _databaseService;
  static ProviderContainer? _container;

  static ProviderContainer? get container => _container;

  static Future<ProviderContainer> start({
    String? storageDirectoryOverride,
  }) async {
    await shutdown();
    final service = await DatabaseService.open(
      storageDirectoryOverride: storageDirectoryOverride,
    );
    final container = ProviderContainer(
      overrides: [
        databaseServiceProvider.overrideWithValue(service),
      ],
    );
    _databaseService = service;
    _container = container;
    return container;
  }

  static Future<void> shutdown() async {
    _container?.dispose();
    _container = null;
    await _databaseService?.dispose();
    _databaseService = null;
  }
}
