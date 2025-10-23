import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_memorizer/core/routing/app_router.dart';
import 'package:quran_memorizer/core/widgets/language_selector.dart';
import 'package:quran_memorizer/l10n/app_localizations.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withOpacity(0.8),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  Icons.menu_book,
                  size: 48,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.appTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Memorize with AI',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  context: context,
                  icon: Icons.home,
                  title: AppLocalizations.of(context)!.home,
                  route: AppRouter.home,
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.school,
                  title: AppLocalizations.of(context)!.learning,
                  route: AppRouter.learning,
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.analytics,
                  title: AppLocalizations.of(context)!.progress,
                  route: AppRouter.progress,
                ),
                const Divider(),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.settings,
                  title: AppLocalizations.of(context)!.settings,
                  route: AppRouter.settings,
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.language,
                  title: AppLocalizations.of(context)!.language,
                  onTap: () => _showLanguageDialog(context),
                ),
                const Divider(),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.logout,
                  title: AppLocalizations.of(context)!.logout,
                  onTap: () => _showLogoutDialog(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? route,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.of(context).pop(); // Close drawer
        if (route != null) {
          context.go(route);
        } else if (onTap != null) {
          onTap();
        }
      },
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => LanguageSelectorDialog(),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.logout),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement logout logic
              context.go(AppRouter.login);
            },
            child: Text(AppLocalizations.of(context)!.logout),
          ),
        ],
      ),
    );
  }
}
