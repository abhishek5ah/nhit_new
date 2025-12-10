class BankLetterFormData {
  final String letterType;
  final String bankName;
  final String branchName;
  final String bankAddress;
  final String accountNumber;
  final String accountHolderName;
  final String ifscCode;
  final String subject;
  final String content;
  final String requestedBy;
  final String designation;
  final DateTime date;

  BankLetterFormData({
    required this.letterType,
    required this.bankName,
    required this.branchName,
    required this.bankAddress,
    required this.accountNumber,
    required this.accountHolderName,
    required this.ifscCode,
    required this.subject,
    required this.content,
    required this.requestedBy,
    required this.designation,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'letter_type': letterType,
      'bank_name': bankName,
      'branch_name': branchName,
      'bank_address': bankAddress,
      'account_number': accountNumber,
      'account_holder_name': accountHolderName,
      'ifsc_code': ifscCode,
      'subject': subject,
      'content': content,
      'requested_by': requestedBy,
      'designation': designation,
      'date': date.toIso8601String(),
    };
  }

  BankLetterFormData copyWith({
    String? letterType,
    String? bankName,
    String? branchName,
    String? bankAddress,
    String? accountNumber,
    String? accountHolderName,
    String? ifscCode,
    String? subject,
    String? content,
    String? requestedBy,
    String? designation,
    DateTime? date,
  }) {
    return BankLetterFormData(
      letterType: letterType ?? this.letterType,
      bankName: bankName ?? this.bankName,
      branchName: branchName ?? this.branchName,
      bankAddress: bankAddress ?? this.bankAddress,
      accountNumber: accountNumber ?? this.accountNumber,
      accountHolderName: accountHolderName ?? this.accountHolderName,
      ifscCode: ifscCode ?? this.ifscCode,
      subject: subject ?? this.subject,
      content: content ?? this.content,
      requestedBy: requestedBy ?? this.requestedBy,
      designation: designation ?? this.designation,
      date: date ?? this.date,
    );
  }
}
