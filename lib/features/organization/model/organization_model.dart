
class Organization {
  final int id;
  final String name;
  final String code;
  final String status;
  final String createdBy;
  final String createdDate;
  final String? description;
  final String? logoPath;

  Organization({
    required this.id,
    required this.name,
    required this.code,
    required this.status,
    required this.createdBy,
    required this.createdDate,
    this.description,
    this.logoPath,
  });

  Organization copyWith({
    int? id,
    String? name,
    String? code,
    String? status,
    String? createdBy,
    String? createdDate,
    String? description,
    String? logoPath,

  }) {
    return Organization(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
      createdDate: createdDate ?? this.createdDate,
      description: description ?? this.description,
      logoPath: logoPath ?? this.logoPath,

    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'status': status,
      'createdBy': createdBy,
      'createdDate': createdDate,
      'description': description,
      'logoPath': logoPath,
    };
  }

  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      status: json['status'],
      createdBy: json['createdBy'],
      createdDate: json['createdDate'],
      description: json['description'],
      logoPath: json['logoPath'],
    );
  }
}
