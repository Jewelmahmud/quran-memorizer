import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:quran_memorizer/features/auth/domain/entities/auth_entities.dart';
import 'package:quran_memorizer/features/auth/domain/usecases/login_usecase.dart';
import 'package:quran_memorizer/features/auth/domain/usecases/register_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
  }) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final authEntity = await loginUseCase(
        LoginRequest(
          email: event.email,
          password: event.password,
        ),
      );

      emit(AuthSuccess(authEntity));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final authEntity = await registerUseCase(
        RegisterRequest(
          username: event.username,
          email: event.email,
          password: event.password,
        ),
      );

      emit(AuthSuccess(authEntity));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }
}
