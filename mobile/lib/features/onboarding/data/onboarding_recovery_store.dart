import 'dart:convert';

import 'package:pos_mobile/core/security/secure_storage_exceptions.dart';
import 'package:pos_mobile/core/security/secure_storage_keys.dart';
import 'package:pos_mobile/core/security/secure_storage_service.dart';
import 'package:pos_mobile/features/onboarding/data/onboarding_storage_outcomes.dart';
import 'package:pos_mobile/features/onboarding/domain/onboarding_snapshot_validation.dart';

class ProvisioningRecoverySnapshot {
  const ProvisioningRecoverySnapshot({
    required this.businessId,
    required this.displayName,
    required this.ownerName,
    required this.ownerEmail,
    this.businessPhone,
    this.businessEmail,
  });

  final String businessId;
  final String displayName;
  final String ownerName;
  final String ownerEmail;
  final String? businessPhone;
  final String? businessEmail;

  Map<String, dynamic> toJson() => {
    'businessId': businessId,
    'displayName': displayName,
    'ownerName': ownerName,
    'ownerEmail': ownerEmail,
    if (businessPhone != null) 'businessPhone': businessPhone,
    if (businessEmail != null) 'businessEmail': businessEmail,
  };

  factory ProvisioningRecoverySnapshot.fromValidatedJson(
    Map<String, dynamic> json,
  ) {
    final businessId = json['businessId'];
    final displayName = json['displayName'];
    final ownerEmail = json['ownerEmail'];
    final ownerName = json['ownerName'];
    if (businessId is! String ||
        displayName is! String ||
        ownerEmail is! String) {
      throw const FormatException('invalid field types');
    }
    final resolvedOwnerName = ownerName is String ? ownerName : ownerEmail;
    return ProvisioningRecoverySnapshot(
      businessId: businessId,
      displayName: displayName,
      ownerName: resolvedOwnerName,
      ownerEmail: ownerEmail,
      businessPhone: json['businessPhone'] as String?,
      businessEmail: json['businessEmail'] as String?,
    );
  }
}

class OwnerPendingSnapshot {
  const OwnerPendingSnapshot({
    required this.businessId,
    required this.businessName,
    required this.ownerEmail,
    required this.ownerName,
  });

  final String businessId;
  final String businessName;
  final String ownerEmail;
  final String ownerName;

  Map<String, dynamic> toJson() => {
    'businessId': businessId,
    'businessName': businessName,
    'ownerEmail': ownerEmail,
    'ownerName': ownerName,
  };

  factory OwnerPendingSnapshot.fromValidatedJson(Map<String, dynamic> json) {
    final businessId = json['businessId'];
    final businessName = json['businessName'];
    final ownerEmail = json['ownerEmail'];
    final ownerName = json['ownerName'];
    if (businessId is! String ||
        businessName is! String ||
        ownerEmail is! String ||
        ownerName is! String) {
      throw const FormatException('invalid field types');
    }
    return OwnerPendingSnapshot(
      businessId: businessId,
      businessName: businessName,
      ownerEmail: ownerEmail,
      ownerName: ownerName,
    );
  }
}

/// Persists safe onboarding recovery metadata (never passwords).
class OnboardingRecoveryStore {
  OnboardingRecoveryStore(this._secureStorage);

  final SecureStorageService _secureStorage;

  Future<void> saveProvisioningRecovery(ProvisioningRecoverySnapshot snapshot) {
    return _wrapStorage(
      'write',
      () => _secureStorage.write(
        key: SecureStorageKeys.provisioningRecovery,
        value: jsonEncode(snapshot.toJson()),
      ),
    );
  }

  Future<OnboardingSnapshotRead<ProvisioningRecoverySnapshot>>
  readProvisioningRecovery() {
    return _readSnapshot(
      key: SecureStorageKeys.provisioningRecovery,
      parse: (json) => ProvisioningRecoverySnapshot.fromValidatedJson(json),
      validate: _validateProvisioningSnapshot,
    );
  }

