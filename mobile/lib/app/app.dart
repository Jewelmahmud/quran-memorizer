import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:quran_memorizer/core/theme/app_theme.dart';
import 'package:quran_memorizer/core/routing/app_router.dart';
import 'package:quran_memorizer/core/di/injection.dart';
import 'package:quran_memorizer/core/localization/localization_service.dart';
import 'package:quran_memorizer/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:quran_memorizer/l10n/app_localizations.dart';

class QuranMemorizerApp extends StatelessWidget {
  const QuranMemorizerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => getIt<AuthBloc>(),
        ),
      ],
      child: MaterialApp.router(
        title: 'Quran Memorizer',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: getIt<AppRouter>().router,
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: LocalizationService().supportedLocales,
        locale: LocalizationService().currentLocale,
        builder: (context, child) {
          return Directionality(
            textDirection: LocalizationService().isCurrentLanguageRTL
                ? TextDirection.rtl
                : TextDirection.ltr,
            child: child!,
          );
        },
      ),
    );
  }
}
