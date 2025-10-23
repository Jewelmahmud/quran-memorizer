import 'package:quran_memorizer/features/auth/domain/entities/auth_entities.dart';

abstract class AuthRepository {
  Future<AuthEntity> login(LoginRequest request);
  Future<AuthEntity> register(RegisterRequest request);
}
