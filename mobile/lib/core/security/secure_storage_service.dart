/// Platform-independent API for sensitive credential storage.
abstract interface class SecureStorageService {
  Future<void> write({required String key, required String value});

  Future<String?> read({required String key});

  Future<void> delete({required String key});

  /// Removes registered application-owned keys only (see [SecureStorageKeys]).
  Future<void> deleteAll();
}
