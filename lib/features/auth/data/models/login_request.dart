class LoginRequest {
  final String tenantId;
  final String login; // Email or username
  final String password;

  LoginRequest({
    required this.tenantId,
    required this.login,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'tenant_id': tenantId,
      'login': login,
      'password': password,
    };
  }

  factory LoginRequest.fromJson(Map<String, dynamic> json) {
    return LoginRequest(
      tenantId: json['tenant_id'] ?? '',
      login: json['login'] ?? '',
      password: json['password'] ?? '',
    );
  }
}
