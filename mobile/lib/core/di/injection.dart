import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:quran_memorizer/core/routing/app_router.dart';
import 'package:quran_memorizer/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:quran_memorizer/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:quran_memorizer/features/auth/domain/repositories/auth_repository.dart';
import 'package:quran_memorizer/features/auth/domain/usecases/login_usecase.dart';
import 'package:quran_memorizer/features/auth/domain/usecases/register_usecase.dart';
import 'package:quran_memorizer/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:quran_memorizer/features/recite/data/datasources/recite_remote_datasource.dart';
import 'package:quran_memorizer/features/recite/data/repositories/recite_repository_impl.dart';
import 'package:quran_memorizer/features/recite/domain/repositories/recite_repository.dart';
import 'package:quran_memorizer/features/recite/domain/usecases/analyze_recitation_usecase.dart';
import 'package:quran_memorizer/features/recite/presentation/bloc/recite_bloc.dart';

final getIt = GetIt.instance;

Future<void> init() async {
  // External
  getIt.registerLazySingleton<Dio>(() {
    final dio = Dio();
    dio.options.baseUrl = 'http://localhost:8000/api'; // Change for production
    dio.options.connectTimeout = const Duration(seconds: 5);
    dio.options.receiveTimeout = const Duration(seconds: 3);
    return dio;
  });

  // Core
  getIt.registerLazySingleton<AppRouter>(() => AppRouter());

  // Features - Auth
  // Data sources
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(getIt()),
  );

  // Repository
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt()),
  );

  // Use cases
  getIt.registerLazySingleton(() => LoginUseCase(getIt()));
  getIt.registerLazySingleton(() => RegisterUseCase(getIt()));

  // Bloc
  getIt.registerFactory(
    () => AuthBloc(
      loginUseCase: getIt(),
      registerUseCase: getIt(),
    ),
  );

  // Features - Recite
  // Data sources
  getIt.registerLazySingleton<ReciteRemoteDataSource>(
    () => ReciteRemoteDataSourceImpl(getIt()),
  );

  // Repository
  getIt.registerLazySingleton<ReciteRepository>(
    () => ReciteRepositoryImpl(getIt()),
  );

  // Use cases
  getIt.registerLazySingleton(() => AnalyzeRecitationUseCase(getIt()));

  // Bloc
  getIt.registerFactory(
    () => ReciteBloc(
      analyzeRecitationUseCase: getIt(),
    ),
  );

  // TODO: Add other features (verses, audio, learning, progress)
}
