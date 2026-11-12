import 'package:flutter_test/flutter_test.dart';
import 'package:pos_mobile/core/network/auth_api.dart';
import 'package:pos_mobile/features/auth/application/auth_session_controller.dart';
import 'package:pos_mobile/features/auth/application/auth_session_launch_service.dart';
import 'package:pos_mobile/features/auth/data/auth_session_store.dart';
import 'package:pos_mobile/features/auth/domain/auth_session_launch_state.dart';

import '../../fakes/fake_secure_storage_service.dart';

const businessId = '550e8400-e29b-41d4-a716-446655440000';

class FakeAuthApi implements AuthApi {
  FakeAuthApi({this.failNetwork = false, this.reject = false});

  final bool failNetwork;
  final bool reject;

  @override
  Future<AuthSessionPayload> login({
    required String email,
    required String password,
    required String businessId,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<bool> logout({required String refreshToken}) async => true;

  @override
  Future<AuthSessionPayload> restoreSession({
    required String refreshToken,
    required String businessId,
  }) async {
    if (failNetwork) {
      throw AuthApiException('offline');
    }
    if (reject) {
      throw AuthApiException('bad', statusCode: 401);
    }
    return AuthSessionPayload(
      accessToken: 'access',
      refreshToken: refreshToken,
      accessTokenExpiresInSeconds: 900,
      businessId: businessId,
      userEmail: 'owner@example.com',
    );
  }
}

void main() {
  test('returns none when no stored session', () async {
    final service = AuthSessionLaunchService(
      store: AuthSessionStore(FakeSecureStorageService()),
      api: FakeAuthApi(),
      sessionController: AuthSessionController(
        store: AuthSessionStore(FakeSecureStorageService()),
        api: FakeAuthApi(),
      ),
    );
    final result = await service.resolveForBusiness(businessId: businessId);
    expect(result.state, AuthSessionLaunchState.none);
  });

  test('network failure does not mark session valid', () async {
    final storage = FakeSecureStorageService();
    await storage.write(
      key: 'pakpos.auth.refresh_token',
      value:
          '{"businessId":"$businessId","refreshToken":"abcdefghijklmnopqrstuvwxyz1234567890"}',
    );
    final store = AuthSessionStore(storage);
    final controller = AuthSessionController(
      store: store,
      api: FakeAuthApi(failNetwork: true),
    );
    final service = AuthSessionLaunchService(
      store: store,
      api: FakeAuthApi(failNetwork: true),
      sessionController: controller,
    );
    final result = await service.resolveForBusiness(businessId: businessId);
    expect(result.state, AuthSessionLaunchState.unavailable);
  });
}
