class User {
  final int id;
  final String name;
  final String username;
  final String email;
  final List<String> roles;
  final bool isActive;

  User({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.roles,
    required this.isActive,
  });

  User copyWith({
    String? name,
    String? email,
    required bool isActive,
    required String username,
    required List<String> roles,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      username: username,
      email: email ?? this.email,
      roles: List<String>.from(roles),
      isActive: isActive,
    );
  }
}
