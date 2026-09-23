import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:haphap_fe/core/network/token_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const storage = FlutterSecureStorage();

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    await TokenManager.deleteToken();
  });

  test(
    'non-remembered login is available only to the current session',
    () async {
      await TokenManager.saveSession(
        token: 'session-token',
        role: 'USER',
        remember: false,
      );

      expect(await TokenManager.getToken(), 'session-token');
      expect(await TokenManager.getRole(), 'USER');
      expect(await storage.read(key: 'auth_token'), isNull);
      expect(await storage.read(key: 'auth_role'), isNull);
    },
  );

  test('remembered login persists both token and role securely', () async {
    await TokenManager.saveSession(
      token: 'remembered-token',
      role: 'MERCHANT',
      remember: true,
    );

    expect(await storage.read(key: 'auth_token'), 'remembered-token');
    expect(await storage.read(key: 'auth_role'), 'MERCHANT');

    await TokenManager.deleteToken();
    expect(await TokenManager.hasToken(), isFalse);
    expect(await storage.read(key: 'auth_role'), isNull);
  });
}
