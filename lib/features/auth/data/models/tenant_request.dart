class TenantRequest {
  final String name;
  final String email;
  final String password;

  TenantRequest({
    required this.name,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'password': password,
    };
  }

  factory TenantRequest.fromJson(Map<String, dynamic> json) {
    return TenantRequest(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
    );
  }
}
