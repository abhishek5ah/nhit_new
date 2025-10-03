class ApprovalRule {
  final String id;          // Name (S. No.)
  final String project;     // Project Name
  final String department;  // Department
  final List<String> steps; // List of Steps

  ApprovalRule({
    required this.id,
    required this.project,
    required this.department,
    required this.steps,
  });

  /// Factory to create from Map
  factory ApprovalRule.fromMap(Map<String, dynamic> m) => ApprovalRule(
    id: m['id'].toString(),
    project: m['project'] ?? '',
    department: m['department'] ?? '',
    steps: List<String>.from(m['steps'] ?? []),
  );

  /// Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'project': project,
      'department': department,
      'steps': steps,
    };
  }
}
