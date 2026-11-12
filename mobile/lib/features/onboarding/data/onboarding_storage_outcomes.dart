/// Why an onboarding snapshot could not be trusted for launch decisions.
enum InvalidSnapshotReason {
  corruptJson,
  invalidFieldTypes,
  invalidBusinessId,
  invalidOwnerEmail,
  missingRegistryBusiness,
  registryStateMismatch,
}

/// Secure storage failed; launch must fail closed.
class OnboardingSecureStorageException implements Exception {
  OnboardingSecureStorageException(this.message, {this.operation});

  final String message;
  final String? operation;

  @override
  String toString() => message;
}

sealed class OnboardingSnapshotRead<T> {
  const OnboardingSnapshotRead();
}

class OnboardingSnapshotAbsent<T> extends OnboardingSnapshotRead<T> {
  const OnboardingSnapshotAbsent();
}

class OnboardingSnapshotPresent<T> extends OnboardingSnapshotRead<T> {
  const OnboardingSnapshotPresent(this.value);

  final T value;
}

class OnboardingSnapshotInvalid<T> extends OnboardingSnapshotRead<T> {
  const OnboardingSnapshotInvalid(this.reason, {this.detail});

  final InvalidSnapshotReason reason;
  final String? detail;
}
