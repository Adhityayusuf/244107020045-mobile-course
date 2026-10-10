import 'package:shared_preferences/shared_preferences.dart';

/// Repository preferensi: seluruh akses key-value terpusat di sini,
/// tidak tersebar di widget.
class PrefsRepository {
  PrefsRepository({this.prefs});

  static const _darkModeKey = 'dark_mode';
  static const _lastOpenedKey = 'last_opened_at';

  /// Disuntikkan bila tersedia (untuk test / demo); bila null, instance
  /// global `SharedPreferences.getInstance()` dipakai saat dibutuhkan.
  final SharedPreferences? prefs;

  Future<SharedPreferences> _instance() async {
    return prefs ?? await SharedPreferences.getInstance();
  }

  Future<bool> getDarkMode() async {
    final prefs = await _instance();
    return prefs.getBool(_darkModeKey) ?? false;
  }

  Future<void> setDarkMode(bool value) async {
    final prefs = await _instance();
    await prefs.setBool(_darkModeKey, value);
  }

  Future<void> markOpenedNow() async {
    final prefs = await _instance();
    await prefs.setString(_lastOpenedKey, DateTime.now().toIso8601String());
  }

  Future<String?> getLastOpened() async {
    final prefs = await _instance();
    return prefs.getString(_lastOpenedKey);
  }
}
