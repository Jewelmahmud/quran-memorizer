import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_memorizer/app/app.dart';
import 'package:quran_memorizer/core/di/injection.dart' as di;
import 'package:quran_memorizer/core/localization/localization_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependency injection
  await di.init();

  // Initialize localization service
  await LocalizationService().initialize();

  runApp(const QuranMemorizerApp());
}
