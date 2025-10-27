import 'package:flutter/material.dart';
import 'package:quran_memorizer/core/widgets/app_drawer.dart';
import 'package:quran_memorizer/core/widgets/bottom_navigation_bar.dart';
import 'package:quran_memorizer/l10n/app_localizations.dart';

class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.progress),
      ),
      drawer: const AppDrawer(),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics,
              size: 64,
              color: Colors.blue,
            ),
            SizedBox(height: 16),
            Text(
              'Progress Page',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Statistics, charts, and achievements will be displayed here.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavigationBar(currentIndex: 3),
    );
  }
}
