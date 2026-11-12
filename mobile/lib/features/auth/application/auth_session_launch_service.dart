// ignore_for_file: prefer_initializing_formals

import 'package:pos_mobile/core/network/auth_api.dart';
import 'package:pos_mobile/features/auth/application/auth_session_controller.dart';
import 'package:pos_mobile/features/auth/data/auth_session_store.dart';
import 'package:pos_mobile/features/auth/domain/auth_session_launch_state.dart';

class AuthSessionLaunchService {
  AuthSessionLaunchService({
    required AuthSessionStore store,
    required AuthApi api,
    required AuthSessionController sessionController,
  }) : _store = store,
       _api = api,
       _sessionController = sessionController;

  final AuthSessionStore _store;
  final AuthApi _api;
  final AuthSessionController _sessionController;

  Future<AuthSessionLaunchContext> resolveForBusiness({
    required String businessId,
  }) async {
    final record = await _store.read();
    if (record == null) {
      return AuthSessionLaunchContext.none;
    }
    if (record.businessId != businessId) {
      return AuthSessionLaunchContext(
        state: AuthSessionLaunchState.invalid,
        businessId: record.businessId,
      );
    }

    try {
      final payload = await _api.restoreSession(
        refreshToken: record.refreshToken,
        businessId: businessId,
      );
      if (payload.businessId != businessId) {
        await _sessionController.clearLocalSession();
        return AuthSessionLaunchContext(
          state: AuthSessionLaunchState.invalid,
          businessId: businessId,
        );
      }
      await _sessionController.applyRestoredSession(payload);
      return AuthSessionLaunchContext(
        state: AuthSessionLaunchState.valid,
        businessId: businessId,
      );
    } on AuthApiException catch (error) {
      if (error.isNetworkFailure) {
        return AuthSessionLaunchContext(
          state: AuthSessionLaunchState.unavailable,
          businessId: businessId,
        );
      }
      await _sessionController.clearLocalSession();
      return AuthSessionLaunchContext(
        state: AuthSessionLaunchState.invalid,
        businessId: businessId,
      );
    }
  }
}
