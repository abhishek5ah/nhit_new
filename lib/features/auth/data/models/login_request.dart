class LoginRequest {
  final String? tenantId; // Optional - backend supports global login
  final String login; // Email or username
  final String password;

  LoginRequest({
    this.tenantId, // Optional
    required this.login,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    final map = {
      'login': login,
      'password': password,
    };
    // Only include tenant_id if provided (for tenant-specific login)
    if (tenantId != null && tenantId!.isNotEmpty) {
      map['tenant_id'] = tenantId!;
    }
    return map;
  }

  factory LoginRequest.fromJson(Map<String, dynamic> json) {
    return LoginRequest(
      tenantId: json['tenant_id'] ?? '',
      login: json['login'] ?? '',
      password: json['password'] ?? '',
    );
  }
}
