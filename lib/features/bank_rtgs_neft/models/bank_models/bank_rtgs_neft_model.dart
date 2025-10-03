// lib/features/bank/models/bank_rtgs_neft_model.dart

class BankRtgsNeft {
  final String id;
  final String slNo;
  final String vendorName;
  final String amount;
  final String date;
  final String status;

  BankRtgsNeft({
    required this.id,
    required this.slNo,
    required this.vendorName,
    required this.amount,
    required this.date,
    required this.status,
  });

  factory BankRtgsNeft.fromMap(Map<String, dynamic> m) => BankRtgsNeft(
    id: m['id'].toString(),
    slNo: m['sl_no'] ?? '',
    vendorName: m['vendor_name'] ?? '',
    amount: m['amount']?.toString() ?? '',
    date: m['date'] ?? '',
    status: m['status'] ?? '',
  );
}
