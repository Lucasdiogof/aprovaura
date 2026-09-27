import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Guarda a sessão do Supabase (access + refresh token) no Keychain (iOS) /
/// Keystore (Android) em vez do SharedPreferences/NSUserDefaults em texto
/// puro, que é o padrão do supabase_flutter.
///
/// Só para mobile: na web o padrão continua (o armazenamento "seguro" de lá
/// também acaba no navegador, sem ganho real).
///
/// Na primeira execução:
/// - migra a sessão que já estava no SharedPreferences, para ninguém ser
///   deslogado pela atualização, e apaga a cópia em texto puro;
/// - sem sessão antiga e sem a marca de instalação, apaga o que houver no
///   Keychain: ele sobrevive à desinstalação no iOS e reinstalar o app não
///   pode reabrir a conta de antes.
class SecureSessionStorage extends LocalStorage {
  SecureSessionStorage({
    required this.persistSessionKey,
    FlutterSecureStorage? secureStorage,
    Future<SharedPreferences> Function()? preferences,
  }) : _secure = secureStorage ?? const FlutterSecureStorage(),
       _preferences = preferences ?? SharedPreferences.getInstance;

  static const installMarkerKey = 'secure_session_storage_installed';

  final String persistSessionKey;
  final FlutterSecureStorage _secure;
  final Future<SharedPreferences> Function() _preferences;

  @override
  Future<void> initialize() async {
    final prefs = await _preferences();
    final legacySession = prefs.getString(persistSessionKey);

    if (legacySession != null) {
      await _secure.write(key: persistSessionKey, value: legacySession);
      await prefs.remove(persistSessionKey);
    } else if (prefs.getBool(installMarkerKey) != true) {
      await _secure.delete(key: persistSessionKey);
    }
    await prefs.setBool(installMarkerKey, true);
  }

  @override
  Future<bool> hasAccessToken() async =>
      await _secure.read(key: persistSessionKey) != null;

  @override
  Future<String?> accessToken() => _secure.read(key: persistSessionKey);

  @override
  Future<void> removePersistedSession() =>
      _secure.delete(key: persistSessionKey);

  @override
  Future<void> persistSession(String persistSessionString) =>
      _secure.write(key: persistSessionKey, value: persistSessionString);
}

/// Mesma chave que o supabase_flutter usa por padrão, para a migração achar
/// a sessão antiga.
String supabaseSessionKey(String supabaseUrl) =>
    'sb-${Uri.parse(supabaseUrl).host.split('.').first}-auth-token';
