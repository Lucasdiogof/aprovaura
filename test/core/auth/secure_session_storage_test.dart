import 'package:aura/core/auth/secure_session_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const key = 'sb-abc-auth-token';
  const secure = FlutterSecureStorage();

  SecureSessionStorage storage() =>
      SecureSessionStorage(persistSessionKey: key, secureStorage: secure);

  test('chave igual à padrão do supabase_flutter', () {
    expect(supabaseSessionKey('https://abc.supabase.co'), key);
  });

  test(
    'atualização: migra a sessão do SharedPreferences e apaga o texto puro',
    () async {
      SharedPreferences.setMockInitialValues({key: 'session-json'});
      FlutterSecureStorage.setMockInitialValues({});

      final s = storage();
      await s.initialize();

      expect(await s.accessToken(), 'session-json');
      expect(await s.hasAccessToken(), isTrue);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey(key), isFalse);
    },
  );

  test('reinstalação: sessão que sobrou no Keychain é descartada', () async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({key: 'old-install-session'});

    final s = storage();
    await s.initialize();

    expect(await s.hasAccessToken(), isFalse);
  });

  test('execuções seguintes mantêm a sessão do Keychain', () async {
    SharedPreferences.setMockInitialValues({
      SecureSessionStorage.installMarkerKey: true,
    });
    FlutterSecureStorage.setMockInitialValues({key: 'current-session'});

    final s = storage();
    await s.initialize();

    expect(await s.accessToken(), 'current-session');
  });

  test('persist/remove passam só pelo armazenamento seguro', () async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});

    final s = storage();
    await s.initialize();
    await s.persistSession('new-session');
    expect(await s.accessToken(), 'new-session');
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(key), isNull);

    await s.removePersistedSession();
    expect(await s.hasAccessToken(), isFalse);
  });
}
