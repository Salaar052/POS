class RegistrationFormValues {
  const RegistrationFormValues({
    required this.businessName,
    required this.ownerName,
    required this.ownerEmail,
    required this.password,
    this.businessPhone,
    this.businessEmail,
  });

  final String businessName;
  final String ownerName;
  final String ownerEmail;
  final String password;
  final String? businessPhone;
  final String? businessEmail;
}

class RegistrationFormValidation {
  const RegistrationFormValidation({
    this.fieldErrors = const {},
    this.formError,
  });

  final Map<String, String> fieldErrors;
  final String? formError;

  bool get isValid => fieldErrors.isEmpty && formError == null;
}

/// Local validation aligned with the NestJS `RegisterBusinessDto` rules.
RegistrationFormValidation validateRegistrationForm(
  RegistrationFormValues values,
) {
  final errors = <String, String>{};

  void requireLength(String key, String label, int min, int max, String raw) {
    final trimmed = raw.trim();
    if (trimmed.length < min) {
      errors[key] = '$label must be at least $min characters';
    } else if (trimmed.length > max) {
      errors[key] = '$label must be at most $max characters';
    }
  }

  requireLength('businessName', 'Business name', 2, 200, values.businessName);
  requireLength('ownerName', 'Owner name', 2, 200, values.ownerName);

  final email = values.ownerEmail.trim();
  if (email.isEmpty || !_emailPattern.hasMatch(email)) {
    errors['ownerEmail'] = 'Enter a valid owner email';
  } else if (email.length > 320) {
    errors['ownerEmail'] = 'Email is too long';
  }

  final optionalBusinessEmail = values.businessEmail?.trim();
  if (optionalBusinessEmail != null &&
      optionalBusinessEmail.isNotEmpty &&
      !_emailPattern.hasMatch(optionalBusinessEmail)) {
    errors['businessEmail'] = 'Enter a valid business email';
  }

  final phone = values.businessPhone?.trim();
  if (phone != null && phone.isNotEmpty && phone.length > 50) {
    errors['businessPhone'] = 'Phone must be at most 50 characters';
  }

  final password = values.password;
  if (password.length < 12) {
    errors['password'] = 'Password must be at least 12 characters';
  } else if (password.length > 128) {
    errors['password'] = 'Password must be at most 128 characters';
  } else if (!_passwordPattern.hasMatch(password)) {
    errors['password'] =
        'Password must include at least one letter and one number';
  }

  return RegistrationFormValidation(fieldErrors: errors);
}

final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
final _passwordPattern = RegExp(r'^(?=.*[A-Za-z])(?=.*\d).+$');
