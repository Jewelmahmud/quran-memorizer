import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:quran_memorizer/core/theme/app_theme.dart';
import 'package:quran_memorizer/core/theme/theme_service.dart';
import 'package:quran_memorizer/core/routing/app_router.dart';
import 'package:quran_memorizer/core/di/injection.dart';
import 'package:quran_memorizer/core/localization/localization_service.dart';
import 'package:quran_memorizer/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:quran_memorizer/l10n/app_localizations.dart';

class QuranMemorizerApp extends StatefulWidget {
  const QuranMemorizerApp({super.key});

  @override
  State<QuranMemorizerApp> createState() => _QuranMemorizerAppState();
}

class _QuranMemorizerAppState extends State<QuranMemorizerApp> {
  @override
  void initState() {
    super.initState();
    // Set up a listener for locale changes from LocalizationService
    // This will trigger a rebuild when the locale changes
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => getIt<AuthBloc>(),
        ),
      ],
      child: ValueListenableBuilder<Locale>(
        valueListenable: LocaleNotifier(),
        builder: (context, currentLocale, _) {
          return ValueListenableBuilder<ThemeMode>(
            valueListenable: ThemeNotifier(),
            builder: (context, currentThemeMode, _) {
              return MaterialApp.router(
                title: 'Quran Memorizer',
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: currentThemeMode,
                routerConfig: getIt<AppRouter>().router,
                debugShowCheckedModeBanner: false,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: LocalizationService().supportedLocales,
                locale: currentLocale,
                builder: (context, child) {
                  final localizationService = LocalizationService();
                  return Directionality(
                    textDirection: localizationService.isCurrentLanguageRTL
                        ? TextDirection.rtl
                        : TextDirection.ltr,
                    child: child!,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

// Helper class to notify about locale changes
class LocaleNotifier extends ValueNotifier<Locale> {
  static final LocaleNotifier _instance = LocaleNotifier._internal();

  factory LocaleNotifier() => _instance;

  LocaleNotifier._internal() : super(LocalizationService().currentLocale) {
    // Listen to changes from LocalizationService
    LocalizationService().addListener(_onLocaleChanged);
  }

  void _onLocaleChanged() {
    value = LocalizationService().currentLocale;
  }

  @override
  void dispose() {
    LocalizationService().removeListener(_onLocaleChanged);
    super.dispose();
  }
}

// Helper class to notify about theme changes
class ThemeNotifier extends ValueNotifier<ThemeMode> {
  static final ThemeNotifier _instance = ThemeNotifier._internal();

  factory ThemeNotifier() => _instance;

  ThemeNotifier._internal() : super(ThemeService().themeMode) {
    // Listen to changes from ThemeService
    ThemeService().addListener(_onThemeChanged);
  }

  void _onThemeChanged() {
    value = ThemeService().themeMode;
  }

  @override
  void dispose() {
    ThemeService().removeListener(_onThemeChanged);
    super.dispose();
  }
}
