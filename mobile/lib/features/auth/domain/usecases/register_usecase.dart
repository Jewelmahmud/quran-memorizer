import 'package:quran_memorizer/features/auth/domain/entities/auth_entities.dart';
import 'package:quran_memorizer/features/auth/domain/repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<AuthEntity> call(RegisterRequest request) async {
    return await repository.register(request);
  }
}
