import 'package:flutter_test/flutter_test.dart';
import 'package:pos_mobile/core/config/api_config.dart';

void main() {
  group('ApiConfig.validateForCurrentBuild', () {
    test('debug accepts omitted URL with localhost default', () {
      final result = ApiConfig.validateForCurrentBuild(
        debugBuild: true,
        rawCompileTimeOverride: ApiConfig.unsetSentinel,
      );
      expect(result.isOk, isTrue);
    });

    test('release rejects omitted API_BASE_URL', () {
      final result = ApiConfig.validateForCurrentBuild(
        debugBuild: false,
        rawCompileTimeOverride: ApiConfig.unsetSentinel,
      );
      expect(result.code, ApiConfigValidationCode.missingExplicitUrl);
    });

    test('release rejects HTTP', () {
      final result = ApiConfig.validateForCurrentBuild(
        debugBuild: false,
        rawCompileTimeOverride: 'http://api.example.com',
      );
      expect(result.code, ApiConfigValidationCode.httpNotAllowed);
    });

    test('release rejects HTTPS localhost', () {
      final result = ApiConfig.validateForCurrentBuild(
        debugBuild: false,
        rawCompileTimeOverride: 'https://localhost',
      );
      expect(result.code, ApiConfigValidationCode.localhostNotAllowed);
    });

    test('release accepts HTTPS production hostname', () {
      final result = ApiConfig.validateForCurrentBuild(
        debugBuild: false,
        rawCompileTimeOverride: 'https://api.pakpos.example',
      );
      expect(result.isOk, isTrue);
    });

    test('rejects malformed URL', () {
      final result = ApiConfig.validateForCurrentBuild(
        debugBuild: true,
        rawCompileTimeOverride: '::::',
      );
      expect(result.code, ApiConfigValidationCode.invalidUrl);
    });

    test('rejects unsupported scheme', () {
      final result = ApiConfig.validateForCurrentBuild(
        debugBuild: true,
        rawCompileTimeOverride: 'ftp://files.example.com',
      );
      expect(result.code, ApiConfigValidationCode.unsupportedScheme);
    });
  });
}
