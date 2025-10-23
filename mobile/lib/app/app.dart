import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_memorizer/core/theme/app_theme.dart';
import 'package:quran_memorizer/core/routing/app_router.dart';
import 'package:quran_memorizer/core/di/injection.dart';

class QuranMemorizerApp extends StatelessWidget {
  const QuranMemorizerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Add BLoC providers here
      ],
      child: MaterialApp.router(
        title: 'Quran Memorizer',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: getIt<AppRouter>().router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
