import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_mobile/core/security/secure_storage_factory.dart';
import 'package:pos_mobile/core/security/secure_storage_service.dart';

/// Resolves secure storage without requiring a business database.
final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return createPlatformSecureStorage();
});
