class DepartmentResponse {
  final List<Department> departments;
  final int totalCount;

  DepartmentResponse({
    required this.departments,
    required this.totalCount,
  });

  factory DepartmentResponse.fromJson(Map<String, dynamic> json) {
    return DepartmentResponse(
      departments: (json['departments'] as List<dynamic>?)
              ?.map((dept) => Department.fromJson(dept))
              .toList() ??
          [],
      totalCount: json['totalCount'] ?? json['total_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'departments': departments.map((dept) => dept.toJson()).toList(),
      'totalCount': totalCount,
    };
  }
}

class Department {
  final String id;
  final String name;

  Department({
    required this.id,
    required this.name,
  });

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
