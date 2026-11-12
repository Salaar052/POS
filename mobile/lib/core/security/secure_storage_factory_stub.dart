import 'package:pos_mobile/core/security/secure_storage_exceptions.dart';
import 'package:pos_mobile/core/security/secure_storage_service.dart';

SecureStorageService createPlatformSecureStorageImpl() {
  throw SecureStorageUnsupportedPlatformException('web');
}
