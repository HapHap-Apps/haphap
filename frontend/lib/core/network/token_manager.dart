import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenManager {
  TokenManager._();

  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'auth_token';
  static const _roleKey = 'auth_role';

  static String? _sessionToken;
  static String? _sessionRole;

  static Future<void> saveSession({
    required String token,
    required String role,
    required bool remember,
  }) async {
    _sessionToken = token;
    _sessionRole = role;

    if (remember) {
      await Future.wait([
        _storage.write(key: _tokenKey, value: token),
        _storage.write(key: _roleKey, value: role),
      ]);
      return;
    }

    await Future.wait([
      _storage.delete(key: _tokenKey),
      _storage.delete(key: _roleKey),
    ]);
  }

  static Future<String?> getToken() async {
    return _sessionToken ?? await _storage.read(key: _tokenKey);
  }

  static Future<String?> getRole() async {
    return _sessionRole ?? await _storage.read(key: _roleKey);
  }

  static Future<void> deleteToken() async {
    _sessionToken = null;
    _sessionRole = null;
    await Future.wait([
      _storage.delete(key: _tokenKey),
      _storage.delete(key: _roleKey),
    ]);
  }

  static Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
