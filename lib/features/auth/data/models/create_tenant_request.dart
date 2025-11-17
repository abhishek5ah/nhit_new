class CreateTenantRequest {
  final String name;
  final String email;
  final String password;

  CreateTenantRequest({
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

  factory CreateTenantRequest.fromJson(Map<String, dynamic> json) {
    return CreateTenantRequest(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
    );
  }
}
