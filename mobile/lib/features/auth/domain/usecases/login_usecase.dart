import 'package:quran_memorizer/features/auth/domain/entities/auth_entities.dart';
import 'package:quran_memorizer/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<AuthEntity> call(LoginRequest request) async {
    return await repository.login(request);
  }
}
