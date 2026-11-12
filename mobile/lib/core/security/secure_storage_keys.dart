/// Reserved secure-storage key names owned by Pak POS.
///
/// Keys use the `pakpos.` namespace so they cannot collide with unrelated
/// credentials and so [deleteAll] can target application-owned entries only.
///
/// Phase 4.2 does not write any of these values; later phases own persistence.
abstract final class SecureStorageKeys {
  static const String namespacePrefix = 'pakpos.';

  /// Installation-level credential material (future auth bootstrap).
  static const String installationCredential = 'pakpos.installation.credential';

  /// Refresh token for session renewal (future online auth).
  static const String refreshToken = 'pakpos.auth.refresh_token';

  /// Offline password verifier material (future offline unlock).
  static const String offlineVerifier = 'pakpos.auth.offline_verifier';

  /// Per-device credential for activation (future device trust).
  static const String deviceCredential = 'pakpos.device.credential';

  /// Remote registration succeeded but local SQLite provisioning must be retried.
  static const String provisioningRecovery =
      'pakpos.onboarding.provisioning_recovery';

  /// Owner account exists remotely but verification/login is not implemented yet.
  static const String ownerPendingVerification =
      'pakpos.onboarding.owner_pending';

  /// Keys cleared by [SecureStorageService.deleteAll] for this application.
  static const List<String> applicationOwnedKeys = [
    installationCredential,
    refreshToken,
    offlineVerifier,
    deviceCredential,
    provisioningRecovery,
    ownerPendingVerification,
  ];

  static bool isApplicationOwned(String key) {
    return key.startsWith(namespacePrefix);
  }
}
