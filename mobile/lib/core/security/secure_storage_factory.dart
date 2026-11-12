import 'package:pos_mobile/core/security/secure_storage_service.dart';

import 'secure_storage_factory_stub.dart'
    if (dart.library.io) 'secure_storage_factory_io.dart';

/// Resolves the platform [SecureStorageService] for production.
SecureStorageService createPlatformSecureStorage() =>
    createPlatformSecureStorageImpl();
