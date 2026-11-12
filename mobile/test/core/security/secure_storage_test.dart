import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_mobile/app/providers/secure_storage_provider.dart';
import 'package:pos_mobile/core/security/secure_storage_exceptions.dart';
import 'package:pos_mobile/core/security/secure_storage_keys.dart';

import '../../fakes/fake_secure_storage_service.dart';

/// Test-only key under the application namespace (not in the production registry).
const _testKey = 'pakpos.test.fixture';

void main() {
  group('FakeSecureStorageService', () {
    late FakeSecureStorageService storage;

    setUp(() {
      storage = FakeSecureStorageService();
    });

    test('write then read returns stored value', () async {
      await storage.write(key: _testKey, value: 'alpha');
      expect(await storage.read(key: _testKey), 'alpha');
    });

    test('updating an existing key overwrites value', () async {
      await storage.write(key: _testKey, value: 'first');
      await storage.write(key: _testKey, value: 'second');
      expect(await storage.read(key: _testKey), 'second');
    });

    test('reading a missing key returns null', () async {
      expect(await storage.read(key: _testKey), isNull);
    });

    test('delete removes a key', () async {
      await storage.write(key: _testKey, value: 'x');
      await storage.delete(key: _testKey);
      expect(await storage.read(key: _testKey), isNull);
    });

    test('deleteAll clears registered application keys only', () async {
      await storage.write(key: SecureStorageKeys.refreshToken, value: 'token');
      await storage.write(key: _testKey, value: 'fixture');
      await storage.deleteAll();
      expect(await storage.read(key: SecureStorageKeys.refreshToken), isNull);
      expect(await storage.read(key: _testKey), 'fixture');
    });

    test('repeated delete on missing key is idempotent', () async {
      await storage.delete(key: _testKey);
      await storage.delete(key: _testKey);
      expect(await storage.read(key: _testKey), isNull);
    });

    test('empty key validation', () async {
      expect(
        () => storage.write(key: '', value: 'v'),
        throwsA(isA<SecureStorageValidationException>()),
      );
    });

    test('empty value validation', () async {
      expect(
        () => storage.write(key: _testKey, value: ''),
        throwsA(isA<SecureStorageValidationException>()),
      );
    });

    test('rejects keys outside the pakpos namespace', () async {
      expect(
        () => storage.write(key: 'other.app.secret', value: 'v'),
        throwsA(isA<SecureStorageValidationException>()),
      );
    });

    test('storage failure propagation', () async {
      storage.simulateFailure = true;
      await expectLater(
        storage.write(key: _testKey, value: 'x'),
        throwsA(isA<SecureStorageUnavailableException>()),
      );
    });

    test('snapshot exposes values for assertions', () async {
      await storage.write(key: _testKey, value: 'inspect');
      expect(storage.snapshot()[_testKey], 'inspect');
    });
  });

  group('secureStorageServiceProvider', () {
    test('override with fake resolves without database', () {
      final fake = FakeSecureStorageService();
      final container = ProviderContainer(
        overrides: [secureStorageServiceProvider.overrideWithValue(fake)],
      );
      addTearDown(container.dispose);
      expect(container.read(secureStorageServiceProvider), same(fake));
    });
  });
}
