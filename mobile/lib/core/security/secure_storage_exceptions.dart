/// Base type for secure-storage failures. Messages must never include secret values.
sealed class SecureStorageException implements Exception {
  const SecureStorageException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Platform is not supported for secure storage (no plaintext fallback).
final class SecureStorageUnsupportedPlatformException
    extends SecureStorageException {
  SecureStorageUnsupportedPlatformException(String platformName)
    : super('Secure storage is not supported on $platformName.');
}

/// Secure storage backend is unavailable for the requested operation.
final class SecureStorageUnavailableException extends SecureStorageException {
  SecureStorageUnavailableException({required this.operation})
    : super('Secure storage is unavailable for $operation.');

  final String operation;
}

/// A read/write/delete failed while storage was present.
final class SecureStorageAccessException extends SecureStorageException {
  SecureStorageAccessException({required this.operation, this.reason})
    : super(
        reason == null
            ? 'Secure storage access failed during $operation.'
            : 'Secure storage access failed during $operation ($reason).',
      );

  final String operation;
  final String? reason;
}

/// Caller supplied an invalid key or value.
final class SecureStorageValidationException extends SecureStorageException {
  SecureStorageValidationException(this.field)
    : super('Secure storage validation failed for $field.');

  final String field;
}
