import 'dart:convert';

/// Validates JSON payloads before SQLite persistence.
class JsonValidator {
  JsonValidator({this.maxBytes = 262144});

  final int maxBytes;

  String encodeObject(Map<String, Object?> value) {
    final encoded = jsonEncode(value);
    validateEncoded(encoded);
    return encoded;
  }

  String validateEncoded(String value) {
    if (value.length > maxBytes) {
      throw JsonValidationException('JSON exceeds $maxBytes bytes');
    }
    try {
      jsonDecode(value);
    } on FormatException catch (e) {
      throw JsonValidationException('Invalid JSON: ${e.message}');
    }
    return value;
  }

  Map<String, Object?> decodeObject(String value) {
    validateEncoded(value);
    final decoded = jsonDecode(value);
    if (decoded is! Map<String, Object?>) {
      throw JsonValidationException('Expected JSON object');
    }
    return decoded;
  }
}

class JsonValidationException implements Exception {
  JsonValidationException(this.message);

  final String message;

  @override
  String toString() => 'JsonValidationException: $message';
}
