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
    int? id,
    String? name,
    String? description,
  }) {
    return Designation(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }

  factory Designation.fromJson(Map<String, dynamic> json) {
    return Designation(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
    );
  }
}
