import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:pos_mobile/core/config/api_config.dart';

class AuthApiException implements Exception {
  AuthApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  bool get isNetworkFailure => statusCode == null;
}

class AuthSessionPayload {
  const AuthSessionPayload({
    required this.accessToken,
    required this.refreshToken,
    required this.accessTokenExpiresInSeconds,
    required this.businessId,
    required this.userEmail,
  });

  final String accessToken;
  final String refreshToken;
  final int accessTokenExpiresInSeconds;
  final String businessId;
  final String userEmail;
}

abstract interface class AuthApi {
  Future<AuthSessionPayload> login({
    required String email,
    required String password,
    required String businessId,
  });

  Future<AuthSessionPayload> restoreSession({
    required String refreshToken,
    required String businessId,
  });

  Future<bool> logout({required String refreshToken});
}

class HttpAuthApi implements AuthApi {
  HttpAuthApi({http.Client? client, Duration? timeout})
    : _client = client ?? http.Client(),
      _timeout = timeout ?? const Duration(seconds: 30);

  final http.Client _client;
  final Duration _timeout;

  Uri _uri(String path) => Uri.parse('${ApiConfig.baseUrl}$path');

  @override
  Future<AuthSessionPayload> login({
    required String email,
    required String password,
    required String businessId,
  }) async {
    return _postSession('/auth/login', {
      'email': email.trim(),
      'password': password,
      'businessId': businessId,
    });
  }

  @override
  Future<AuthSessionPayload> restoreSession({
    required String refreshToken,
    required String businessId,
  }) async {
    return _postSession('/auth/session/restore', {
      'refreshToken': refreshToken,
      'businessId': businessId,
    });
  }

  @override
  Future<bool> logout({required String refreshToken}) async {
    try {
      final response = await _client
          .post(
            _uri('/auth/logout'),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({'refreshToken': refreshToken}),
          )
          .timeout(_timeout);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        return body['serverRevoked'] == true;
      }
      return false;
    } on Exception {
      return false;
    }
  }

  Future<AuthSessionPayload> _postSession(
    String path,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _client
          .post(
            _uri(path),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(_timeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return _parseSession(response.body);
      }

      final message = _messageFromBody(response.body);
      throw AuthApiException(message, statusCode: response.statusCode);
    } on AuthApiException {
      rethrow;
    } catch (_) {
      throw AuthApiException('Unable to reach the authentication server.');
    }
  }

  AuthSessionPayload _parseSession(String body) {
    final map = jsonDecode(body) as Map<String, dynamic>;
    final accessToken = map['accessToken'];
    final refreshToken = map['refreshToken'];
    final business = map['business'];
    final user = map['user'];
    if (accessToken is! String ||
        refreshToken is! String ||
        business is! Map<String, dynamic> ||
        user is! Map<String, dynamic>) {
      throw AuthApiException('Unexpected authentication response.');
    }
    final businessId = business['id'];
    final email = user['email'];
    final expires = map['accessTokenExpiresInSeconds'];
    if (businessId is! String || email is! String) {
      throw AuthApiException('Unexpected authentication response.');
    }
    return AuthSessionPayload(
      accessToken: accessToken,
      refreshToken: refreshToken,
      accessTokenExpiresInSeconds: expires is int
          ? expires
          : int.tryParse('$expires') ?? 900,
      businessId: businessId,
      userEmail: email,
    );
  }

  String _messageFromBody(String body) {
    try {
      final map = jsonDecode(body) as Map<String, dynamic>;
      final message = map['message'];
      if (message is List && message.isNotEmpty) {
        return message.join(', ');
      }
      if (message is String && message.isNotEmpty) {
        return message;
      }
    } catch (_) {}
    return 'Authentication failed.';
  }
}
