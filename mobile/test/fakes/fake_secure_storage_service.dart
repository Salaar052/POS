import 'package:pos_mobile/core/security/secure_storage_exceptions.dart';
import 'package:pos_mobile/core/security/secure_storage_keys.dart';
import 'package:pos_mobile/core/security/secure_storage_service.dart';
import 'package:pos_mobile/core/security/secure_storage_validation.dart';

/// In-memory secure storage for unit tests (not for production).
final class FakeSecureStorageService implements SecureStorageService {
  FakeSecureStorageService();

  final Map<String, String> _values = {};
  bool simulateFailure = false;

  /// Test-only view of stored entries (never log in production).
  Map<String, String> snapshot() => Map.unmodifiable(_values);

  void _throwIfSimulatedFailure(String operation) {
    if (simulateFailure) {
      throw SecureStorageUnavailableException(operation: operation);
    }
  }

  @override
  Future<void> write({required String key, required String value}) async {
    validateSecureStorageKey(key);
    validateSecureStorageValue(value);
    _throwIfSimulatedFailure('write');
    _values[key] = value;
  }

  @override
  Future<String?> read({required String key}) async {
    validateSecureStorageKey(key);
    _throwIfSimulatedFailure('read');
    return _values[key];
  }

  @override
  Future<void> delete({required String key}) async {
    validateSecureStorageKey(key);
    _throwIfSimulatedFailure('delete');
    _values.remove(key);
  }

  @override
  Future<void> deleteAll() async {
    _throwIfSimulatedFailure('deleteAll');
    for (final key in SecureStorageKeys.applicationOwnedKeys) {
      _values.remove(key);
    }
  }
}
