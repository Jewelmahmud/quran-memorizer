import 'package:flutter/material.dart';
import 'package:quran_memorizer/core/widgets/app_drawer.dart';
import 'package:quran_memorizer/core/widgets/bottom_navigation_bar.dart';
import 'package:quran_memorizer/core/localization/localization_service.dart';
import 'package:quran_memorizer/core/theme/theme_service.dart';
import 'package:quran_memorizer/l10n/app_localizations.dart';
import 'package:quran_memorizer/app/app.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final LocalizationService _localizationService = LocalizationService();
  final ThemeService _themeService = ThemeService();
  bool _showTranslation = true;
  bool _showTransliteration = false;
  bool _enableNotifications = true;
  double _playbackSpeed = 1.0;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _showTranslation = prefs.getBool('show_translation') ?? true;
      _showTransliteration = prefs.getBool('show_transliteration') ?? false;
      _enableNotifications = prefs.getBool('enable_notifications') ?? true;
      _playbackSpeed = prefs.getDouble('playback_speed') ?? 1.0;
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = _localizationService.currentLocale;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // General Settings
            _buildSectionHeader(l10n.general),
            _buildSettingsCard(
              [
                _buildDropdownSetting(
                  context,
                  icon: Icons.language,
                  label: l10n.language,
                  value: currentLocale.languageCode,
                  items: _localizationService.languageOptions
                      .map((lang) => DropdownMenuItem(
                            value: lang.code,
                            child: Row(
                              children: [
                                Text(lang.flag,
                                    style: const TextStyle(fontSize: 20)),
                                const SizedBox(width: 8),
                                Text(lang.name),
                              ],
                            ),
                          ))
                      .toList(),
                  onChanged: (value) async {
                    if (value != null) {
                      await _localizationService.changeLanguage(value);
                      LocaleNotifier().value =
                          _localizationService.currentLocale;
                    }
                  },
                ),
                _buildThemeDropdownSetting(context),
                _buildSwitchSetting(
                  context,
                  icon: Icons.notifications,
                  label: l10n.enableNotifications,
                  value: _enableNotifications,
                  onChanged: (value) {
                    setState(() => _enableNotifications = value);
                    _saveSetting('enable_notifications', value);
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Audio Settings
            _buildSectionHeader(l10n.audioSettings),
            _buildSettingsCard(
              [
                _buildSliderSetting(
                  context,
                  icon: Icons.speed,
                  label: l10n.playbackSpeed,
                  value: _playbackSpeed,
                  min: 0.5,
                  max: 2.0,
                  divisions: 6,
                  onChanged: (value) {
                    setState(() => _playbackSpeed = value);
                    _saveSetting('playback_speed', value);
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Learning Preferences
            _buildSectionHeader(l10n.learningPreferences),
            _buildSettingsCard(
              [
                _buildSwitchSetting(
                  context,
                  icon: Icons.translate,
                  label: l10n.showTranslation,
                  value: _showTranslation,
                  onChanged: (value) {
                    setState(() => _showTranslation = value);
                    _saveSetting('show_translation', value);
                  },
                ),
                _buildSwitchSetting(
                  context,
                  icon: Icons.text_fields,
                  label: l10n.showTransliteration,
                  value: _showTransliteration,
                  onChanged: (value) {
                    setState(() => _showTransliteration = value);
                    _saveSetting('show_transliteration', value);
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // About
            _buildSectionHeader(l10n.about),
            _buildSettingsCard(
              [
                _buildListTile(
                  context,
                  icon: Icons.info_outline,
                  title: l10n.version,
                  trailing: const Text('1.0.0'),
                ),
                _buildListTile(
                  context,
                  icon: Icons.star_outline,
                  title: l10n.rateApp,
                  onTap: () {
                    // TODO: Open app store for rating
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Rate app functionality coming soon')),
                    );
                  },
                ),
                _buildListTile(
                  context,
                  icon: Icons.share,
                  title: l10n.shareApp,
                  onTap: () {
                    // TODO: Share app
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Share app functionality coming soon')),
                    );
                  },
                ),
                _buildListTile(
                  context,
                  icon: Icons.help_outline,
                  title: l10n.help,
                  onTap: () {
                    // TODO: Show help
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Help section coming soon')),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavigationBar(currentIndex: 4),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Card(
      elevation: 2,
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildDropdownSetting(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: value,
              decoration: InputDecoration(
                labelText: label,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              items: items,
              onChanged: onChanged,
              isExpanded: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchSetting(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(label),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildSliderSetting(
    BuildContext context, {
    required IconData icon,
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Theme.of(context).primaryColor),
              const SizedBox(width: 16),
              Text(label),
              const Spacer(),
              Text(
                '${value.toStringAsFixed(1)}x',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            label: value.toStringAsFixed(1),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(title),
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildThemeDropdownSetting(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentThemeMode = _themeService.themeMode;

    String getThemeName(ThemeMode mode) {
      switch (mode) {
        case ThemeMode.light:
          return l10n.light;
        case ThemeMode.dark:
          return l10n.dark;
        case ThemeMode.system:
          return l10n.system;
      }
    }

    String getThemeIcon(ThemeMode mode) {
      switch (mode) {
        case ThemeMode.light:
          return '☀️';
        case ThemeMode.dark:
          return '🌙';
        case ThemeMode.system:
          return '🔄';
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(Icons.palette, color: Theme.of(context).primaryColor),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButtonFormField<ThemeMode>(
              value: currentThemeMode,
              decoration: InputDecoration(
                labelText: l10n.themeMode,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              items: _themeService.themeModeOptions
                  .map((option) => DropdownMenuItem<ThemeMode>(
                        value: option.mode,
                        child: Row(
                          children: [
                            Text(option.icon,
                                style: const TextStyle(fontSize: 20)),
                            const SizedBox(width: 8),
                            Text(option.name),
                          ],
                        ),
                      ))
                  .toList(),
              onChanged: (value) async {
                if (value != null) {
                  await _themeService.changeThemeMode(value);
                  ThemeNotifier().value = _themeService.themeMode;
                }
              },
              isExpanded: true,
            ),
          ),
        ],
      ),
    );
  }
}
