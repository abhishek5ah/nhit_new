class ResetPasswordRequest {
  final String token;
  final String password;
  final String confirmPassword;

  ResetPasswordRequest({
    required this.token,
    required this.password,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'password': password,
      'confirmPassword': confirmPassword,
    };
  }

  factory ResetPasswordRequest.fromJson(Map<String, dynamic> json) {
    return ResetPasswordRequest(
      token: json['token'] ?? '',
      password: json['password'] ?? '',
      confirmPassword: json['confirmPassword'] ?? '',
    );
  }
}
