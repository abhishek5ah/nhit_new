// ============================================================================
// USER API MODELS
// Complete data models for User Management API
// Base URL: http://192.168.1.51:8083/api/v1
// ============================================================================

/// User API Model - Main user entity from backend
class UserApiModel {
  final String userId;
  final String name;
  final String email;
  final List<String> roles;
  final List<String> permissions;
  final String? departmentId;
  final String? departmentName;
  final String? designationId;
  final String? designationName;
  final List<String>? projectIds;
  final String? signatureUrl;
  final String? accountHolderName;
  final String? bankName;
  final String? bankAccountNumber;
  final String? ifscCode;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserApiModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.roles,
    required this.permissions,
    this.departmentId,
    this.departmentName,
    this.designationId,
    this.designationName,
    this.projectIds,
    this.signatureUrl,
    this.accountHolderName,
    this.bankName,
    this.bankAccountNumber,
    this.ifscCode,
    this.createdAt,
    this.updatedAt,
  });

  factory UserApiModel.fromJson(Map<String, dynamic> json) {
    return UserApiModel(
      userId: json['user_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      roles: (json['roles'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      permissions: (json['permissions'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      departmentId: json['department_id'],
      departmentName: json['department_name'],
      designationId: json['designation_id'],
      designationName: json['designation_name'],
      projectIds: (json['project_ids'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      signatureUrl: json['signature_url'],
      accountHolderName: json['account_holder_name'],
      bankName: json['bank_name'],
      bankAccountNumber: json['bank_account_number'],
      ifscCode: json['ifsc_code'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'email': email,
      'roles': roles,
      'permissions': permissions,
      if (departmentId != null) 'department_id': departmentId,
      if (departmentName != null) 'department_name': departmentName,
      if (designationId != null) 'designation_id': designationId,
      if (designationName != null) 'designation_name': designationName,
      if (projectIds != null) 'project_ids': projectIds,
      if (signatureUrl != null) 'signature_url': signatureUrl,
      if (accountHolderName != null) 'account_holder_name': accountHolderName,
      if (bankName != null) 'bank_name': bankName,
      if (bankAccountNumber != null) 'bank_account_number': bankAccountNumber,
      if (ifscCode != null) 'ifsc_code': ifscCode,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }
}

/// Create User Request
class CreateUserRequest {
  final String tenantId;
  final String orgId;
  final String email;
  final String name;
  final String password;
  final String roleId;
  final String? departmentId;
  final String? designationId;
  final List<String>? projectIds;
  final String createdBy;
  final String? accountHolderName;
  final String? bankName;
  final String? bankAccountNumber;
  final String? ifscCode;

  CreateUserRequest({
    required this.tenantId,
    required this.orgId,
    required this.email,
    required this.name,
    required this.password,
    required this.roleId,
    this.departmentId,
    this.designationId,
    this.projectIds,
    required this.createdBy,
    this.accountHolderName,
    this.bankName,
    this.bankAccountNumber,
    this.ifscCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'tenant_id': tenantId,
      'org_id': orgId,
      'email': email,
      'name': name,
      'password': password,
      'role_id': roleId,
      if (departmentId != null && departmentId!.isNotEmpty) 'department_id': departmentId,
      if (designationId != null && designationId!.isNotEmpty) 'designation_id': designationId,
      if (projectIds != null && projectIds!.isNotEmpty) 'project_ids': projectIds,
      'created_by': createdBy,
      if (accountHolderName != null && accountHolderName!.isNotEmpty) 'account_holder_name': accountHolderName,
      if (bankName != null && bankName!.isNotEmpty) 'bank_name': bankName,
      if (bankAccountNumber != null && bankAccountNumber!.isNotEmpty) 'bank_account_number': bankAccountNumber,
      if (ifscCode != null && ifscCode!.isNotEmpty) 'ifsc_code': ifscCode,
    };
  }
}

/// Update User Request
class UpdateUserRequest {
  final String userId;
  final String? name;
  final String? email;
  final String? password;
  final List<String>? roles;

  UpdateUserRequest({
    required this.userId,
    this.name,
    this.email,
    this.password,
    this.roles,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      if (name != null && name!.isNotEmpty) 'name': name,
      if (email != null && email!.isNotEmpty) 'email': email,
      if (password != null && password!.isNotEmpty) 'password': password,
      if (roles != null && roles!.isNotEmpty) 'roles': roles,
    };
  }
}

/// Upload Signature Request
class UploadSignatureRequest {
  final String userId;
  final String filename;
  final String signatureFile; // base64 encoded

  UploadSignatureRequest({
    required this.userId,
    required this.filename,
    required this.signatureFile,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'filename': filename,
      'signature_file': signatureFile,
    };
  }
}

/// Add User to Organization Request
class AddUserToOrgRequest {
  final String userId;
  final String orgId;
  final String roleId;
  final String? departmentId;
  final String? designationId;
  final List<String>? projectIds;
  final String addedBy;

  AddUserToOrgRequest({
    required this.userId,
    required this.orgId,
    required this.roleId,
    this.departmentId,
    this.designationId,
    this.projectIds,
    required this.addedBy,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'org_id': orgId,
      'role_id': roleId,
      if (departmentId != null && departmentId!.isNotEmpty) 'department_id': departmentId,
      if (designationId != null && designationId!.isNotEmpty) 'designation_id': designationId,
      if (projectIds != null && projectIds!.isNotEmpty) 'project_ids': projectIds,
      'added_by': addedBy,
    };
  }
}

/// User Organization Model
class UserOrganization {
  final String orgId;
  final String orgName;
  final String roleName;
  final bool isCurrentContext;
  final DateTime? joinedAt;

  UserOrganization({
    required this.orgId,
    required this.orgName,
    required this.roleName,
    required this.isCurrentContext,
    this.joinedAt,
  });

  factory UserOrganization.fromJson(Map<String, dynamic> json) {
    return UserOrganization(
      orgId: json['org_id'] ?? '',
      orgName: json['org_name'] ?? '',
      roleName: json['role_name'] ?? '',
      isCurrentContext: json['is_current_context'] ?? false,
      joinedAt: json['joined_at'] != null ? DateTime.parse(json['joined_at']) : null,
    );
  }
}

/// Dropdown Models
class DropdownItem {
  final String id;
  final String name;

  DropdownItem({
    required this.id,
    required this.name,
  });

  factory DropdownItem.fromJson(Map<String, dynamic> json) {
    return DropdownItem(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

/// Pagination Model
class UserPagination {
  final int page;
  final int pageSize;
  final int totalPages;
  final int totalItems;

  UserPagination({
    required this.page,
    required this.pageSize,
    required this.totalPages,
    required this.totalItems,
  });

  factory UserPagination.fromJson(Map<String, dynamic> json) {
    return UserPagination(
      page: json['page'] ?? 1,
      pageSize: json['page_size'] ?? 10,
      totalPages: json['total_pages'] ?? 1,
      totalItems: json['total_items'] ?? 0,
    );
  }
}

// ============================================================================
// RESPONSE MODELS
// ============================================================================

/// Users List Response
class UsersListResponse {
  final List<UserApiModel> users;
  final UserPagination pagination;

  UsersListResponse({
    required this.users,
    required this.pagination,
  });

  factory UsersListResponse.fromJson(Map<String, dynamic> json) {
    return UsersListResponse(
      users: (json['users'] as List<dynamic>?)
              ?.map((e) => UserApiModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      pagination: UserPagination.fromJson(json['pagination'] ?? {}),
    );
  }
}

/// User Response (single user)
class UserResponse {
  final UserApiModel user;

  UserResponse({required this.user});

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      user: UserApiModel.fromJson(json),
    );
  }
}

/// Signature Upload Response
class SignatureUploadResponse {
  final String message;
  final String fileUrl;

  SignatureUploadResponse({
    required this.message,
    required this.fileUrl,
  });

  factory SignatureUploadResponse.fromJson(Map<String, dynamic> json) {
    return SignatureUploadResponse(
      message: json['message'] ?? '',
      fileUrl: json['file_url'] ?? '',
    );
  }
}

/// User Organizations Response
class UserOrganizationsResponse {
  final List<UserOrganization> organizations;

  UserOrganizationsResponse({required this.organizations});

  factory UserOrganizationsResponse.fromJson(Map<String, dynamic> json) {
    return UserOrganizationsResponse(
      organizations: (json['organizations'] as List<dynamic>?)
              ?.map((e) => UserOrganization.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// Dropdown Responses
class DepartmentsDropdownResponse {
  final List<DropdownItem> departments;

  DepartmentsDropdownResponse({required this.departments});

  factory DepartmentsDropdownResponse.fromJson(Map<String, dynamic> json) {
    return DepartmentsDropdownResponse(
      departments: (json['departments'] as List<dynamic>?)
              ?.map((e) => DropdownItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class DesignationsDropdownResponse {
  final List<DropdownItem> designations;

  DesignationsDropdownResponse({required this.designations});

  factory DesignationsDropdownResponse.fromJson(Map<String, dynamic> json) {
    return DesignationsDropdownResponse(
      designations: (json['designations'] as List<dynamic>?)
              ?.map((e) => DropdownItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class RolesDropdownResponse {
  final List<DropdownItem> roles;

  RolesDropdownResponse({required this.roles});

  factory RolesDropdownResponse.fromJson(Map<String, dynamic> json) {
    return RolesDropdownResponse(
      roles: (json['roles'] as List<dynamic>?)
              ?.map((e) => DropdownItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
