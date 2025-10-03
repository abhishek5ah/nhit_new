class BankLetterApprovalRule {
  final String id;
  final String approverLevel;
  final String users;
  final String paymentRange;

  BankLetterApprovalRule({
    required this.id,
    required this.approverLevel,
    required this.users,
    required this.paymentRange,
  });

  factory BankLetterApprovalRule.fromMap(Map<String, dynamic> m) =>
      BankLetterApprovalRule(
        id: m['id'].toString(),
        approverLevel: m['approver_level'] ?? '',
        users: m['users'] ?? '',
        paymentRange: m['payment_range'] ?? '',
      );
}
