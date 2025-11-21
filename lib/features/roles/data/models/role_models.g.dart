// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'role_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PermissionModelImpl _$$PermissionModelImplFromJson(
  Map<String, dynamic> json,
) => _$PermissionModelImpl(
  permissionId: json['permissionId'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  module: json['module'] as String,
  action: json['action'] as String,
  isSystemPermission: json['isSystemPermission'] as bool,
);

Map<String, dynamic> _$$PermissionModelImplToJson(
  _$PermissionModelImpl instance,
) => <String, dynamic>{
  'permissionId': instance.permissionId,
  'name': instance.name,
  'description': instance.description,
  'module': instance.module,
  'action': instance.action,
  'isSystemPermission': instance.isSystemPermission,
};

_$RoleModelImpl _$$RoleModelImplFromJson(Map<String, dynamic> json) =>
    _$RoleModelImpl(
      roleId: json['roleId'] as String?,
      name: json['name'] as String,
      permissions: (json['permissions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$RoleModelImplToJson(_$RoleModelImpl instance) =>
    <String, dynamic>{
      'roleId': instance.roleId,
      'name': instance.name,
      'permissions': instance.permissions,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
