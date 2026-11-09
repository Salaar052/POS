import 'package:flutter_test/flutter_test.dart';
import 'package:pos_mobile/data/repositories/local_business_repository.dart';
import 'package:pos_mobile/data/repositories/users_cache_repository.dart';

import '../helpers/test_database.dart';

void main() {
  late TestDatabaseHarness harness;

  setUp(() {
    harness = TestDatabaseHarness.memory();
  });

  tearDown(() async {
    await harness.close();
  });

  test('users_cache has no secret columns in schema', () async {
    final columns = await harness.database
        .customSelect('PRAGMA table_info(users_cache)')
        .get();
    final names = columns
        .map((r) => (r.data['name'] as String).toLowerCase())
        .toList();
    expect(names, isNot(contains('password')));
    expect(names, isNot(contains('token')));
    expect(names, isNot(contains('verifier')));
  });

  test('rejects invalid role', () async {
    await LocalBusinessRepository(harness.runner)
        .provisionBusiness(businessId: 'biz-a', name: 'Shop');
    final users = UsersCacheRepository(harness.runner);
    expect(
      () => users.upsertUser(
        userId: 'u1',
        displayName: 'Cashier',
        role: 'superadmin',
      ),
      throwsA(isA<ArgumentError>()),
    );
  });
}
