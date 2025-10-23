import 'package:flutter/material.dart';
import 'package:quran_memorizer/core/localization/localization_service.dart';
import 'package:quran_memorizer/l10n/app_localizations.dart';

class LanguageSelector extends StatelessWidget {
  final VoidCallback? onLanguageChanged;

  const LanguageSelector({
    super.key,
    this.onLanguageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final localizationService = LocalizationService();
    final currentLocale = localizationService.currentLocale;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.language,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: localizationService.languageOptions.map((language) {
              final isSelected = language.code == currentLocale.languageCode;

              return ListTile(
                leading: Text(
                  language.flag,
                  style: const TextStyle(fontSize: 24),
                ),
                title: Text(language.nativeName),
                subtitle: Text(language.name),
                trailing: isSelected
                    ? Icon(
                        Icons.check_circle,
                        color: Theme.of(context).primaryColor,
                      )
                    : null,
                onTap: () async {
                  if (!isSelected) {
                    await localizationService.changeLanguage(language.code);
                    if (onLanguageChanged != null) {
                      onLanguageChanged!();
                    }
                    // Restart the app to apply the new language
                    // This is a simple approach; in production, you might want to use
                    // a more sophisticated state management approach
                    Navigator.of(context).pushReplacementNamed('/');
                  }
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class LanguageSelectorDialog extends StatelessWidget {
  const LanguageSelectorDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final localizationService = LocalizationService();
    final currentLocale = localizationService.currentLocale;

    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.language),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: localizationService.languageOptions.map((language) {
            final isSelected = language.code == currentLocale.languageCode;

            return RadioListTile<String>(
              value: language.code,
              groupValue: currentLocale.languageCode,
              title: Text(language.nativeName),
              subtitle: Text(language.name),
              secondary: Text(
                language.flag,
                style: const TextStyle(fontSize: 24),
              ),
              onChanged: (value) async {
                if (value != null && value != currentLocale.languageCode) {
                  await localizationService.changeLanguage(value);
                  Navigator.of(context).pop();
                  // Restart the app to apply the new language
                  Navigator.of(context).pushReplacementNamed('/');
                }
              },
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
      ],
    );
  }
}
