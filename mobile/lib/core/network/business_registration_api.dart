import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:pos_mobile/core/config/api_config.dart';
import 'package:pos_mobile/core/network/business_registration_models.dart';

/// Typed client for `POST /businesses/register`.
abstract interface class BusinessRegistrationApi {
  Future<RegisterBusinessResult> register(RegisterBusinessRequest request);
}

class HttpBusinessRegistrationApi implements BusinessRegistrationApi {
  HttpBusinessRegistrationApi({
    http.Client? client,
    Duration? timeout,
    Uri? endpoint,
  }) : _client = client ?? http.Client(),
       _timeout = timeout ?? ApiConfig.registrationTimeout,
       _endpoint = endpoint ?? ApiConfig.registrationUri();

  final http.Client _client;
  final Duration _timeout;
  final Uri _endpoint;

  @override
  Future<RegisterBusinessResult> register(
    RegisterBusinessRequest request,
  ) async {
    ApiConfig.assertTransportPolicy();
    try {
      final response = await _client
          .post(
            _endpoint,
            headers: const {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(request.toJson()),
          )
          .timeout(_timeout);

      return _mapResponse(response);
    } on TimeoutException {
      throw const RegistrationApiException(
        RegistrationApiFailureKind.timeout,
        'The registration request timed out. The server may or may not have created your account.',
      );
    } on http.ClientException {
      throw const RegistrationApiException(
        RegistrationApiFailureKind.network,
        'Could not reach the server. Check your connection and try again.',
      );
    } on FormatException catch (error) {
      throw RegistrationApiException(
        RegistrationApiFailureKind.malformedResponse,
        'The server returned an unexpected response.',
        details: error.message,
      );
    }
  }

  RegisterBusinessResult _mapResponse(http.Response response) {
    final bodyText = response.body;
    Map<String, dynamic>? json;
    if (bodyText.isNotEmpty) {
      try {
        final decoded = jsonDecode(bodyText);
        if (decoded is Map<String, dynamic>) {
          json = decoded;
        }
      } catch (_) {
        if (response.statusCode == 201) {
          throw const FormatException('Success response was not valid JSON');
        }
      }
    }

    switch (response.statusCode) {
      case 201:
        if (json == null) {
          throw const FormatException('Empty registration success body');
        }
        final result = RegisterBusinessResult.fromJson(json);
        result.validateForProvisioning();
        return result;
      case 400:
        throw RegistrationApiException(
          RegistrationApiFailureKind.validation,
          _messageFrom(json) ?? 'Please check the form and try again.',
          fieldErrors: _fieldErrorsFrom(json),
        );
      case 409:
        throw RegistrationApiException(
          RegistrationApiFailureKind.duplicateEmail,
          _messageFrom(json) ?? 'An account with this email already exists. If you recently registered, wait a moment and open the app again.',
        );
      default:
        throw RegistrationApiException(
          RegistrationApiFailureKind.server,
          _messageFrom(json) ?? 'Registration failed. Please try again later.',
          statusCode: response.statusCode,
        );
    }
  }

  static String? _messageFrom(Map<String, dynamic>? json) {
    if (json == null) return null;
    final message = json['message'];
    if (message is String && message.trim().isNotEmpty) {
      return message;
    }
    if (message is List) {
      final parts = message.whereType<String>().toList();
      if (parts.isNotEmpty) {
        return parts.join('\n');
      }
    }
    return null;
  }

  static Map<String, String>? _fieldErrorsFrom(Map<String, dynamic>? json) {
    final body = json;
    if (body == null) return null;
    final errors = <String, String>{};
    void addField(String key) {
      final value = body[key];
      if (value is List && value.isNotEmpty && value.first is String) {
        errors[key] = value.first as String;
      }
    }

    for (final key in [
      'businessName',
      'ownerName',
      'ownerEmail',
      'password',
      'businessPhone',
      'businessEmail',
    ]) {
      addField(key);
    }
    return errors.isEmpty ? null : errors;
  }
}

enum RegistrationApiFailureKind {
  validation,
  duplicateEmail,
  network,
  timeout,
  malformedResponse,
  server,
}

class RegistrationApiException implements Exception {
  const RegistrationApiException(
    this.kind,
    this.message, {
    this.details,
    this.fieldErrors,
    this.statusCode,
  });

  final RegistrationApiFailureKind kind;
  final String message;
  final String? details;
  final Map<String, String>? fieldErrors;
  final int? statusCode;

  @override
  String toString() => message;
}
