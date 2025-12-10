class RuleLevel {
  final int level;
  final String approverName;
  final double amount;

  const RuleLevel({
    required this.level,
    required this.approverName,
    required this.amount,
  });

  factory RuleLevel.fromMap(Map<String, dynamic> map) => RuleLevel(
        level: map['level'] ?? 0,
        approverName: map['approver_name'] ?? '',
        amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      );
}

class ApprovalRule {
  final String id;
  final String ruleName;
  final String amountRange;
  final int approvers;
  final int levels;
  final String created;
  final String status;
  final String department;
  final String project;
  final List<RuleLevel> ruleLevels;

  ApprovalRule({
    required this.id,
    required this.ruleName,
    required this.amountRange,
    required this.approvers,
    required this.levels,
    required this.created,
    required this.status,
    required this.department,
    required this.project, 
    this.ruleLevels = const [],
  });

  factory ApprovalRule.fromMap(Map<String, dynamic> m) => ApprovalRule(
        id: m['id'].toString(),
        ruleName: m['rule_name'] ?? '',
        amountRange: m['amount_range'] ?? '',
        approvers: m['approvers'] ?? 0,
        levels: m['levels'] ?? 0,
        created: m['created'] ?? '',
        status: m['status'] ?? 'Inactive',
        department: m['department'] ?? '',
        project: m['project'] ?? '',
        ruleLevels: (m['rule_levels'] as List<dynamic>?)
                ?.map((e) => RuleLevel.fromMap(e as Map<String, dynamic>))
                .toList() ??
            const [],
      );
}
