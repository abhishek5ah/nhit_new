class Department {
  final int id;
  final String name;
  final String description;

  Department({
    required this.id,
    required this.name,
    required this.description,
  });

  Department copyWith({
    String? name,
    String? description,
  }) {
    return Department(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
    );
  }
}
