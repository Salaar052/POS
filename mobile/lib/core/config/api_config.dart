import 'package:flutter/foundation.dart';

/// Result of validating compile-time and runtime API configuration.
enum ApiConfigValidationCode {
  ok,
  missingExplicitUrl,
  emptyUrl,
  invalidUrl,
  unsupportedScheme,
  httpNotAllowed,
  localhostNotAllowed,
}

class ApiConfigValidation {
  const ApiConfigValidation._({required this.code, this.userMessage});

  const ApiConfigValidation.ok() : this._(code: ApiConfigValidationCode.ok);

  const ApiConfigValidation.failure({
    required ApiConfigValidationCode code,
    required String userMessage,
  }) : this._(code: code, userMessage: userMessage);

  final ApiConfigValidationCode code;
  final String? userMessage;

  bool get isOk => code == ApiConfigValidationCode.ok;
}

/// HTTP API base URL for the NestJS server (no trailing slash).
abstract final class ApiConfig {
  static const String unsetSentinel = '__PAKPOS_API_BASE_URL_UNSET__';

  static const String _envBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: unsetSentinel,
  );

  static const Duration registrationTimeout = Duration(seconds: 30);

  static const String _debugDevelopmentDefault = 'http://127.0.0.1:3000';

  /// Raw compile-time value (may be [unsetSentinel]).
  @visibleForTesting
  static String get rawCompileTimeValue => _envBaseUrl;

  /// Validates API origin for the current build mode (call at startup).
  static ApiConfigValidation validateForCurrentBuild({
    required bool debugBuild,
    String? rawCompileTimeOverride,
  }) {
    final raw = rawCompileTimeOverride ?? _envBaseUrl;

    if (!debugBuild) {
      if (raw == unsetSentinel || raw.trim().isEmpty) {
        return const ApiConfigValidation.failure(
          code: ApiConfigValidationCode.missingExplicitUrl,
          userMessage:
              'This build requires API_BASE_URL via --dart-define. '
              'Contact your administrator for the correct Pak POS API host.',
        );
      }
    }

    final resolved = _resolveBaseUrl(raw: raw, debugBuild: debugBuild);
    if (resolved.isEmpty) {
      return const ApiConfigValidation.failure(
        code: ApiConfigValidationCode.emptyUrl,
        userMessage: 'API_BASE_URL is not configured for this build.',
      );
    }

    Uri uri;
    try {
      uri = Uri.parse(resolved);
    } catch (_) {
      return const ApiConfigValidation.failure(
        code: ApiConfigValidationCode.invalidUrl,
        userMessage: 'API_BASE_URL is not a valid URL.',
      );
    }

    if (uri.scheme != 'http' && uri.scheme != 'https') {
      return const ApiConfigValidation.failure(
        code: ApiConfigValidationCode.unsupportedScheme,
        userMessage: 'API_BASE_URL must use http or https.',
      );
    }

    if (!debugBuild) {
      if (uri.scheme != 'https') {
        return const ApiConfigValidation.failure(
          code: ApiConfigValidationCode.httpNotAllowed,
          userMessage: 'API_BASE_URL must use HTTPS in release builds.',
        );
      }
      if (_isLocalhostHost(uri.host)) {
        return const ApiConfigValidation.failure(
          code: ApiConfigValidationCode.localhostNotAllowed,
          userMessage:
              'API_BASE_URL cannot point to localhost in release builds.',
        );
      }
    }

    return const ApiConfigValidation.ok();
  }

  /// Resolved API origin for the current build/run configuration.
  static String get baseUrl {
    final validation = validateForCurrentBuild(debugBuild: kDebugMode);
    if (!validation.isOk) {
      throw StateError(validation.userMessage ?? 'Invalid API configuration');
    }
    final raw = _envBaseUrl;
    return _resolveBaseUrl(raw: raw, debugBuild: kDebugMode);
  }

  static Uri registrationUri() => Uri.parse('$baseUrl/businesses/register');

  /// Registration calls re-check transport policy.
  static void assertTransportPolicy() {
    final validation = validateForCurrentBuild(debugBuild: kDebugMode);
    if (!validation.isOk) {
      throw StateError(validation.userMessage ?? 'Invalid API configuration');
    }
  }

  static String _resolveBaseUrl({
    required String raw,
    required bool debugBuild,
  }) {
    if (raw == unsetSentinel || raw.trim().isEmpty) {
      if (debugBuild) {
        return _trimTrailingSlash(_debugDevelopmentDefault);
      }
      return '';
    }
    return _trimTrailingSlash(raw.trim());
  }

  static String _trimTrailingSlash(String value) {
    return value.endsWith('/') ? value.substring(0, value.length - 1) : value;
  }

  static bool _isLocalhostHost(String host) {
    final normalized = host.toLowerCase();
    if (normalized == 'localhost') {
      return true;
    }
    if (normalized == '127.0.0.1' || normalized == '0.0.0.0') {
      return true;
    }
    if (normalized == '::1') {
      return true;
    }
    if (normalized.endsWith('.localhost')) {
      return true;
    }
    return false;
  }
}
