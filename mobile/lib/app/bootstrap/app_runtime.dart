import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_mobile/app/providers/database_providers.dart';
import 'package:pos_mobile/data/repositories/database_runner.dart';
import 'package:pos_mobile/data/repositories/installation_repository.dart';
import 'package:pos_mobile/data/services/business_database_coordinator.dart';
import 'package:pos_mobile/data/services/database_service.dart';

/// Process-level ownership of [DatabaseService] and [ProviderContainer].
class AppRuntime {
  AppRuntime._();

  static DatabaseService? _databaseService;
  static ProviderContainer? _container;
  static String? _storageDirectoryOverride;

  static final ValueNotifier<int> containerRevision = ValueNotifier<int>(0);

  static ProviderContainer? get container => _container;

  static String? get storageDirectoryOverride => _storageDirectoryOverride;

  static BusinessDatabaseCoordinator get coordinator =>
      BusinessDatabaseCoordinator(_storageDirectoryOverride);

  /// Opens the bootstrap database (`local.sqlite`) and binds Riverpod providers.
  static Future<ProviderContainer> start({
    String? storageDirectoryOverride,
  }) async {
    _storageDirectoryOverride = storageDirectoryOverride;
    await shutdown();
    final service = await DatabaseService.open(
      storageDirectoryOverride: storageDirectoryOverride,
    );
    final installRepo = InstallationRepository(
      DatabaseRunner(service.database),
    );
    await installRepo.ensureProfile();
    return _bind(service);
  }

  /// Disposes the active Riverpod container, then closes the active database.
  static Future<void> shutdown() async {
    final container = _container;
    final service = _databaseService;
    _container = null;
    _databaseService = null;
    container?.dispose();
    await service?.dispose();
  }

  /// Rebinds providers to [service]. Disposes the previous container before
  /// closing the previous database service.
  static Future<ProviderContainer> switchDatabase(
    DatabaseService service,
  ) async {
    final previousContainer = _container;
    final previousService = _databaseService;
    _container = null;
    _databaseService = null;
    previousContainer?.dispose();
    await previousService?.dispose();
    return _bind(service);
  }

  /// Switches back to the bootstrap database.
  static Future<ProviderContainer> switchToBootstrap() async {
    final service = await DatabaseService.open(
      storageDirectoryOverride: _storageDirectoryOverride,
    );
    await InstallationRepository(DatabaseRunner(service.database))
        .ensureProfile();
    return switchDatabase(service);
  }

  /// Provisions a separate business file and switches the runtime to it.
  static Future<ProviderContainer> provisionAndSwitchToBusiness({
    required String businessId,
    required String displayName,
    String? legalName,
    String? phone,
    String? address,
  }) async {
    final bootstrap = _databaseService;
    if (bootstrap == null || !bootstrap.isBootstrap) {
      throw StateError(
        'provisionAndSwitchToBusiness requires an active bootstrap database',
      );
    }
    final businessService = await coordinator.provisionBusinessDatabase(
      registryBootstrap: bootstrap,
      businessId: businessId,
      displayName: displayName,
      legalName: legalName,
      phone: phone,
      address: address,
    );
    return switchDatabase(businessService);
  }

  /// Opens a READY registered business and switches the runtime to it.
  static Future<ProviderContainer> openReadyBusinessAndSwitch({
    required String businessId,
  }) async {
    final bootstrap = _databaseService;
    final businessService = await coordinator.openReadyBusiness(
      registryBootstrap: bootstrap?.isBootstrap == true ? bootstrap : null,
      businessId: businessId,
    );
    return switchDatabase(businessService);
  }

  static ProviderContainer _bind(DatabaseService service) {
    final container = ProviderContainer(
      overrides: [databaseServiceProvider.overrideWithValue(service)],
    );
    _databaseService = service;
    _container = container;
    containerRevision.value++;
    return container;
  }
}
