import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_memorizer/core/routing/app_router.dart';
import 'package:quran_memorizer/l10n/app_localizations.dart';

class AppBottomNavigationBar extends StatelessWidget {
  final int currentIndex;

  const AppBottomNavigationBar({
    super.key,
    required this.currentIndex,
  });

  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location == AppRouter.home) return 0;
    if (location == AppRouter.recite) return 1;
    if (location == AppRouter.learning) return 2;
    if (location == AppRouter.progress) return 3;
    if (location == AppRouter.settings) return 4;
    return 0;
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(AppRouter.home);
        break;
      case 1:
        context.go(AppRouter.recite);
        break;
      case 2:
        context.go(AppRouter.learning);
        break;
      case 3:
        context.go(AppRouter.progress);
        break;
      case 4:
        context.go(AppRouter.settings);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentIndex = _getCurrentIndex(context);

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) => _onItemTapped(context, index),
      type: BottomNavigationBarType.fixed,
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home),
          label: l10n.home,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.mic),
          label: l10n.recite,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.book),
          label: l10n.learning,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.trending_up),
          label: l10n.progress,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.settings),
          label: l10n.settings,
        ),
      ],
    );
  }
}
