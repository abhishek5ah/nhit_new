class OrganizationModel {
  final String orgId;
  final String tenantId;
  final String name;
  final String code;
  final String databaseName;
  final String description;
  final String logo;
  final bool isActive;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String>? initialProjects;

  OrganizationModel({
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
    this.initialProjects,
  });

  factory OrganizationModel.fromJson(Map<String, dynamic> json) {
    return OrganizationModel(
      orgId: json['orgId'] ?? '',
      tenantId: json['tenantId'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      databaseName: json['databaseName'] ?? '',
      description: json['description'] ?? '',
      logo: json['logo'] ?? '',
      isActive: json['isActive'] ?? false,
      createdBy: json['createdBy'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      initialProjects: json['initial_projects'] != null 
          ? List<String>.from(json['initial_projects']) 
          : null,
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
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      if (initialProjects != null) 'initial_projects': initialProjects,
    };
  }

  OrganizationModel copyWith({
    String? orgId,
    String? tenantId,
    String? name,
    String? code,
    String? databaseName,
    String? description,
    String? logo,
    bool? isActive,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? initialProjects,
  }) {
    return OrganizationModel(
      orgId: orgId ?? this.orgId,
      tenantId: tenantId ?? this.tenantId,
      name: name ?? this.name,
      code: code ?? this.code,
      databaseName: databaseName ?? this.databaseName,
      description: description ?? this.description,
      logo: logo ?? this.logo,
      isActive: isActive ?? this.isActive,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      initialProjects: initialProjects ?? this.initialProjects,
    );
  }
}

class OrganizationsListResponse {
  final List<OrganizationModel> organizations;
  final int totalCount;
  final PaginationInfo pagination;

  OrganizationsListResponse({
    required this.organizations,
    required this.totalCount,
    required this.pagination,
  });

  factory OrganizationsListResponse.fromJson(Map<String, dynamic> json) {
    return OrganizationsListResponse(
      organizations: (json['organizations'] as List)
          .map((org) => OrganizationModel.fromJson(org))
          .toList(),
      totalCount: json['totalCount'] ?? 0,
      pagination: PaginationInfo.fromJson(json['pagination']),
    );
  }
}

class PaginationInfo {
  final int currentPage;
  final int pageSize;
  final int totalItems;
  final int totalPages;

  PaginationInfo({
    required this.currentPage,
    required this.pageSize,
    required this.totalItems,
    required this.totalPages,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      currentPage: json['currentPage'] ?? 1,
      pageSize: json['pageSize'] ?? 10,
      totalItems: json['totalItems'] ?? 0,
      totalPages: json['totalPages'] ?? 1,
    );
  }
}

class UpdateOrganizationRequest {
  final String tenantId;
  final String name;
  final String code;
  final String description;
  final SuperAdminRequest superAdmin;
  final List<String> initialProjects;

  UpdateOrganizationRequest({
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
}

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
}
