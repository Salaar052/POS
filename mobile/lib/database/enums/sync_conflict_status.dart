abstract final class SyncConflictStatus {
  static const open = 'open';
  static const resolved = 'resolved';
  static const dismissed = 'dismissed';

  static const all = [open, resolved, dismissed];

  static bool isValid(String value) => all.contains(value);
}
