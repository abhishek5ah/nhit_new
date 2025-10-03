class Designation {
  final int id;
  final String name;
  final String description;

  Designation({
    required this.id,
    required this.name,
    required this.description,
  });

  Designation copyWith({
    String? name,
    String? description,
  }) {
    return Designation(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
    );
  }
}
