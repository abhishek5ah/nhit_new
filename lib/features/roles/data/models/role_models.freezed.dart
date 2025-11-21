// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'role_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PermissionModel _$PermissionModelFromJson(Map<String, dynamic> json) {
  return _PermissionModel.fromJson(json);
}

/// @nodoc
mixin _$PermissionModel {
  String get permissionId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get module => throw _privateConstructorUsedError;
  String get action => throw _privateConstructorUsedError;
  bool get isSystemPermission => throw _privateConstructorUsedError;

  /// Serializes this PermissionModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PermissionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PermissionModelCopyWith<PermissionModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PermissionModelCopyWith<$Res> {
  factory $PermissionModelCopyWith(
    PermissionModel value,
    $Res Function(PermissionModel) then,
  ) = _$PermissionModelCopyWithImpl<$Res, PermissionModel>;
  @useResult
  $Res call({
    String permissionId,
    String name,
    String description,
    String module,
    String action,
    bool isSystemPermission,
  });
}

/// @nodoc
class _$PermissionModelCopyWithImpl<$Res, $Val extends PermissionModel>
    implements $PermissionModelCopyWith<$Res> {
  _$PermissionModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PermissionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? permissionId = null,
    Object? name = null,
    Object? description = null,
    Object? module = null,
    Object? action = null,
    Object? isSystemPermission = null,
  }) {
    return _then(
      _value.copyWith(
            permissionId: null == permissionId
                ? _value.permissionId
                : permissionId // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            module: null == module
                ? _value.module
                : module // ignore: cast_nullable_to_non_nullable
                      as String,
            action: null == action
                ? _value.action
                : action // ignore: cast_nullable_to_non_nullable
                      as String,
            isSystemPermission: null == isSystemPermission
                ? _value.isSystemPermission
                : isSystemPermission // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PermissionModelImplCopyWith<$Res>
    implements $PermissionModelCopyWith<$Res> {
  factory _$$PermissionModelImplCopyWith(
    _$PermissionModelImpl value,
    $Res Function(_$PermissionModelImpl) then,
  ) = __$$PermissionModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String permissionId,
    String name,
    String description,
    String module,
    String action,
    bool isSystemPermission,
  });
}

/// @nodoc
class __$$PermissionModelImplCopyWithImpl<$Res>
    extends _$PermissionModelCopyWithImpl<$Res, _$PermissionModelImpl>
    implements _$$PermissionModelImplCopyWith<$Res> {
  __$$PermissionModelImplCopyWithImpl(
    _$PermissionModelImpl _value,
    $Res Function(_$PermissionModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PermissionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? permissionId = null,
    Object? name = null,
    Object? description = null,
    Object? module = null,
    Object? action = null,
    Object? isSystemPermission = null,
  }) {
    return _then(
      _$PermissionModelImpl(
        permissionId: null == permissionId
            ? _value.permissionId
            : permissionId // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        module: null == module
            ? _value.module
            : module // ignore: cast_nullable_to_non_nullable
                  as String,
        action: null == action
            ? _value.action
            : action // ignore: cast_nullable_to_non_nullable
                  as String,
        isSystemPermission: null == isSystemPermission
            ? _value.isSystemPermission
            : isSystemPermission // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PermissionModelImpl implements _PermissionModel {
  const _$PermissionModelImpl({
    required this.permissionId,
    required this.name,
    required this.description,
    required this.module,
    required this.action,
    required this.isSystemPermission,
  });

  factory _$PermissionModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$PermissionModelImplFromJson(json);

  @override
  final String permissionId;
  @override
  final String name;
  @override
  final String description;
  @override
  final String module;
  @override
  final String action;
  @override
  final bool isSystemPermission;

  @override
  String toString() {
    return 'PermissionModel(permissionId: $permissionId, name: $name, description: $description, module: $module, action: $action, isSystemPermission: $isSystemPermission)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PermissionModelImpl &&
            (identical(other.permissionId, permissionId) ||
                other.permissionId == permissionId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.module, module) || other.module == module) &&
            (identical(other.action, action) || other.action == action) &&
            (identical(other.isSystemPermission, isSystemPermission) ||
                other.isSystemPermission == isSystemPermission));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    permissionId,
    name,
    description,
    module,
    action,
    isSystemPermission,
  );

  /// Create a copy of PermissionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PermissionModelImplCopyWith<_$PermissionModelImpl> get copyWith =>
      __$$PermissionModelImplCopyWithImpl<_$PermissionModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PermissionModelImplToJson(this);
  }
}

abstract class _PermissionModel implements PermissionModel {
  const factory _PermissionModel({
    required final String permissionId,
    required final String name,
    required final String description,
    required final String module,
    required final String action,
    required final bool isSystemPermission,
  }) = _$PermissionModelImpl;

  factory _PermissionModel.fromJson(Map<String, dynamic> json) =
      _$PermissionModelImpl.fromJson;

  @override
  String get permissionId;
  @override
  String get name;
  @override
  String get description;
  @override
  String get module;
  @override
  String get action;
  @override
  bool get isSystemPermission;

  /// Create a copy of PermissionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PermissionModelImplCopyWith<_$PermissionModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RoleModel _$RoleModelFromJson(Map<String, dynamic> json) {
  return _RoleModel.fromJson(json);
}

/// @nodoc
mixin _$RoleModel {
  String? get roleId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  List<String> get permissions =>
      throw _privateConstructorUsedError; // List of permission names
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this RoleModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RoleModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RoleModelCopyWith<RoleModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RoleModelCopyWith<$Res> {
  factory $RoleModelCopyWith(RoleModel value, $Res Function(RoleModel) then) =
      _$RoleModelCopyWithImpl<$Res, RoleModel>;
  @useResult
  $Res call({
    String? roleId,
    String name,
    List<String> permissions,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class _$RoleModelCopyWithImpl<$Res, $Val extends RoleModel>
    implements $RoleModelCopyWith<$Res> {
  _$RoleModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RoleModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? roleId = freezed,
    Object? name = null,
    Object? permissions = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            roleId: freezed == roleId
                ? _value.roleId
                : roleId // ignore: cast_nullable_to_non_nullable
                      as String?,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            permissions: null == permissions
                ? _value.permissions
                : permissions // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RoleModelImplCopyWith<$Res>
    implements $RoleModelCopyWith<$Res> {
  factory _$$RoleModelImplCopyWith(
    _$RoleModelImpl value,
    $Res Function(_$RoleModelImpl) then,
  ) = __$$RoleModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? roleId,
    String name,
    List<String> permissions,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class __$$RoleModelImplCopyWithImpl<$Res>
    extends _$RoleModelCopyWithImpl<$Res, _$RoleModelImpl>
    implements _$$RoleModelImplCopyWith<$Res> {
  __$$RoleModelImplCopyWithImpl(
    _$RoleModelImpl _value,
    $Res Function(_$RoleModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RoleModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? roleId = freezed,
    Object? name = null,
    Object? permissions = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$RoleModelImpl(
        roleId: freezed == roleId
            ? _value.roleId
            : roleId // ignore: cast_nullable_to_non_nullable
                  as String?,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        permissions: null == permissions
            ? _value._permissions
            : permissions // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RoleModelImpl implements _RoleModel {
  const _$RoleModelImpl({
    this.roleId,
    required this.name,
    required final List<String> permissions,
    this.createdAt,
    this.updatedAt,
  }) : _permissions = permissions;

  factory _$RoleModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$RoleModelImplFromJson(json);

  @override
  final String? roleId;
  @override
  final String name;
  final List<String> _permissions;
  @override
  List<String> get permissions {
    if (_permissions is EqualUnmodifiableListView) return _permissions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_permissions);
  }

  // List of permission names
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'RoleModel(roleId: $roleId, name: $name, permissions: $permissions, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RoleModelImpl &&
            (identical(other.roleId, roleId) || other.roleId == roleId) &&
            (identical(other.name, name) || other.name == name) &&
            const DeepCollectionEquality().equals(
              other._permissions,
              _permissions,
            ) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    roleId,
    name,
    const DeepCollectionEquality().hash(_permissions),
    createdAt,
    updatedAt,
  );

  /// Create a copy of RoleModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RoleModelImplCopyWith<_$RoleModelImpl> get copyWith =>
      __$$RoleModelImplCopyWithImpl<_$RoleModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RoleModelImplToJson(this);
  }
}

abstract class _RoleModel implements RoleModel {
  const factory _RoleModel({
    final String? roleId,
    required final String name,
    required final List<String> permissions,
    final DateTime? createdAt,
    final DateTime? updatedAt,
  }) = _$RoleModelImpl;

  factory _RoleModel.fromJson(Map<String, dynamic> json) =
      _$RoleModelImpl.fromJson;

  @override
  String? get roleId;
  @override
  String get name;
  @override
  List<String> get permissions; // List of permission names
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of RoleModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RoleModelImplCopyWith<_$RoleModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
