import 'package:pos_mobile/core/security/secure_storage_exceptions.dart';
import 'package:pos_mobile/core/security/secure_storage_keys.dart';

void validateSecureStorageKey(String key) {
  if (key.isEmpty) {
    throw SecureStorageValidationException('key');
  }
  if (!SecureStorageKeys.isApplicationOwned(key)) {
    throw SecureStorageValidationException('key_namespace');
  }
}

void validateSecureStorageValue(String value) {
  if (value.isEmpty) {
    throw SecureStorageValidationException('value');
  }
}
