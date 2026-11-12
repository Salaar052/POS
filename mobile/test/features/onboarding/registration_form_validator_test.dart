import 'package:flutter_test/flutter_test.dart';
import 'package:pos_mobile/features/onboarding/domain/registration_form_validator.dart';

void main() {
  const valid = RegistrationFormValues(
    businessName: 'Karachi Shop',
    ownerName: 'Ali Khan',
    ownerEmail: 'ali@example.com',
    password: 'secure-pass-12',
  );

  test('accepts valid registration values', () {
    expect(validateRegistrationForm(valid).isValid, isTrue);
  });

  test('requires business and owner names', () {
    final result = validateRegistrationForm(
      const RegistrationFormValues(
        businessName: 'x',
        ownerName: '',
        ownerEmail: 'ali@example.com',
        password: 'secure-pass-12',
      ),
    );
    expect(result.fieldErrors['businessName'], isNotNull);
    expect(result.fieldErrors['ownerName'], isNotNull);
  });

  test('validates email and password rules', () {
    final result = validateRegistrationForm(
      const RegistrationFormValues(
        businessName: 'Karachi Shop',
        ownerName: 'Ali Khan',
        ownerEmail: 'not-an-email',
        password: 'short',
      ),
    );
    expect(result.fieldErrors['ownerEmail'], isNotNull);
    expect(result.fieldErrors['password'], isNotNull);
  });
}
