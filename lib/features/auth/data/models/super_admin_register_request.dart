class SuperAdminRegisterRequest {
  final String name;
  final String email;
  final String password;

  SuperAdminRegisterRequest({
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

  factory SuperAdminRegisterRequest.fromJson(Map<String, dynamic> json) {
    return SuperAdminRegisterRequest(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
    );
  }
}
