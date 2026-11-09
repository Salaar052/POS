import 'dart:io';

import 'package:pos_mobile/data/repositories/database_runner.dart';
import 'package:pos_mobile/data/repositories/installation_repository.dart';
import 'package:pos_mobile/data/repositories/local_business_repository.dart';
import 'package:pos_mobile/data/services/database_service.dart';
import 'package:pos_mobile/database/app_database.dart';
import 'package:pos_mobile/database/connection/local_db_paths.dart';
import 'package:pos_mobile/database/connection/open_database.dart';
import 'package:pos_mobile/database/enums/provisioning_status.dart';

/// Explicit business-database provisioning and opening (bootstrap registry only).
///
/// Cross-file operations are **not** one SQLite transaction: registry status
/// (`PROVISIONING` → `READY`) is the recovery state machine.
class BusinessDatabaseCoordinator {
  BusinessDatabaseCoordinator(this._storageDirectoryOverride);

  final String? _storageDirectoryOverride;

  static final _uuidPattern = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
  );

  Future<DatabaseService> provisionBusinessDatabase({
    DatabaseService? registryBootstrap,
    required String businessId,
    required String displayName,
    String? legalName,
    String? phone,
    String? address,
    String timezoneId = 'Asia/Karachi',
    String currencyCode = 'PKR',
    Map<String, Object?> settings = const {},
  }) async {
    _validateBusinessId(businessId);
    if (displayName.trim().isEmpty) {
      throw BusinessDatabaseException('Display name is required');
    }

    final bootstrap = await _bootstrapRegistry(registryBootstrap);
    final ownsBootstrap = registryBootstrap == null;
    try {
      final installRepo = InstallationRepository(
        DatabaseRunner(bootstrap.database),
      );
      await installRepo.ensureProfile();

      final existing = await installRepo.getKnownBusiness(businessId);
      if (existing != null &&
          existing.provisioningStatus == ProvisioningStatus.ready) {
        throw BusinessDatabaseException(
          'Business $businessId is already registered as READY',
        );
      }

      final file = File(await _businessFilePath(businessId));
      if (file.existsSync()) {
        final recovered = await _tryRecoverExistingBusinessFile(
          installRepo: installRepo,
          businessId: businessId,
          displayName: displayName,
        );
        if (recovered != null) {
          return recovered;
        }
        throw BusinessDatabaseException(
          'Business database file exists but is incomplete or belongs to another business. '
          'Manual recovery is required; the file was not modified.',
        );
      }

      await installRepo.registerProvisioningBusiness(
        businessId: businessId,
        displayName: displayName,
      );
    } finally {
      if (ownsBootstrap) {
        await bootstrap.dispose();
      }
    }

    DatabaseService? businessService;
    try {
      businessService = await DatabaseService.openForBusiness(
        businessId: businessId,
        storageDirectoryOverride: _storageDirectoryOverride,
      );
      await LocalBusinessRepository(DatabaseRunner(businessService.database))
          .provisionBusiness(
            businessId: businessId,
            name: displayName,
            legalName: legalName,
            phone: phone,
            address: address,
            timezoneId: timezoneId,
            currencyCode: currencyCode,
            settings: settings,
          );

      await _verifyBusinessIdentity(
        service: businessService,
        businessId: businessId,
      );
    } catch (error) {
      await businessService?.dispose();
      rethrow;
    }

    await _finalizeRegistry(
      registryBootstrap: registryBootstrap,
      businessId: businessId,
    );

    return businessService;
  }

  Future<DatabaseService> openReadyBusiness({
    DatabaseService? registryBootstrap,
    required String businessId,
  }) async {
    _validateBusinessId(businessId);

    final bootstrap = await _bootstrapRegistry(registryBootstrap);
    final ownsBootstrap = registryBootstrap == null;
    DatabaseService? recovered;
    try {
      final installRepo = InstallationRepository(
        DatabaseRunner(bootstrap.database),
      );
      final known = await installRepo.getKnownBusiness(businessId);
      if (known == null) {
        throw BusinessDatabaseException(
          'Business $businessId is not in the registry',
        );
      }
      if (known.provisioningStatus != ProvisioningStatus.ready) {
        if (known.provisioningStatus == ProvisioningStatus.provisioning) {
          recovered = await _tryRecoverExistingBusinessFile(
            installRepo: installRepo,
            businessId: businessId,
            displayName: known.displayName,
          );
          if (recovered == null) {
            throw BusinessDatabaseException(
              'Business $businessId is still PROVISIONING and the database file '
              'is not valid yet',
            );
          }
        } else {
          throw BusinessDatabaseException('Business $businessId is not READY');
        }
      }
    } finally {
      if (ownsBootstrap) {
        await bootstrap.dispose();
      }
    }

    if (recovered != null) {
      return recovered;
    }

    final filePath = await _businessFilePath(businessId);
    if (!File(filePath).existsSync()) {
      throw BusinessDatabaseException(
        'Business database file is missing for $businessId',
      );
    }

    final service = await DatabaseService.openForBusiness(
      businessId: businessId,
      storageDirectoryOverride: _storageDirectoryOverride,
    );
    await _verifyBusinessIdentity(service: service, businessId: businessId);

    await _touchOpened(
      registryBootstrap: registryBootstrap,
      businessId: businessId,
    );

    return service;
  }

  Future<DatabaseService> openBootstrap() {
    return DatabaseService.open(
      storageDirectoryOverride: _storageDirectoryOverride,
    );
  }

  Future<InstallationProfileRow?> readInstallationProfile() async {
    final bootstrap = await _openBootstrapSession();
    try {
      return await InstallationRepository(DatabaseRunner(bootstrap.database))
          .getProfile();
    } finally {
      await bootstrap.dispose();
    }
  }

  Future<List<KnownBusinessRow>> listKnownBusinesses() async {
    final bootstrap = await _openBootstrapSession();
    try {
      return await InstallationRepository(DatabaseRunner(bootstrap.database))
          .listKnownBusinesses();
    } finally {
      await bootstrap.dispose();
    }
  }

  Future<DatabaseService?> _tryRecoverExistingBusinessFile({
    required InstallationRepository installRepo,
    required String businessId,
    required String displayName,
  }) async {
    final filePath = await _businessFilePath(businessId);
    if (!File(filePath).existsSync()) {
      return null;
    }

    final service = await DatabaseService.openForBusiness(
      businessId: businessId,
      storageDirectoryOverride: _storageDirectoryOverride,
    );
    try {
      await _verifyBusinessIdentity(service: service, businessId: businessId);
    } catch (_) {
      await service.dispose();
      return null;
    }

    final known = await installRepo.getKnownBusiness(businessId);
    if (known?.provisioningStatus != ProvisioningStatus.ready) {
      await installRepo.registerProvisioningBusiness(
        businessId: businessId,
        displayName: displayName,
      );
      await installRepo.markBusinessReady(businessId);
    }
    await installRepo.setActiveBusinessId(businessId);
    await installRepo.touchLastOpened(businessId);
    return service;
  }

  Future<void> _verifyBusinessIdentity({
    required DatabaseService service,
    required String businessId,
  }) async {
    final row = await LocalBusinessRepository(DatabaseRunner(service.database))
        .getBusiness();
    if (row == null) {
      throw BusinessDatabaseException(
        'Business database has no local_business row',
      );
    }
    if (row.businessId != businessId) {
      throw BusinessDatabaseException(
        'Business identity mismatch: expected $businessId, found ${row.businessId}',
      );
    }
  }

  Future<DatabaseService> _openBootstrapSession() {
    return DatabaseService.open(
      storageDirectoryOverride: _storageDirectoryOverride,
    );
  }

  Future<DatabaseService> _bootstrapRegistry(
    DatabaseService? registryBootstrap,
  ) async {
    if (registryBootstrap != null) {
      if (!registryBootstrap.isBootstrap) {
        throw BusinessDatabaseException(
          'registryBootstrap must reference local.sqlite',
        );
      }
      return registryBootstrap;
    }
    return _openBootstrapSession();
  }

  Future<void> _finalizeRegistry({
    DatabaseService? registryBootstrap,
    required String businessId,
  }) async {
    final bootstrap = await _bootstrapRegistry(registryBootstrap);
    final ownsBootstrap = registryBootstrap == null;
    try {
      final installRepo = InstallationRepository(
        DatabaseRunner(bootstrap.database),
      );
      await installRepo.markBusinessReady(businessId);
      await installRepo.setActiveBusinessId(businessId);
      await installRepo.touchLastOpened(businessId);
    } finally {
      if (ownsBootstrap) {
        await bootstrap.dispose();
      }
    }
  }

  Future<void> _touchOpened({
    DatabaseService? registryBootstrap,
    required String businessId,
  }) async {
    final bootstrap = await _bootstrapRegistry(registryBootstrap);
    final ownsBootstrap = registryBootstrap == null;
    try {
      final installRepo = InstallationRepository(
        DatabaseRunner(bootstrap.database),
      );
      await installRepo.setActiveBusinessId(businessId);
      await installRepo.touchLastOpened(businessId);
    } finally {
      if (ownsBootstrap) {
        await bootstrap.dispose();
      }
    }
  }

  Future<String> _businessFilePath(String businessId) async {
    final dir = await resolvePakposDirectory(
      overrideDirectory: _storageDirectoryOverride,
    );
    return '$dir/${businessDatabaseFileName(businessId)}';
  }

  void _validateBusinessId(String businessId) {
    if (!_uuidPattern.hasMatch(businessId)) {
      throw BusinessDatabaseException('businessId must be a UUID');
    }
  }
}

class BusinessDatabaseException implements Exception {
  BusinessDatabaseException(this.message);

  final String message;

  @override
  String toString() => message;
}
