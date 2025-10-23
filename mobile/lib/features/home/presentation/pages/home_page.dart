import 'package:flutter/material.dart';
import 'package:quran_memorizer/features/home/presentation/widgets/dashboard_widget.dart';
import 'package:quran_memorizer/features/home/presentation/widgets/quick_actions_widget.dart';
import 'package:quran_memorizer/features/home/presentation/widgets/recent_progress_widget.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quran Memorizer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings
            },
          ),
        ],
      ),
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
    );
  }
}
