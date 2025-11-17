class UserModel {
  final String id;
  final String email;
  final String name;
  final List<String> roles;
  final List<String> permissions;
  final bool emailVerified;
  final String? tenantId;
  final String? organizationId;
  final String? lastLoginAt;
  final String? lastLoginIp;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.roles = const [],
    this.permissions = const [],
    required this.emailVerified,
    this.tenantId,
    this.organizationId,
    this.lastLoginAt,
    this.lastLoginIp,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      roles: List<String>.from(json['roles'] ?? []),
      permissions: List<String>.from(json['permissions'] ?? []),
      emailVerified: json['emailVerified'] ?? false,
      tenantId: json['tenantId'],
      organizationId: json['organizationId'],
      lastLoginAt: json['lastLoginAt'],
      lastLoginIp: json['lastLoginIp'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'roles': roles,
      'permissions': permissions,
      'emailVerified': emailVerified,
      'tenantId': tenantId,
      'organizationId': organizationId,
      'lastLoginAt': lastLoginAt,
      'lastLoginIp': lastLoginIp,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    List<String>? roles,
    List<String>? permissions,
    bool? emailVerified,
    String? tenantId,
    String? organizationId,
    String? lastLoginAt,
    String? lastLoginIp,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      roles: roles ?? this.roles,
      permissions: permissions ?? this.permissions,
      emailVerified: emailVerified ?? this.emailVerified,
      tenantId: tenantId ?? this.tenantId,
      organizationId: organizationId ?? this.organizationId,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      lastLoginIp: lastLoginIp ?? this.lastLoginIp,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
