class SuperAdminRequest {
  final String name;
  final String email;
  final String password;

  SuperAdminRequest({
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

  factory SuperAdminRequest.fromJson(Map<String, dynamic> json) {
    return SuperAdminRequest(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
    );
  }
}

class OrganizationRequest {
  final String tenantId;
  final String name;
  final String code;
  final String description;
  final SuperAdminRequest superAdmin;
  final List<String> initialProjects;

  OrganizationRequest({
    required this.tenantId,
    required this.name,
    required this.code,
    required this.description,
    required this.superAdmin,
    required this.initialProjects,
  });

  Map<String, dynamic> toJson() {
    return {
      'tenantId': tenantId,
      'name': name,
      'code': code,
      'description': description,
      'super_admin': superAdmin.toJson(),
      'initial_projects': initialProjects,
    };
  }

  factory OrganizationRequest.fromJson(Map<String, dynamic> json) {
    return OrganizationRequest(
      tenantId: json['tenantId'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      description: json['description'] ?? '',
      superAdmin: SuperAdminRequest.fromJson(json['super_admin'] ?? {}),
      initialProjects: List<String>.from(json['initial_projects'] ?? []),
    );
  }
}
