import 'package:pos_mobile/core/security/secure_storage_keys.dart';
import 'package:pos_mobile/core/security/secure_storage_service.dart';
import 'package:pos_mobile/features/auth/data/auth_session_record.dart';

class AuthSessionStore {
  AuthSessionStore(this._secureStorage);

  final SecureStorageService _secureStorage;

  Future<AuthSessionRecord?> read() async {
    final raw = await _secureStorage.read(key: SecureStorageKeys.refreshToken);
    return AuthSessionRecord.tryParse(raw);
  }

  Future<void> write(AuthSessionRecord record) async {
    await _secureStorage.write(
      key: SecureStorageKeys.refreshToken,
      value: record.encode(),
    );
  }

  Future<void> clear() async {
    await _secureStorage.delete(key: SecureStorageKeys.refreshToken);
  }
}
