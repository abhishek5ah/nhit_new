class AccountingDetail {
  final String account;
  final double taxAmount;
  final String costCenter;
  final String taxCode;
  final double netAmount;

  AccountingDetail({
    required this.account,
    required this.taxAmount,
    required this.costCenter,
    required this.taxCode,
    required this.netAmount,
  });
}
