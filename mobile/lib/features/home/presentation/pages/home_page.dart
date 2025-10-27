import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_memorizer/core/widgets/app_drawer.dart';
import 'package:quran_memorizer/core/widgets/bottom_navigation_bar.dart';
import 'package:quran_memorizer/features/home/presentation/widgets/dashboard_widget.dart';
import 'package:quran_memorizer/features/home/presentation/widgets/quick_actions_widget.dart';
import 'package:quran_memorizer/features/home/presentation/widgets/recent_progress_widget.dart';
import 'package:quran_memorizer/l10n/app_localizations.dart';
import 'package:quran_memorizer/core/routing/app_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              context.go(AppRouter.settings);
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DashboardWidget(),
            SizedBox(height: 24),
            QuickActionsWidget(),
            SizedBox(height: 24),
            RecentProgressWidget(),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavigationBar(currentIndex: 0),
    );
  }
}
