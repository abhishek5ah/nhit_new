class CreateBankLetterRequest {
  final String letterType;
  final String createdById;
  final String bankName;
  final String branchName;
  final String bankAddress;
  final String subject;
  final String content;
  final List<String> attachments;
  final String? transferId;
  final String? paymentSlNo;
  final String saveAsStatus;

  CreateBankLetterRequest({
    required this.letterType,
    required this.createdById,
    required this.bankName,
    required this.branchName,
    required this.bankAddress,
    required this.subject,
    required this.content,
    required this.attachments,
    this.transferId,
    this.paymentSlNo,
    required this.saveAsStatus,
  });

  Map<String, dynamic> toJson() {
    return {
      'letter_type': letterType,
      'created_by_id': createdById,
      'bank_name': bankName,
      'branch_name': branchName,
      'bank_address': bankAddress,
      'subject': subject,
      'content': content,
      'attachments': attachments,
      if (transferId != null && transferId!.isNotEmpty) 'transfer_id': transferId,
      if (paymentSlNo != null && paymentSlNo!.isNotEmpty) 'payment_sl_no': paymentSlNo,
      'save_as_status': saveAsStatus,
    };
  }
}
