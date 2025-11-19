// Complete Organization API Models matching the exact backend spec

class OrganizationModel {
  final String orgId;
  final String tenantId;
  final String? parentOrgId;
  final String name;
  final String code;
  final String databaseName;
  final String description;
  final String logo;
  final SuperAdminInfo? superAdmin;
  final List<String> initialProjects;
  final String status; // "activated" or "deactivated"
  final DateTime createdAt;
  final DateTime updatedAt;

  OrganizationModel({
    required this.orgId,
    required this.tenantId,
    this.parentOrgId,
    required this.name,
    required this.code,
    required this.databaseName,
    required this.description,
    required this.logo,
    this.superAdmin,
    required this.initialProjects,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrganizationModel.fromJson(Map<String, dynamic> json) {
    return OrganizationModel(
      orgId: json['orgId'] ?? '',
      tenantId: json['tenantId'] ?? '',
      parentOrgId: json['parentOrgId'],
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      databaseName: json['databaseName'] ?? '',
      description: json['description'] ?? '',
      logo: json['logo'] ?? '',
      superAdmin: json['superAdmin'] != null 
          ? SuperAdminInfo.fromJson(json['superAdmin'])
          : null,
      initialProjects: json['initialProjects'] != null
          ? List<String>.from(json['initialProjects'])
          : [],
      status: json['status'] ?? 'activated',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orgId': orgId,
      'tenantId': tenantId,
      if (parentOrgId != null) 'parentOrgId': parentOrgId,
      'name': name,
      'code': code,
      'databaseName': databaseName,
      'description': description,
      'logo': logo,
      if (superAdmin != null) 'superAdmin': superAdmin!.toJson(),
      'initialProjects': initialProjects,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  bool get isActive => status.toLowerCase() == 'activated';
}

class SuperAdminInfo {
  final String name;
  final String email;
  final String password; // Empty string when returned from API

  SuperAdminInfo({
    required this.name,
    required this.email,
    required this.password,
  });

  factory SuperAdminInfo.fromJson(Map<String, dynamic> json) {
    return SuperAdminInfo(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      if (password.isNotEmpty) 'password': password,
    };
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
      organizations: (json['organizations'] as List? ?? [])
          .map((org) => OrganizationModel.fromJson(org))
          .toList(),
      totalCount: json['totalCount'] ?? 0,
      pagination: PaginationInfo.fromJson(json['pagination'] ?? {}),
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
      pageSize: json['pageSize'] ?? 20,
      totalItems: json['totalItems'] ?? 0,
      totalPages: json['totalPages'] ?? 1,
    );
  }
}

// Request models
class CreateOrganizationRequest {
  final String name;
  final String code;
  final String description;
  final SuperAdminRequest superAdmin;
  final List<String> initialProjects;

  CreateOrganizationRequest({
    required this.name,
    required this.code,
    required this.description,
    required this.superAdmin,
    required this.initialProjects,
  });

  Map<String, dynamic> toJson() {
    return {
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

class UpdateOrganizationRequest {
  final String orgId;
  final String name;
  final String code;
  final String description;
  final String logo;
  final String status;

  UpdateOrganizationRequest({
    required this.orgId,
    required this.name,
    required this.code,
    required this.description,
    required this.logo,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'orgId': orgId,
      'name': name,
      'code': code,
      'description': description,
      'logo': logo,
      'status': status,
    };
  }
}
