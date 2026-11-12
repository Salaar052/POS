/// Outcome of server-backed session validation during app launch.
enum AuthSessionLaunchState {
  /// No refresh credential stored for the selected business.
  none,

  /// Backend confirmed session for the selected business.
  valid,

  /// Credential present but rejected (revoked, expired, or wrong business).
  invalid,

  /// Backend unreachable; must not grant shell access.
  unavailable,
}

class AuthSessionLaunchContext {
  const AuthSessionLaunchContext({required this.state, this.businessId});

  final AuthSessionLaunchState state;
  final String? businessId;

  static const none = AuthSessionLaunchContext(
    state: AuthSessionLaunchState.none,
  );
}
