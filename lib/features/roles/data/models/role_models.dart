/// Role and Permission data models for API integration
/// Matches backend API structure exactly

import 'package:freezed_annotation/freezed_annotation.dart';

part 'role_models.freezed.dart';
part 'role_models.g.dart';

@freezed
class PermissionModel with _$PermissionModel {
  const factory PermissionModel({
    required String permissionId,
    required String name,
    required String description,
    required String module,
    required String action,
    required bool isSystemPermission,
  }) = _PermissionModel;

  factory PermissionModel.fromJson(Map<String, dynamic> json) =>
      _$PermissionModelFromJson(json);
}

@freezed
class RoleModel with _$RoleModel {
  const factory RoleModel({
    String? roleId,
    required String name,
    required List<String> permissions, // List of permission names
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _RoleModel;

  factory RoleModel.fromJson(Map<String, dynamic> json) =>
      _$RoleModelFromJson(json);
}

// Request models
class CreateRoleRequest {
  final String name;
  final List<String> permissions;

  CreateRoleRequest({
    required this.name,
    required this.permissions,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'permissions': permissions,
    };
  }
}

class UpdateRoleRequest {
  final String name;
  final List<String> permissions;

  UpdateRoleRequest({
    required this.name,
    required this.permissions,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'permissions': permissions,
    };
  }
}

// Response models
class PermissionsResponse {
  final List<PermissionModel> permissions;

  PermissionsResponse({
    required this.permissions,
  });

  factory PermissionsResponse.fromJson(Map<String, dynamic> json) {
    return PermissionsResponse(
      permissions: (json['permissions'] as List<dynamic>?)
              ?.map((e) => PermissionModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class RolesListResponse {
  final List<RoleModel> roles;
  final int? totalCount;

  RolesListResponse({
    required this.roles,
    this.totalCount,
  });

  factory RolesListResponse.fromJson(dynamic json) {
    // Handle both array response and object with roles array
    if (json is List) {
      return RolesListResponse(
        roles: json
            .map((e) => RoleModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        totalCount: json.length,
      );
    } else if (json is Map<String, dynamic>) {
      return RolesListResponse(
        roles: (json['roles'] as List<dynamic>?)
                ?.map((e) => RoleModel.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        totalCount: json['totalCount'],
      );
    } else {
      return RolesListResponse(roles: [], totalCount: 0);
    }
  }
}

class RoleResponse {
  final RoleModel role;
  final String? message;

  RoleResponse({
    required this.role,
    this.message,
  });

  factory RoleResponse.fromJson(Map<String, dynamic> json) {
    return RoleResponse(
      role: RoleModel.fromJson(json['role'] ?? json),
      message: json['message'],
    );
  }
}