  Future<void> clearProvisioningRecovery() {
    return _wrapStorage(
      'delete',
      () => _secureStorage.delete(key: SecureStorageKeys.provisioningRecovery),
    );
  }

  Future<void> saveOwnerPending(OwnerPendingSnapshot snapshot) {
    return _wrapStorage(
      'write',
      () => _secureStorage.write(
        key: SecureStorageKeys.ownerPendingVerification,
        value: jsonEncode(snapshot.toJson()),
      ),
    );
  }

  Future<OnboardingSnapshotRead<OwnerPendingSnapshot>> readOwnerPending() {
    return _readSnapshot(
      key: SecureStorageKeys.ownerPendingVerification,
      parse: (json) => OwnerPendingSnapshot.fromValidatedJson(json),
      validate: _validateOwnerPendingSnapshot,
    );
  }

  Future<void> clearOwnerPending() {
    return _wrapStorage(
      'delete',
      () => _secureStorage.delete(
        key: SecureStorageKeys.ownerPendingVerification,
      ),
    );
  }

  Future<OnboardingSnapshotRead<T>> _readSnapshot<T>({
    required String key,
    required T Function(Map<String, dynamic> json) parse,
    required InvalidSnapshotReason? Function(T value) validate,
  }) async {
    String? raw;
    try {
      raw = await _secureStorage.read(key: key);
    } on SecureStorageUnavailableException catch (error) {
      throw OnboardingSecureStorageException(
        'Secure storage is unavailable. The app cannot verify onboarding state.',
        operation: error.operation,
      );
    }

    if (raw == null || raw.isEmpty) {
      return OnboardingSnapshotAbsent<T>();
    }

    Map<String, dynamic> json;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return OnboardingSnapshotInvalid<T>(InvalidSnapshotReason.corruptJson);
      }
      json = decoded;
    } catch (_) {
      return OnboardingSnapshotInvalid<T>(InvalidSnapshotReason.corruptJson);
    }

    final T value;
    try {
      value = parse(json);
    } catch (_) {
      return OnboardingSnapshotInvalid<T>(
        InvalidSnapshotReason.invalidFieldTypes,
      );
    }

    final fieldReason = validate(value);
    if (fieldReason != null) {
      return OnboardingSnapshotInvalid<T>(fieldReason);
    }

    return OnboardingSnapshotPresent<T>(value);
  }

  InvalidSnapshotReason? _validateProvisioningSnapshot(
    ProvisioningRecoverySnapshot value,
  ) {
    if (!OnboardingSnapshotValidation.isUuid(value.businessId)) {
      return InvalidSnapshotReason.invalidBusinessId;
    }
    if (!OnboardingSnapshotValidation.isReasonableEmail(value.ownerEmail)) {
      return InvalidSnapshotReason.invalidOwnerEmail;
    }
    if (value.displayName.trim().isEmpty || value.ownerName.trim().isEmpty) {
      return InvalidSnapshotReason.invalidFieldTypes;
    }
    return null;
  }

  InvalidSnapshotReason? _validateOwnerPendingSnapshot(
    OwnerPendingSnapshot value,
  ) {
    if (!OnboardingSnapshotValidation.isUuid(value.businessId)) {
      return InvalidSnapshotReason.invalidBusinessId;
    }
    if (!OnboardingSnapshotValidation.isReasonableEmail(value.ownerEmail)) {
      return InvalidSnapshotReason.invalidOwnerEmail;
    }
    if (value.businessName.trim().isEmpty || value.ownerName.trim().isEmpty) {
      return InvalidSnapshotReason.invalidFieldTypes;
    }
    return null;
  }

  Future<void> _wrapStorage(String operation, Future<void> Function() run) {
    return run().catchError((Object error) {
      if (error is SecureStorageUnavailableException) {
        throw OnboardingSecureStorageException(
          'Secure storage is unavailable ($operation).',
          operation: error.operation,
        );
      }
      throw error;
    });
  }
}
