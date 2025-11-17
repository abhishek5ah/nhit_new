class OrganizationResponse {
  final OrganizationData organization;
  final List<String> initialProjects;
  final String message;

  OrganizationResponse({
    required this.organization,
    required this.initialProjects,
    required this.message,
  });

  factory OrganizationResponse.fromJson(Map<String, dynamic> json) {
    return OrganizationResponse(
      organization: OrganizationData.fromJson(json['organization'] ?? {}),
      initialProjects: List<String>.from(json['initial_projects'] ?? []),
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'organization': organization.toJson(),
      'initial_projects': initialProjects,
      'message': message,
    };
  }
}

class OrganizationData {
  final String orgId;
  final String tenantId;
  final String name;
  final String code;
  final String databaseName;
  final String description;
  final String logo;
  final bool isActive;
  final String createdBy;
  final String createdAt;
  final String updatedAt;

  OrganizationData({
    required this.orgId,
    required this.tenantId,
    required this.name,
    required this.code,
    required this.databaseName,
    required this.description,
    required this.logo,
    required this.isActive,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrganizationData.fromJson(Map<String, dynamic> json) {
    return OrganizationData(
      orgId: json['orgId'] ?? '',
      tenantId: json['tenantId'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      databaseName: json['databaseName'] ?? '',
      description: json['description'] ?? '',
      logo: json['logo'] ?? '',
      isActive: json['isActive'] ?? false,
      createdBy: json['createdBy'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orgId': orgId,
      'tenantId': tenantId,
      'name': name,
      'code': code,
      'databaseName': databaseName,
      'description': description,
      'logo': logo,
      'isActive': isActive,
      'createdBy': createdBy,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
