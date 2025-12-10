class SimpleEscrowAccount {
  final String id;
  final String accountNumber;
  final String accountName;

  SimpleEscrowAccount({
    required this.id,
    required this.accountNumber,
    required this.accountName,
  });

  factory SimpleEscrowAccount.fromJson(Map<String, dynamic> json) {
    return SimpleEscrowAccount(
      id: json['id'] as String,
      accountNumber: json['account_number'] as String,
      accountName: json['account_name'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'account_number': accountNumber,
    'account_name': accountName,
  };
}

class SimpleVendor {
  final String id;
  final String name;
  final String code;

  SimpleVendor({
    required this.id,
    required this.name,
    required this.code,
  });

  factory SimpleVendor.fromJson(Map<String, dynamic> json) {
    return SimpleVendor(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'code': code,
  };
}

class SimpleUser {
  final String id;
  final String name;
  final String? designation;

  SimpleUser({
    required this.id,
    required this.name,
    this.designation,
  });

  factory SimpleUser.fromJson(Map<String, dynamic> json) {
    return SimpleUser(
      id: json['id'] as String,
      name: json['name'] as String,
      designation: json['designation'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    if (designation != null) 'designation': designation,
  };
}

class TransferLeg {
  final String id;
  final String transferId;
  final String sourceAccountId;
  final String? destinationAccountId;
  final String? destinationVendorId;
  final double amount;
  final SimpleEscrowAccount? sourceAccount;
  final SimpleEscrowAccount? destinationAccount;
  final SimpleVendor? destinationVendor;

  TransferLeg({
    required this.id,
    required this.transferId,
    required this.sourceAccountId,
    this.destinationAccountId,
    this.destinationVendorId,
    required this.amount,
    this.sourceAccount,
    this.destinationAccount,
    this.destinationVendor,
  });

  factory TransferLeg.fromJson(Map<String, dynamic> json) {
    return TransferLeg(
      id: json['id'] as String,
      transferId: json['transfer_id'] as String,
      sourceAccountId: json['source_account_id'] as String,
      destinationAccountId: json['destination_account_id'] as String?,
      destinationVendorId: json['destination_vendor_id'] as String?,
      amount: (json['amount'] as num).toDouble(),
      sourceAccount: json['source_account'] != null ? SimpleEscrowAccount.fromJson(json['source_account'] as Map<String, dynamic>) : null,
      destinationAccount: json['destination_account'] != null ? SimpleEscrowAccount.fromJson(json['destination_account'] as Map<String, dynamic>) : null,
      destinationVendor: json['destination_vendor'] != null ? SimpleVendor.fromJson(json['destination_vendor'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'transfer_id': transferId,
    'source_account_id': sourceAccountId,
    if (destinationAccountId != null) 'destination_account_id': destinationAccountId,
    if (destinationVendorId != null) 'destination_vendor_id': destinationVendorId,
    'amount': amount,
    if (sourceAccount != null) 'source_account': sourceAccount!.toJson(),
    if (destinationAccount != null) 'destination_account': destinationAccount!.toJson(),
    if (destinationVendor != null) 'destination_vendor': destinationVendor!.toJson(),
  };
}
