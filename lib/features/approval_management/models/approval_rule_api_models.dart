/// API Models for Approval Rule Backend Integration
/// Matches the protobuf definitions from backend

class CreateApprovalRuleRequest {
  final String ruleName;
  final String? description;
  final String? departmentId;
  final String? projectId;
  final double minAmount;
  final double maxAmount;
  final List<ApproverRequest> approvers;

  CreateApprovalRuleRequest({
    required this.ruleName,
    this.description,
    this.departmentId,
    this.projectId,
    required this.minAmount,
    required this.maxAmount,
    required this.approvers,
  });

  Map<String, dynamic> toJson() {
    return {
      'rule_name': ruleName,
      if (description != null && description!.isNotEmpty) 'description': description,
      if (departmentId != null && departmentId!.isNotEmpty) 'department_id': departmentId,
      if (projectId != null && projectId!.isNotEmpty) 'project_id': projectId,
      'min_amount': minAmount,
      'max_amount': maxAmount,
      'approvers': approvers.map((a) => a.toJson()).toList(),
    };
  }
}

class ApproverRequest {
  final String reviewerId;
  final int level;
  final double maxAmount;

  ApproverRequest({
    required this.reviewerId,
    required this.level,
    required this.maxAmount,
  });

  Map<String, dynamic> toJson() {
    return {
      'reviewer_id': reviewerId,
      'level': level,
      'max_amount': maxAmount,
    };
  }
}

class RuleResponse {
  final String id;
  final String ruleName;
  final String? description;
  final String? departmentId;
  final String? departmentName;
  final String? projectId;
  final String? projectName;
  final double minAmount;
  final double maxAmount;
  final DateTime? createdAt;
  final List<ApproverResponse> approvers;

  RuleResponse({
    required this.id,
    required this.ruleName,
    this.description,
    this.departmentId,
    this.departmentName,
    this.projectId,
    this.projectName,
    required this.minAmount,
    required this.maxAmount,
    this.createdAt,
    required this.approvers,
  });

  factory RuleResponse.fromJson(Map<String, dynamic> json) {
    return RuleResponse(
      id: json['id'] ?? '',
      ruleName: json['rule_name'] ?? '',
      description: json['description'],
      departmentId: json['department_id'],
      departmentName: json['department_name'],
      projectId: json['project_id'],
      projectName: json['project_name'],
      minAmount: (json['min_amount'] as num?)?.toDouble() ?? 0.0,
      maxAmount: (json['max_amount'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      approvers: (json['approvers'] as List<dynamic>?)
              ?.map((a) => ApproverResponse.fromJson(a))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rule_name': ruleName,
      if (description != null) 'description': description,
      if (departmentId != null) 'department_id': departmentId,
      if (departmentName != null) 'department_name': departmentName,
      if (projectId != null) 'project_id': projectId,
      if (projectName != null) 'project_name': projectName,
      'min_amount': minAmount,
      'max_amount': maxAmount,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      'approvers': approvers.map((a) => a.toJson()).toList(),
    };
  }
}

class ApproverResponse {
  final String id;
  final String reviewerId;
  final String reviewerName;
  final int level;
  final double maxAmount;

  ApproverResponse({
    required this.id,
    required this.reviewerId,
    required this.reviewerName,
    required this.level,
    required this.maxAmount,
  });

  factory ApproverResponse.fromJson(Map<String, dynamic> json) {
    return ApproverResponse(
      id: json['id'] ?? '',
      reviewerId: json['reviewer_id'] ?? '',
      reviewerName: json['reviewer_name'] ?? '',
      level: json['level'] ?? 0,
      maxAmount: (json['max_amount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reviewer_id': reviewerId,
      'reviewer_name': reviewerName,
      'level': level,
      'max_amount': maxAmount,
    };
  }
}
