import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pos_mobile/core/security/secure_storage_exceptions.dart';
import 'package:pos_mobile/core/security/secure_storage_keys.dart';
import 'package:pos_mobile/core/security/secure_storage_operation_queue.dart';
import 'package:pos_mobile/core/security/secure_storage_service.dart';
import 'package:pos_mobile/core/security/secure_storage_validation.dart';

/// Production [SecureStorageService] backed by `flutter_secure_storage`.
final class FlutterSecureStorageService implements SecureStorageService {
  FlutterSecureStorageService({FlutterSecureStorage? storage})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(
              preferencesKeyPrefix: 'pakpos',
              storageNamespace: 'com.pakpos.pos.secure',
            ),
            wOptions: WindowsOptions.defaultOptions,
          );

  static const AndroidOptions _documentedAndroidOptions = AndroidOptions(
    preferencesKeyPrefix: 'pakpos',
    storageNamespace: 'com.pakpos.pos.secure',
  );

  static const WindowsOptions _documentedWindowsOptions =
      WindowsOptions.defaultOptions;

  /// Exposed for tests that assert platform configuration.
  static AndroidOptions get androidOptions => _documentedAndroidOptions;

  static WindowsOptions get windowsOptions => _documentedWindowsOptions;

  final FlutterSecureStorage _storage;
  final SecureStorageOperationQueue _queue = SecureStorageOperationQueue();

  @override
  Future<void> write({required String key, required String value}) {
    validateSecureStorageKey(key);
    validateSecureStorageValue(value);
    return _queue.run(() async {
      try {
        await _storage.write(key: key, value: value);
      } on PlatformException catch (e) {
        throw _mapPlatformException(operation: 'write', exception: e);
      } catch (_) {
        throw SecureStorageUnavailableException(operation: 'write');
      }
    });
  }

  @override
  Future<String?> read({required String key}) {
    validateSecureStorageKey(key);
    return _queue.run(() async {
      try {
        return await _storage.read(key: key);
      } on PlatformException catch (e) {
        throw _mapPlatformException(operation: 'read', exception: e);
      } catch (_) {
        throw SecureStorageUnavailableException(operation: 'read');
      }
    });
  }

  @override
  Future<void> delete({required String key}) {
    validateSecureStorageKey(key);
    return _queue.run(() async {
      try {
        await _storage.delete(key: key);
      } on PlatformException catch (e) {
        throw _mapPlatformException(operation: 'delete', exception: e);
      } catch (_) {
        throw SecureStorageUnavailableException(operation: 'delete');
      }
    });
  }

  @override
  Future<void> deleteAll() {
    return _queue.run(() async {
      for (final key in SecureStorageKeys.applicationOwnedKeys) {
        try {
          await _storage.delete(key: key);
        } on PlatformException catch (e) {
          throw _mapPlatformException(operation: 'deleteAll', exception: e);
        } catch (_) {
          throw SecureStorageUnavailableException(operation: 'deleteAll');
        }
      }
    });
  }

  SecureStorageException _mapPlatformException({
    required String operation,
    required PlatformException exception,
  }) {
    final code = exception.code;
    if (code == 'NotSupported' || code == 'UnsupportedOperation') {
      return SecureStorageUnsupportedPlatformException(operation);
    }
    return SecureStorageAccessException(operation: operation, reason: code);
  }
}
