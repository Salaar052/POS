/// Serializes async secure-storage operations to avoid overlapping plugin calls.
final class SecureStorageOperationQueue {
  Future<void> _tail = Future<void>.value();

  Future<T> run<T>(Future<T> Function() action) {
    final operation = _tail.then((_) => action());
    _tail = operation.then((_) {}, onError: (_) {});
    return operation;
  }
}
