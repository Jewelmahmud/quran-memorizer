import 'package:flutter/material.dart';

class RecentProgressWidget extends StatelessWidget {
  const RecentProgressWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Progress',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            _buildProgressItem(
              'Al-Fatiha, Ayah 1',
              'Completed',
              Icons.check_circle,
              Colors.green,
              '2 hours ago',
            ),
            const Divider(),
            _buildProgressItem(
              'Al-Baqarah, Ayah 255',
              'Review',
              Icons.refresh,
              Colors.blue,
              'Yesterday',
            ),
            const Divider(),
            _buildProgressItem(
              'Al-Imran, Ayah 2',
              'Learning',
              Icons.play_circle,
              Colors.orange,
              '2 days ago',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressItem(
    String title,
    String status,
    IconData icon,
    Color color,
    String time,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  status,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
