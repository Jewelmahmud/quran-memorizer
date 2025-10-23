import 'package:flutter/material.dart';
import 'package:quran_memorizer/core/widgets/app_drawer.dart';
import 'package:quran_memorizer/core/widgets/language_selector.dart';
import 'package:quran_memorizer/l10n/app_localizations.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings),
      ),
      drawer: const AppDrawer(),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LanguageSelector(),
            SizedBox(height: 24),
            // Add more settings sections here
          ],
        ),
      ),
    );
  }
}
