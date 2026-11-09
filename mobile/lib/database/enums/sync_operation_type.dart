abstract final class SyncOperationType {
  static const create = 'create';
  static const update = 'update';
  static const tombstone = 'tombstone';

  static const all = [create, update, tombstone];

  static bool isValid(String value) => all.contains(value);
}
