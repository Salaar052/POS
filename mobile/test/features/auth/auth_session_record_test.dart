import 'package:flutter_test/flutter_test.dart';
import 'package:pos_mobile/features/auth/data/auth_session_record.dart';

void main() {
  test('parses valid session record', () {
    const raw =
        '{"businessId":"550e8400-e29b-41d4-a716-446655440000","refreshToken":"abcdefghijklmnopqrstuvwxyz1234567890"}';
    final record = AuthSessionRecord.tryParse(raw);
    expect(record, isNotNull);
    expect(record!.businessId, '550e8400-e29b-41d4-a716-446655440000');
  });

  test('rejects malformed record', () {
    expect(AuthSessionRecord.tryParse('{bad'), isNull);
    expect(AuthSessionRecord.tryParse('{}'), isNull);
  });
}
