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
  final String? createdBy; 


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
    this.createdBy,
  });

  factory OrganizationModel.fromJson(Map<String, dynamic> json) {
    // Enhanced debugging for API response data
    final hasSuperAdmin = json['superAdmin'] != null;
    final hasCreatedBy = json['createdBy'] != null && json['createdBy'].toString().trim().isNotEmpty;
    final orgName = json['name'] ?? 'Unknown';
    final tenantId = json['tenantId'] ?? 'Unknown';
    
    // Always log organization data for debugging
    print('🔍 [OrganizationModel] Processing org: $orgName');
    print('   TenantId: $tenantId');
    print('   SuperAdmin: ${hasSuperAdmin ? 'PRESENT' : 'NULL'} ${hasSuperAdmin ? '(${json['superAdmin']})' : ''}');
    print('   CreatedBy: ${hasCreatedBy ? 'PRESENT' : 'EMPTY/NULL'} ("${json['createdBy'] ?? 'null'}")');
    
    if (!hasSuperAdmin || !hasCreatedBy) {
      print('❌ [OrganizationModel] DATA ISSUE for $orgName:');
      print('   - SuperAdmin: ${hasSuperAdmin ? 'OK' : 'MISSING/NULL'}');
      print('   - CreatedBy: ${hasCreatedBy ? 'OK' : 'EMPTY/NULL'}');
      print('   - Raw JSON superAdmin: ${json['superAdmin']}');
      print('   - Raw JSON createdBy: "${json['createdBy']}"');
    } else {
      print('✅ [OrganizationModel] Complete data for $orgName');
    }

    List<String> _parseProjects(Map<String, dynamic> source) {
      final possibleKeys = ['initialProjects', 'projects', 'initial_projects'];
      for (final key in possibleKeys) {
        if (source[key] != null) {
          final value = source[key];
          if (value is List) {
            return value.map((e) => e.toString()).toList();
          }
        }
      }
      return <String>[];
    }

    final parsedProjects = _parseProjects(json);

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
      initialProjects: parsedProjects,
      status: json['status'] ?? 'activated',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      createdBy: json['createdBy']?.toString().trim(),
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

  /// Get display name for who created this organization with fallbacks
  String get createdByDisplay {
    // Priority order for fallback:
    // 1. createdBy field (if not null/empty)
    // 2. superAdmin name (if available)
    // 3. 'System' as final fallback
    
    if (createdBy != null && createdBy!.trim().isNotEmpty) {
      return createdBy!.trim();
    }
    
    if (superAdmin != null && superAdmin!.name.trim().isNotEmpty) {
      return superAdmin!.name.trim();
    }
    
    return 'System';
  }

  /// Get super admin display name with fallback
  String get superAdminDisplay {
    if (superAdmin != null && superAdmin!.name.trim().isNotEmpty) {
      return superAdmin!.name.trim();
    }
    return 'Not Available';
  }

  /// Get super admin email with fallback
  String get superAdminEmailDisplay {
    if (superAdmin != null && superAdmin!.email.trim().isNotEmpty) {
      return superAdmin!.email.trim();
    }
    return 'Not Available';
  }

  /// Check if this organization has complete admin data
  bool get hasCompleteAdminData {
    return superAdmin != null && 
           superAdmin!.name.trim().isNotEmpty && 
           superAdmin!.email.trim().isNotEmpty;
  }

  /// Check if createdBy data is missing
  bool get isMissingCreatedBy {
    return (createdBy == null || createdBy!.trim().isEmpty) && 
           (superAdmin == null || superAdmin!.name.trim().isEmpty);
  }
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
  final String? tenantId;
  final String? parentOrgId;
  final String name;
  final String code;
  final String description;
  final SuperAdminRequest superAdmin;
  final List<String> initialProjects;
  final String? createdBy;

  CreateOrganizationRequest({
    this.tenantId,
    this.parentOrgId,
    required this.name,
    required this.code,
    required this.description,
    required this.superAdmin,
    required this.initialProjects,
    this.createdBy,
  });

  Map<String, dynamic> toJson() {
    return {
      if (tenantId != null && tenantId!.isNotEmpty) 'tenantId': tenantId,
      if (parentOrgId != null && parentOrgId!.isNotEmpty) 'parentOrgId': parentOrgId,
      'name': name,
      'code': code,
      'description': description,
      'super_admin': superAdmin.toJson(),
      'initial_projects': initialProjects,
      if (createdBy != null && createdBy!.isNotEmpty) 'createdBy': createdBy,
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
      if (password.isNotEmpty) 'password': password,
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
