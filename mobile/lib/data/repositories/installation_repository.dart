import 'package:drift/drift.dart';
import 'package:pos_mobile/core/ids/uuid_generator.dart';
import 'package:pos_mobile/database/app_database.dart';
import 'package:pos_mobile/database/connection/local_db_paths.dart';
import 'package:pos_mobile/database/enums/provisioning_status.dart';
import 'package:pos_mobile/data/repositories/database_runner.dart';

class InstallationRepository {
  InstallationRepository(this._runner, {UuidGenerator? uuid})
    : _uuid = uuid ?? UuidGenerator();

  final DatabaseRunner _runner;
  final UuidGenerator _uuid;

  static const profileSingletonId = 1;

  Future<InstallationProfileRow> ensureProfile() async {
    final existing = await getProfile();
    if (existing != null) {
      return existing;
    }
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    await _runner.database
        .into(_runner.database.installationProfile)
        .insert(
          InstallationProfileCompanion.insert(
            singletonId: Value(profileSingletonId),
            appInstallId: _uuid.v4(),
            createdAtMs: now,
            updatedAtMs: now,
          ),
        );
    final created = await getProfile();
    if (created == null) {
      throw InstallationStateException('Failed to create installation profile');
    }
    return created;
  }

  Future<InstallationProfileRow?> getProfile() {
    return (_runner.database.select(_runner.database.installationProfile)
          ..where((t) => t.singletonId.equals(profileSingletonId)))
        .getSingleOrNull();
  }

  Future<void> setActiveBusinessId(String? businessId) async {
    await ensureProfile();
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    await (_runner.database.update(
      _runner.database.installationProfile,
    )..where((t) => t.singletonId.equals(profileSingletonId))).write(
      InstallationProfileCompanion(
        activeBusinessId: Value(businessId),
        updatedAtMs: Value(now),
      ),
    );
  }

  Future<List<KnownBusinessRow>> listKnownBusinesses() {
    return (_runner.database.select(
      _runner.database.knownBusinesses,
    )..orderBy([(t) => OrderingTerm.asc(t.displayName)])).get();
  }

  Future<KnownBusinessRow?> getKnownBusiness(String businessId) {
    return (_runner.database.select(
      _runner.database.knownBusinesses,
    )..where((t) => t.businessId.equals(businessId))).getSingleOrNull();
  }

  Future<void> registerProvisioningBusiness({
    required String businessId,
    required String displayName,
  }) async {
    final existing = await getKnownBusiness(businessId);
    if (existing != null &&
        existing.provisioningStatus == ProvisioningStatus.ready) {
      throw InstallationStateException(
        'Business $businessId is already provisioned on this device',
      );
    }
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    final fileName = businessDatabaseFileName(businessId);
    await _runner.database
        .into(_runner.database.knownBusinesses)
        .insertOnConflictUpdate(
          KnownBusinessesCompanion.insert(
            businessId: businessId,
            displayName: displayName,
            databaseFileName: fileName,
            provisioningStatus: ProvisioningStatus.provisioning,
            createdAtMs: existing?.createdAtMs ?? now,
            lastOpenedAtMs: Value(existing?.lastOpenedAtMs),
          ),
        );
  }

  Future<void> markBusinessReady(String businessId) async {
    final updated =
        await (_runner.database.update(
          _runner.database.knownBusinesses,
        )..where((t) => t.businessId.equals(businessId))).write(
          const KnownBusinessesCompanion(
            provisioningStatus: Value(ProvisioningStatus.ready),
          ),
        );
    if (updated == 0) {
      throw InstallationStateException(
        'Unknown business $businessId in registry',
      );
    }
  }

  Future<void> touchLastOpened(String businessId) async {
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    await (_runner.database.update(_runner.database.knownBusinesses)
          ..where((t) => t.businessId.equals(businessId)))
        .write(KnownBusinessesCompanion(lastOpenedAtMs: Value(now)));
  }
}

class InstallationStateException implements Exception {
  InstallationStateException(this.message);

  final String message;

  @override
  String toString() => message;
}
