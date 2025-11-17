class TenantResponse {
  final String tenantId;
  final String name;
  final String email;
  final String password; // Empty string returned by backend for security

  TenantResponse({
    required this.tenantId,
    required this.name,
    required this.email,
    required this.password,
  });

  factory TenantResponse.fromJson(Map<String, dynamic> json) {
    return TenantResponse(
      tenantId: json['tenantId'] ?? '', // camelCase from backend
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '', // Will be empty string
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tenantId': tenantId,
      'name': name,
      'email': email,
      'password': password,
    };
  }
}
