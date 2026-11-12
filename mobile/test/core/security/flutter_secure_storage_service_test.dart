import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/test/test_flutter_secure_storage_platform.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_mobile/core/security/flutter_secure_storage_service.dart';
import 'package:pos_mobile/core/security/secure_storage_exceptions.dart';
import 'package:pos_mobile/core/security/secure_storage_keys.dart';

const _testKey = 'pakpos.test.plugin';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Map<String, String> data;
  late FlutterSecureStorageService service;

  setUp(() {
    data = {};
    FlutterSecureStoragePlatform.instance = TestFlutterSecureStoragePlatform(
      data,
    );
    service = FlutterSecureStorageService();
  });

  test(
    'production configuration exposes documented Android and Windows options',
    () {
      expect(
        FlutterSecureStorageService.androidOptions.preferencesKeyPrefix,
        'pakpos',
      );
      expect(
        FlutterSecureStorageService.androidOptions.storageNamespace,
        'com.pakpos.pos.secure',
      );
      expect(
        FlutterSecureStorageService.windowsOptions
            .toMap()['useBackwardCompatibility'],
        'false',
      );
    },
  );

  test('write and read via plugin test platform', () async {
    await service.write(key: _testKey, value: 'secret-value');
    expect(await service.read(key: _testKey), 'secret-value');
  });

  test('deleteAll removes registered keys only', () async {
    await service.write(
      key: SecureStorageKeys.deviceCredential,
      value: 'device',
    );
    await service.write(key: _testKey, value: 'leftover');
    await service.deleteAll();
    expect(await service.read(key: SecureStorageKeys.deviceCredential), isNull);
    expect(await service.read(key: _testKey), 'leftover');
  });

  test('maps platform failure to SecureStorageAccessException', () async {
    FlutterSecureStoragePlatform.instance = _FailingWritePlatform();
    addTearDown(
      () => FlutterSecureStoragePlatform.instance =
          TestFlutterSecureStoragePlatform(data),
    );

    await expectLater(
      service.write(key: _testKey, value: 'x'),
      throwsA(
        isA<SecureStorageAccessException>().having(
          (e) => e.reason,
          'reason',
          'write_failed',
        ),
      ),
    );
  });
}

final class _FailingWritePlatform extends FlutterSecureStoragePlatform {
  @override
  Future<bool> containsKey({
    required String key,
    required Map<String, String> options,
  }) async => false;

  @override
  Future<void> delete({
    required String key,
    required Map<String, String> options,
  }) async {}

  @override
  Future<void> deleteAll({required Map<String, String> options}) async {}

  @override
  Future<String?> read({
    required String key,
    required Map<String, String> options,
  }) async => null;

  @override
  Future<Map<String, String>> readAll({
    required Map<String, String> options,
  }) async => {};

  @override
  Future<void> write({
    required String key,
    required String value,
    required Map<String, String> options,
  }) async {
    throw PlatformException(code: 'write_failed');
  }
}
