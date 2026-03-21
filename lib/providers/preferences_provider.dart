import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesProvider extends ChangeNotifier {
  SharedPreferences? _prefs;

  ThemeMode _themeMode = ThemeMode.system;
  String _language = 'en'; // 'en' or 'ta'
  bool _notificationsMuted = false;

  ThemeMode get themeMode => _themeMode;
  String get language => _language;
  bool get notificationsMuted => _notificationsMuted;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();

    final tStr = _prefs?.getString('theme_mode');
    if (tStr == 'light') _themeMode = ThemeMode.light;
    if (tStr == 'dark') _themeMode = ThemeMode.dark;

    _language = _prefs?.getString('app_language') ?? 'en';
    _notificationsMuted = _prefs?.getBool('notifications_muted') ?? false;

    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    String tStr = 'system';
    if (mode == ThemeMode.light) tStr = 'light';
    if (mode == ThemeMode.dark) tStr = 'dark';
    await _prefs?.setString('theme_mode', tStr);
    notifyListeners();
  }

  Future<void> setLanguage(String langCode) async {
    _language = langCode;
    await _prefs?.setString('app_language', langCode);
    notifyListeners();
  }

  Future<void> setNotificationsMuted(bool muted) async {
    _notificationsMuted = muted;
    await _prefs?.setBool('notifications_muted', muted);
    notifyListeners();
  }
}
