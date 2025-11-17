class Role {
  final int id;
  final String roleName;
  final List<String> permissions;

  Role({
    required this.id,
    required this.roleName,
    required this.permissions,
  });

  Role copyWith({
    int? id,
    String? roleName,
    List<String>? permissions,
  }) {
    return Role(
      id: id ?? this.id,
      roleName: roleName ?? this.roleName,
      permissions: permissions ?? List<String>.from(this.permissions),
    );
  }
}
  