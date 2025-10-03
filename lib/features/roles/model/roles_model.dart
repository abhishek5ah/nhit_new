
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
    String? roleName,
    List<String>? permissions,
  }) {
    return Role(
      id: id,
      roleName: roleName ?? this.roleName,
      permissions: permissions ?? this.permissions,
    );
  }
}