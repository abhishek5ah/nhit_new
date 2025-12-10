class EscrowAccountResponse {
  final EscrowAccountData account;

  EscrowAccountResponse({required this.account});

  factory EscrowAccountResponse.fromJson(Map<String, dynamic> json) {
    return EscrowAccountResponse(
      account: EscrowAccountData.fromJson(json['account']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'account': account.toJson(),
    };
  }
}

class EscrowAccountData {
  final String accountId;
  final String accountName;
  final String accountNumber;
  final String bankName;
  final String branchName;
  final String ifscCode;
  final double balance;
  final double availableBalance;
  final String accountType;
  final String status;
  final String description;
  final List<String> authorizedSignatories;
  final String? createdById;
  final String? organizationId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  EscrowAccountData({
    required this.accountId,
    required this.accountName,
    required this.accountNumber,
    required this.bankName,
    required this.branchName,
    required this.ifscCode,
    required this.balance,
    required this.availableBalance,
    required this.accountType,
    required this.status,
    required this.description,
    required this.authorizedSignatories,
    this.createdById,
    this.organizationId,
    this.createdAt,
    this.updatedAt,
  });

  factory EscrowAccountData.fromJson(Map<String, dynamic> json) {
    // Backend currently returns camelCase keys (accountId, accountName, ...),
    // while earlier versions used snake_case (account_id, account_name, ...).
    // Support both formats to be fully compatible.
    return EscrowAccountData(
      accountId: json['accountId'] ?? json['account_id'] ?? '',
      accountName: json['accountName'] ?? json['account_name'] ?? '',
      accountNumber: json['accountNumber'] ?? json['account_number'] ?? '',
      bankName: json['bankName'] ?? json['bank_name'] ?? '',
      branchName: json['branchName'] ?? json['branch_name'] ?? '',
      ifscCode: json['ifscCode'] ?? json['ifsc_code'] ?? '',
      balance: (json['balance'] ?? 0).toDouble(),
      availableBalance: (json['availableBalance'] ?? json['available_balance'] ?? 0).toDouble(),
      accountType: json['accountType'] ?? json['account_type'] ?? '',
      status: json['status'] ?? '',
      description: json['description'] ?? '',
      authorizedSignatories: List<String>.from(
        json['authorizedSignatories'] ?? json['authorized_signatories'] ?? [],
      ),
      createdById: json['createdById'] ?? json['created_by_id'],
      organizationId: json['organizationId'] ?? json['organization_id'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : (json['created_at'] != null ? DateTime.parse(json['created_at']) : null),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : (json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'account_id': accountId,
      'account_name': accountName,
      'account_number': accountNumber,
      'bank_name': bankName,
      'branch_name': branchName,
      'ifsc_code': ifscCode,
      'balance': balance,
      'available_balance': availableBalance,
      'account_type': accountType,
      'status': status,
      'description': description,
      'authorized_signatories': authorizedSignatories,
      if (createdById != null) 'created_by_id': createdById,
      if (organizationId != null) 'organization_id': organizationId,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  // Convert to existing EscrowAccount model for UI compatibility
  EscrowAccount toEscrowAccount() {
    print('🔄 CONVERTING: $accountName -> bankName: $bankName, accountType: $accountType');
    
    return EscrowAccount(
      accountName: accountName,
      accountNumber: accountNumber,
      bank: bankName,  // ✅ bankName -> bank
      branchName: branchName,
      ifscCode: ifscCode,
      type: accountType,  // ✅ accountType -> type
      status: status,
      balance: '₹${balance.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
    );
  }
}

// Import the existing model for compatibility
class EscrowAccount {
  final String accountName;
  final String accountNumber;
  final String bank;
  final String branchName;
  final String ifscCode;
  final String type;
  final String status;
  final String balance;

  EscrowAccount({
    required this.accountName,
    required this.accountNumber,
    required this.bank,
    required this.branchName,
    required this.ifscCode,
    required this.type,
    required this.status,
    required this.balance,
  });

  factory EscrowAccount.fromMap(Map<String, dynamic> m) => EscrowAccount(
        accountName: m['account_name'] ?? '',
        accountNumber: m['account_number'] ?? '',
        bank: m['bank'] ?? '',
        branchName: m['branch_name'] ?? '',
        ifscCode: m['ifsc_code'] ?? '',
        type: m['type'] ?? '',
        status: m['status'] ?? '',
        balance: m['balance'] ?? '',
      );

  EscrowAccount copyWith({
    String? accountName,
    String? accountNumber,
    String? bank,
    String? branchName,
    String? ifscCode,
    String? type,
    String? status,
    String? balance,
  }) {
    return EscrowAccount(
      accountName: accountName ?? this.accountName,
      accountNumber: accountNumber ?? this.accountNumber,
      bank: bank ?? this.bank,
      branchName: branchName ?? this.branchName,
      ifscCode: ifscCode ?? this.ifscCode,
      type: type ?? this.type,
      status: status ?? this.status,
      balance: balance ?? this.balance,
    );
  }
}
