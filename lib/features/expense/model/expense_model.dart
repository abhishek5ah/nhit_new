class GreenNote {
  final String sNo;            // S. No.
  final String projectName;    // Project Name
  final String vendorName;     // Vendor Name
  final String invoiceValue;   // Invoice Value
  final String date;           // Date in string format
  final String status;         // Status like "Sent for Approval"
  final String nextApprover;   // Next Approver Name

  GreenNote({
    required this.sNo,
    required this.projectName,
    required this.vendorName,
    required this.invoiceValue,
    required this.date,
    required this.status,
    required this.nextApprover,
  });

  /// Factory constructor to create model from Map
  factory GreenNote.fromMap(Map<String, dynamic> m) => GreenNote(
    sNo: m['s_no'].toString(),
    projectName: m['project_name'] ?? '',
    vendorName: m['vendor_name'] ?? '',
    invoiceValue: m['invoice_value'].toString(),
    date: m['date'] ?? '',
    status: m['status'] ?? '',
    nextApprover: m['next_approver'] ?? '',
  );

  /// Convert model to Map (for API or local storage)
  Map<String, dynamic> toMap() {
    return {
      's_no': sNo,
      'project_name': projectName,
      'vendor_name': vendorName,
      'invoice_value': invoiceValue,
      'date': date,
      'status': status,
      'next_approver': nextApprover,
    };
  }
}
