class ReimbursementNote {
  final String id;            // Unique ID
  final String sNo;           // S. No.
  final String projectName;   // Project Name
  final String employeeName;  // Employee Name
  final String amount;        // Amount
  final String date;          // Date
  final String status;        // Status (Approved, Rejected, etc.)
  final String nextApprover;  // Optional - For "Sent for Approval"
  final String utrDate;       // Optional - For Paid
  final String utrNumber;     // Optional - For Paid

  ReimbursementNote({
    required this.id,
    required this.sNo,
    required this.projectName,
    required this.employeeName,
    required this.amount,
    required this.date,
    required this.status,
    this.nextApprover = '',
    this.utrDate = '',
    this.utrNumber = '',
  });

  /// Factory to create ReimbursementNote from Map
  factory ReimbursementNote.fromMap(Map<String, dynamic> m) => ReimbursementNote(
    id: m['id'].toString(),
    sNo: m['s_no']?.toString() ?? '',
    projectName: m['project_name'] ?? '',
    employeeName: m['employee_name'] ?? '',
    amount: m['amount']?.toString() ?? '',
    date: m['date'] ?? '',
    status: m['status'] ?? '',
    nextApprover: m['next_approver'] ?? '',
    utrDate: m['utr_date'] ?? '',
    utrNumber: m['utr_number'] ?? '',
  );
}
