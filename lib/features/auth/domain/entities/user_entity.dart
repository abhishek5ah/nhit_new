class UserEntity {
  final String id;
  final String email;
  final String name;
  final String? role;
  final bool emailVerified;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserEntity({
    required this.id,
    required this.email,
    required this.name,
    this.role,
    required this.emailVerified,
    this.createdAt,
    this.updatedAt,
  });

  UserEntity copyWith({
    String? id,
    String? email,
    String? name,
    String? role,
    bool? emailVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      emailVerified: emailVerified ?? this.emailVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserEntity &&
        other.id == id &&
        other.email == email &&
        other.name == name &&
        other.role == role &&
        other.emailVerified == emailVerified;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        email.hashCode ^
        name.hashCode ^
        role.hashCode ^
        emailVerified.hashCode;
  }
}
