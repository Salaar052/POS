abstract final class ActivationStatus {
  static const unregistered = 'unregistered';
  static const pending = 'pending';
  static const activated = 'activated';
  static const revoked = 'revoked';

  static const all = [unregistered, pending, activated, revoked];

  static bool isValid(String value) => all.contains(value);
}
