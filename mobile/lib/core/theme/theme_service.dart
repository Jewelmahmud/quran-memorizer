import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends ChangeNotifier {
  static const String _themeModeKey = 'theme_mode';

  static final ThemeService _instance = ThemeService._internal();
  factory ThemeService() => _instance;
  ThemeService._internal();

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  /// Initialize the theme service
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMode = prefs.getString(_themeModeKey);

    if (savedMode != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (mode) => mode.toString() == 'ThemeMode.$savedMode',
        orElse: () => ThemeMode.system,
      );
    } else {
      _themeMode = ThemeMode.system;
    }

    notifyListeners();
  }

  /// Change the theme mode
  Future<void> changeThemeMode(ThemeMode mode) async {
    if (_themeMode != mode) {
      _themeMode = mode;
      await _saveThemeMode(mode);
      notifyListeners();
    }
  }

  Future<void> _saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    final modeString = mode.toString().split('.').last;
    await prefs.setString(_themeModeKey, modeString);
  }

  bool get isDarkMode {
    if (_themeMode == ThemeMode.light) return false;
    if (_themeMode == ThemeMode.dark) return true;
    // For system mode, we can't determine without context
    return false;
  }

  String get themeModeName {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}

// Theme Mode Options for Settings Dropdown
class ThemeModeOption {
  final ThemeMode mode;
  final String name;
  final String icon;

  const ThemeModeOption({
    required this.mode,
    required this.name,
    required this.icon,
  });
}

extension ThemeModeOptions on ThemeService {
  List<ThemeModeOption> get themeModeOptions => [
        const ThemeModeOption(
          mode: ThemeMode.system,
          name: 'System',
          icon: '🔄',
        ),
        const ThemeModeOption(
          mode: ThemeMode.light,
          name: 'Light',
          icon: '☀️',
        ),
        const ThemeModeOption(
          mode: ThemeMode.dark,
          name: 'Dark',
          icon: '🌙',
        ),
      ];
}
