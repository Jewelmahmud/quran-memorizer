class LoginRequestModel {
  final String email;
  final String password;

  LoginRequestModel({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }

  factory LoginRequestModel.fromJson(Map<String, dynamic> json) {
    return LoginRequestModel(
      email: json['email'],
      password: json['password'],
    );
  }
}

class RegisterRequestModel {
  final String username;
  final String email;
  final String password;

  RegisterRequestModel({
    required this.username,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'password': password,
    };
  }

  factory RegisterRequestModel.fromJson(Map<String, dynamic> json) {
    return RegisterRequestModel(
      username: json['username'],
      email: json['email'],
      password: json['password'],
    );
  }
}

class AuthResponseModel {
  final String accessToken;
  final String tokenType;

  AuthResponseModel({
    required this.accessToken,
    required this.tokenType,
  });

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'token_type': tokenType,
    };
  }

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      accessToken: json['access_token'],
      tokenType: json['token_type'],
    );
  }
}
