import 'package:flutter/material.dart';
import 'package:quran_memorizer/core/widgets/app_drawer.dart';
import 'package:quran_memorizer/core/widgets/bottom_navigation_bar.dart';
import 'package:quran_memorizer/l10n/app_localizations.dart';

class LearningPage extends StatelessWidget {
  const LearningPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.learning),
      ),
      drawer: const AppDrawer(),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.book,
              size: 64,
              color: Colors.green,
            ),
            SizedBox(height: 16),
            Text(
              'Learning Page',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Verse display, audio playback, and recording interface will be implemented here.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavigationBar(currentIndex: 2),
    );
  }
}
