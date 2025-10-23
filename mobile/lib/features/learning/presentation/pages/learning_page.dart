import 'package:flutter/material.dart';

class LearningPage extends StatelessWidget {
  const LearningPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning'),
      ),
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
    );
  }
}
