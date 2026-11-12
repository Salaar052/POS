import 'package:flutter/foundation.dart';
import 'package:pos_mobile/core/security/flutter_secure_storage_service.dart';
import 'package:pos_mobile/core/security/secure_storage_exceptions.dart';
import 'package:pos_mobile/core/security/secure_storage_service.dart';

SecureStorageService createPlatformSecureStorageImpl() {
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
    case TargetPlatform.windows:
      return FlutterSecureStorageService();
    case TargetPlatform.linux:
    case TargetPlatform.macOS:
    case TargetPlatform.iOS:
    case TargetPlatform.fuchsia:
      throw SecureStorageUnsupportedPlatformException(
        defaultTargetPlatform.name,
      );
  }
}
