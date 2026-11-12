// ignore_for_file: prefer_initializing_formals

import 'package:flutter/foundation.dart';
import 'package:pos_mobile/core/network/auth_api.dart';
import 'package:pos_mobile/features/auth/data/auth_session_record.dart';
import 'package:pos_mobile/features/auth/data/auth_session_store.dart';

class AuthSessionController extends ChangeNotifier {
  AuthSessionController({required AuthSessionStore store, required AuthApi api})
    : _store = store,
      _api = api;

  // Private fields assigned via constructor initializers (not `this.` formals).
  final AuthSessionStore _store;
  final AuthApi _api;

  String? _accessToken;
  String? _activeBusinessId;
  String? _userEmail;

  String? get accessToken => _accessToken;
  String? get activeBusinessId => _activeBusinessId;
  String? get userEmail => _userEmail;
  bool get hasAccessToken => _accessToken != null && _activeBusinessId != null;

  Future<AuthSessionPayload> login({
    required String email,
    required String password,
    required String businessId,
  }) async {
    final payload = await _api.login(
      email: email,
      password: password,
      businessId: businessId,
    );
    if (payload.businessId != businessId) {
      throw AuthApiException('Session does not match this business.');
    }
    await _persist(payload);
    return payload;
  }

  Future<void> applyRestoredSession(AuthSessionPayload payload) async {
    await _persist(payload);
  }

  Future<bool> logout() async {
    final record = await _store.read();
    var serverRevoked = false;
    if (record != null) {
      serverRevoked = await _api.logout(refreshToken: record.refreshToken);
    }
    await clearLocalSession();
    return serverRevoked;
  }

  Future<void> clearLocalSession() async {
    _accessToken = null;
    _activeBusinessId = null;
    _userEmail = null;
    await _store.clear();
    notifyListeners();
  }

  Future<void> _persist(AuthSessionPayload payload) async {
    _accessToken = payload.accessToken;
    _activeBusinessId = payload.businessId;
    _userEmail = payload.userEmail;
    await _store.write(
      AuthSessionRecord(
        businessId: payload.businessId,
        refreshToken: payload.refreshToken,
      ),
    );
    notifyListeners();
  }
}
