class LoginRequest {
  final String email;
  final String password;

  LoginRequest({
    required this.email,
    required this.password,
  });
}

class RegisterRequest {
  final String username;
  final String email;
  final String password;

  RegisterRequest({
    required this.username,
    required this.email,
    required this.password,
  });
}

class AuthEntity {
  final String accessToken;
  final String tokenType;

  AuthEntity({
    required this.accessToken,
    required this.tokenType,
  });
}
