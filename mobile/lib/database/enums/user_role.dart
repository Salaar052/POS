abstract final class UserRole {
  static const owner = 'owner';
  static const manager = 'manager';
  static const cashier = 'cashier';

  static const all = [owner, manager, cashier];

  static bool isValid(String value) => all.contains(value);
}
