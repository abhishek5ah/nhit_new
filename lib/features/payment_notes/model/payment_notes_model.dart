class PaymentNote {
  final int sno;
  final String projectName;
  final String vendorName;
  final String invoiceValue;
  final String date;
  final String status;
  final String nextApprover;

  PaymentNote({
    required this.sno,
    required this.projectName,
    required this.vendorName,
    required this.invoiceValue,
    required this.date,
    required this.status,
    required this.nextApprover,
  });

  PaymentNote copyWith({
    String? projectName,
    String? vendorName,
    String? invoiceValue,
    String? date,
    String? status,
    String? nextApprover,
  }) {
    return PaymentNote(
      sno: sno,
      projectName: projectName ?? this.projectName,
      vendorName: vendorName ?? this.vendorName,
      invoiceValue: invoiceValue ?? this.invoiceValue,
      date: date ?? this.date,
      status: status ?? this.status,
      nextApprover: nextApprover ?? this.nextApprover,
    );
  }
}