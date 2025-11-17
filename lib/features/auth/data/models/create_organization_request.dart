class CreateOrganizationRequest {
  final String tenantId;
  final String name;
  final String code;
  final String description;
  final SuperAdminCredentials superAdmin;
  final List<String> initialProjects;

  CreateOrganizationRequest({
    required this.tenantId,
    required this.name,
    required this.code,
    required this.description,
    required this.superAdmin,
    this.initialProjects = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'tenantId': tenantId, // camelCase as per backend spec
      'name': name,
      'code': code,
      'description': description,
      'super_admin': superAdmin.toJson(), // snake_case as per backend spec
      'initial_projects': initialProjects, // snake_case as per backend spec
    };
  }

  factory CreateOrganizationRequest.fromJson(Map<String, dynamic> json) {
    return CreateOrganizationRequest(
      tenantId: json['tenant_id'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      description: json['description'] ?? '',
      superAdmin: SuperAdminCredentials.fromJson(json['super_admin'] ?? {}),
      initialProjects: List<String>.from(json['initial_projects'] ?? []),
    );
  }
}

class SuperAdminCredentials {
  final String name;
  final String email;
  final String password;

  SuperAdminCredentials({
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

  factory SuperAdminCredentials.fromJson(Map<String, dynamic> json) {
    return SuperAdminCredentials(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
    );
  }
}
