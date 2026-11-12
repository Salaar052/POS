import 'dart:convert';

class AuthSessionRecord {
  const AuthSessionRecord({
    required this.businessId,
    required this.refreshToken,
  });

  final String businessId;
  final String refreshToken;

  Map<String, dynamic> toJson() => {
    'businessId': businessId,
    'refreshToken': refreshToken,
  };

  static AuthSessionRecord? tryParse(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return null;
    }
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final businessId = map['businessId'];
      final refreshToken = map['refreshToken'];
      if (businessId is! String || refreshToken is! String) {
        return null;
      }
      if (businessId.isEmpty || refreshToken.length < 32) {
        return null;
      }
      return AuthSessionRecord(
        businessId: businessId,
        refreshToken: refreshToken,
      );
    } catch (_) {
      return null;
    }
  }

  String encode() => jsonEncode(toJson());
}
