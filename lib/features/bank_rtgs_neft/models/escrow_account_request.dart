class CreateEscrowAccountRequest {
  final String accountName;
  final String accountNumber;
  final String bankName;
  final String branchName;
  final String ifscCode;
  final String accountType;
  final double balance;
  final String description;
  final List<String> authorizedSignatories;
  final String createdById;

  CreateEscrowAccountRequest({
    required this.accountName,
    required this.accountNumber,
    required this.bankName,
    required this.branchName,
    required this.ifscCode,
    required this.accountType,
    required this.balance,
    required this.description,
    required this.authorizedSignatories,
    required this.createdById,
  });

  Map<String, dynamic> toJson() {
    return {
      'account_name': accountName,
      'account_number': accountNumber,
      'bank_name': bankName,
      'branch_name': branchName,
      'ifsc_code': ifscCode,
      'account_type': accountType.toUpperCase(),
      'balance': balance,
      'description': description,
      'authorized_signatories': authorizedSignatories,
      'created_by_id': createdById,
    };
  }
}

class UpdateEscrowAccountRequest {
  final String accountId;
  final String accountName;
  final String accountNumber;
  final String bankName;
  final String branchName;
  final String ifscCode;
  final String accountType;
  final String description;
  final List<String> authorizedSignatories;
  final String status;

  UpdateEscrowAccountRequest({
    required this.accountId,
    required this.accountName,
    required this.accountNumber,
    required this.bankName,
    required this.branchName,
    required this.ifscCode,
    required this.accountType,
    required this.description,
    required this.authorizedSignatories,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'account_id': accountId,
      'account_name': accountName,
      'account_number': accountNumber,
      'bank_name': bankName,
      'branch_name': branchName,
      'ifsc_code': ifscCode,
      'account_type': accountType.toUpperCase(),
      'description': description,
      'authorized_signatories': authorizedSignatories,
      'status': status,
    };
  }
}

class GetEscrowAccountRequest {
  final String accountId;

  GetEscrowAccountRequest({required this.accountId});

  Map<String, dynamic> toJson() {
    return {
      'account_id': accountId,
    };
  }
}
