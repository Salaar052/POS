abstract final class OnboardingSnapshotValidation {
  static final RegExp uuidPattern = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
  );

  static final RegExp emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static bool isUuid(String value) => uuidPattern.hasMatch(value.trim());

  static bool isReasonableEmail(String value) =>
      value.trim().length <= 320 && emailPattern.hasMatch(value.trim());
}
