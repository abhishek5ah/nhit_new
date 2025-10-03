class Approver {
  final String id;
  final String name;
  String role;

  Approver({required this.id, required this.name, required this.role});

  factory Approver.fromJson(Map<String, dynamic> json) => Approver(
    id: json['id'] as String,
    name: json['name'] as String,
    role: json['role'] as String,
  );

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'role': role};
}
