import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_mobile/core/security/flutter_secure_storage_service.dart';
import 'package:pos_mobile/core/security/secure_storage_exceptions.dart';
import 'package:pos_mobile/core/security/secure_storage_factory.dart';

void main() {
  test('createPlatformSecureStorage supports current test platform', () {
    final service = createPlatformSecureStorage();
    expect(service, isA<FlutterSecureStorageService>());
  });

  test('createPlatformSecureStorage rejects unsupported desktop targets', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);

    expect(
      createPlatformSecureStorage,
      throwsA(isA<SecureStorageUnsupportedPlatformException>()),
    );
  });
}
