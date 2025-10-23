import 'package:quran_memorizer/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:quran_memorizer/features/auth/data/models/auth_models.dart';
import 'package:quran_memorizer/features/auth/domain/entities/auth_entities.dart';
import 'package:quran_memorizer/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<AuthEntity> login(LoginRequest request) async {
    final response = await remoteDataSource.login(
      LoginRequestModel(
        email: request.email,
        password: request.password,
      ),
    );

    return AuthEntity(
      accessToken: response.accessToken,
      tokenType: response.tokenType,
    );
  }

  @override
  Future<AuthEntity> register(RegisterRequest request) async {
    final response = await remoteDataSource.register(
      RegisterRequestModel(
        username: request.username,
        email: request.email,
        password: request.password,
      ),
    );

    return AuthEntity(
      accessToken: response.accessToken,
      tokenType: response.tokenType,
    );
  }
}
