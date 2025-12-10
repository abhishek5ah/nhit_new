// Vendor API Models - Complete backend integration models

class VendorAddress {
  final String street;
  final String city;
  final String state;
  final String postalCode;
  final String country;

  VendorAddress({
    required this.street,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
  });

  factory VendorAddress.fromJson(Map<String, dynamic> json) {
    return VendorAddress(
      street: json['street'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      postalCode: json['postal_code'] ?? json['postalCode'] ?? '',
      country: json['country'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'street': street,
      'city': city,
      'state': state,
      'postal_code': postalCode,
      'country': country,
    };
  }
}

class VendorApiModel {
  final int? id;
  final String vendorCode;
  final String name;
  final String contactPerson;
  final String email;
  final String phone;
  final String? alternatePhone;
  final VendorAddress address;
  final String gstNumber;
  final String panNumber;
  final String? tanNumber;
  final bool msmeRegistered;
  final String? msmeNumber;
  final String vendorType; // SUPPLIER, CONTRACTOR, SERVICE_PROVIDER
  final String paymentTerms;
  final double creditLimit;
  final String status; // ACTIVE, INACTIVE, BLOCKED
  final List<VendorBankAccount> accounts;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  VendorApiModel({
    this.id,
    required this.vendorCode,
    required this.name,
    required this.contactPerson,
    required this.email,
    required this.phone,
    this.alternatePhone,
    required this.address,
    required this.gstNumber,
    required this.panNumber,
    this.tanNumber,
    required this.msmeRegistered,
    this.msmeNumber,
    required this.vendorType,
    required this.paymentTerms,
    required this.creditLimit,
    required this.status,
    this.accounts = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory VendorApiModel.fromJson(Map<String, dynamic> json) {
    return VendorApiModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      vendorCode: json['vendor_code'] ?? json['vendorCode'] ?? '',
      name: json['name'] ?? '',
      contactPerson: json['contact_person'] ?? json['contactPerson'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      alternatePhone: json['alternate_phone'] ?? json['alternatePhone'],
      address: json['address'] != null
          ? VendorAddress.fromJson(json['address'])
          : VendorAddress(street: '', city: '', state: '', postalCode: '', country: ''),
      gstNumber: json['gst_number'] ?? json['gstNumber'] ?? '',
      panNumber: json['pan_number'] ?? json['panNumber'] ?? '',
      tanNumber: json['tan_number'] ?? json['tanNumber'],
      msmeRegistered: json['msme_registered'] ?? json['msmeRegistered'] ?? false,
      msmeNumber: json['msme_number'] ?? json['msmeNumber'],
      vendorType: json['vendor_type'] ?? json['vendorType'] ?? 'SUPPLIER',
      paymentTerms: json['payment_terms'] ?? json['paymentTerms'] ?? '',
      creditLimit: (json['credit_limit'] ?? json['creditLimit'] ?? 0).toDouble(),
      status: json['status'] ?? 'ACTIVE',
      accounts: (json['accounts'] as List<dynamic>?)
              ?.map((acc) => VendorBankAccount.fromJson(acc))
              .toList() ??
          [],
      createdAt: json['created_at'] != null || json['createdAt'] != null
          ? DateTime.tryParse(json['created_at'] ?? json['createdAt'] ?? '')
          : null,
      updatedAt: json['updated_at'] != null || json['updatedAt'] != null
          ? DateTime.tryParse(json['updated_at'] ?? json['updatedAt'] ?? '')
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'vendor_code': vendorCode,
      'name': name,
      'contact_person': contactPerson,
      'email': email,
      'phone': phone,
      if (alternatePhone != null) 'alternate_phone': alternatePhone,
      'address': address.toJson(),
      'gst_number': gstNumber,
      'pan_number': panNumber,
      if (tanNumber != null) 'tan_number': tanNumber,
      'msme_registered': msmeRegistered,
      if (msmeNumber != null) 'msme_number': msmeNumber,
      'vendor_type': vendorType,
      'payment_terms': paymentTerms,
      'credit_limit': creditLimit,
      'status': status,
      'accounts': accounts.map((account) => account.toJson()).toList(),
    };
  }
}

class VendorBankAccount {
  final int? id;
  final int? vendorId;
  final String accountHolderName;
  final String bankName;
  final String branchName;
  final String accountNumber;
  final String ifscCode;
  final String accountType; // CURRENT, SAVINGS
  final String? swiftCode;
  final bool isPrimary;
  final bool isActive;
  final DateTime? createdAt;

  VendorBankAccount({
    this.id,
    this.vendorId,
    required this.accountHolderName,
    required this.bankName,
    required this.branchName,
    required this.accountNumber,
    required this.ifscCode,
    required this.accountType,
    this.swiftCode,
    required this.isPrimary,
    required this.isActive,
    this.createdAt,
  });

  factory VendorBankAccount.fromJson(Map<String, dynamic> json) {
    return VendorBankAccount(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      vendorId: json['vendor_id'] is int
          ? json['vendor_id']
          : int.tryParse(json['vendor_id']?.toString() ?? ''),
      accountHolderName: json['account_holder_name'] ?? json['accountHolderName'] ?? '',
      bankName: json['bank_name'] ?? json['bankName'] ?? '',
      branchName: json['branch_name'] ?? json['branchName'] ?? '',
      accountNumber: json['account_number'] ?? json['accountNumber'] ?? '',
      ifscCode: json['ifsc_code'] ?? json['ifscCode'] ?? '',
      accountType: json['account_type'] ?? json['accountType'] ?? 'CURRENT',
      swiftCode: json['swift_code'] ?? json['swiftCode'],
      isPrimary: json['is_primary'] ?? json['isPrimary'] ?? false,
      isActive: json['is_active'] ?? json['isActive'] ?? true,
      createdAt: json['created_at'] != null || json['createdAt'] != null
          ? DateTime.tryParse(json['created_at'] ?? json['createdAt'] ?? '')
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (vendorId != null) 'vendor_id': vendorId,
      'account_holder_name': accountHolderName,
      'bank_name': bankName,
      'branch_name': branchName,
      'account_number': accountNumber,
      'ifsc_code': ifscCode,
      'account_type': accountType,
      if (swiftCode != null) 'swift_code': swiftCode,
      'is_primary': isPrimary,
      'is_active': isActive,
    };
  }
}

// Request Models
class CreateVendorRequest {
  final VendorApiModel vendor;

  CreateVendorRequest({required this.vendor});

  Map<String, dynamic> toJson() {
    return {'vendor': vendor.toJson()};
  }
}

class UpdateVendorRequest {
  final int id;
  final VendorApiModel vendor;

  UpdateVendorRequest({required this.id, required this.vendor});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vendor': vendor.toJson(),
    };
  }
}

class GenerateVendorCodeRequest {
  final String prefix;
  final String vendorName;

  GenerateVendorCodeRequest({
    required this.prefix,
    required this.vendorName,
  });

  Map<String, dynamic> toJson() {
    return {
      'prefix': prefix,
      'vendor_name': vendorName,
    };
  }
}

class UpdateVendorCodeRequest {
  final int id;
  final String vendorCode;

  UpdateVendorCodeRequest({required this.id, required this.vendorCode});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vendor_code': vendorCode,
    };
  }
}

class RegenerateVendorCodeRequest {
  final int id;
  final String prefix;

  RegenerateVendorCodeRequest({required this.id, required this.prefix});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'prefix': prefix,
    };
  }
}

class CreateVendorAccountRequest {
  final int vendorId;
  final VendorBankAccount account;

  CreateVendorAccountRequest({required this.vendorId, required this.account});

  Map<String, dynamic> toJson() {
    return {
      'vendor_id': vendorId,
      'account': account.toJson(),
    };
  }
}

class UpdateVendorAccountRequest {
  final int id;
  final VendorBankAccount account;

  UpdateVendorAccountRequest({required this.id, required this.account});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'account': account.toJson(),
    };
  }
}

class ToggleAccountStatusRequest {
  final int id;
  final bool isActive;

  ToggleAccountStatusRequest({required this.id, required this.isActive});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'is_active': isActive,
    };
  }
}

// Response Models
class VendorResponse {
  final VendorApiModel vendor;

  VendorResponse({required this.vendor});

  factory VendorResponse.fromJson(Map<String, dynamic> json) {
    return VendorResponse(
      vendor: VendorApiModel.fromJson(json['vendor'] ?? json),
    );
  }
}

class VendorsListResponse {
  final List<VendorApiModel> vendors;
  final VendorPagination pagination;

  VendorsListResponse({required this.vendors, required this.pagination});

  factory VendorsListResponse.fromJson(Map<String, dynamic> json) {
    return VendorsListResponse(
      vendors: (json['vendors'] as List<dynamic>?)
              ?.map((v) => VendorApiModel.fromJson(v))
              .toList() ??
          [],
      pagination: VendorPagination.fromJson(json['pagination'] ?? {}),
    );
  }
}

class VendorPagination {
  final int total;
  final int page;
  final int perPage;
  final int totalPages;

  VendorPagination({
    required this.total,
    required this.page,
    required this.perPage,
    required this.totalPages,
  });

  factory VendorPagination.fromJson(Map<String, dynamic> json) {
    return VendorPagination(
      total: json['total'] ?? json['total_items'] ?? 0,
      page: json['page'] ?? json['current_page'] ?? 1,
      perPage: json['per_page'] ?? json['page_size'] ?? 10,
      totalPages: json['total_pages'] ?? 1,
    );
  }
}

class VendorCodeResponse {
  final String vendorCode;

  VendorCodeResponse({required this.vendorCode});

  factory VendorCodeResponse.fromJson(Map<String, dynamic> json) {
    return VendorCodeResponse(
      vendorCode: json['vendor_code'] ?? json['vendorCode'] ?? '',
    );
  }
}

class VendorAccountResponse {
  final VendorBankAccount account;

  VendorAccountResponse({required this.account});

  factory VendorAccountResponse.fromJson(Map<String, dynamic> json) {
    return VendorAccountResponse(
      account: VendorBankAccount.fromJson(json['account'] ?? json),
    );
  }
}

class VendorAccountsListResponse {
  final List<VendorBankAccount> accounts;

  VendorAccountsListResponse({required this.accounts});

  factory VendorAccountsListResponse.fromJson(Map<String, dynamic> json) {
    return VendorAccountsListResponse(
      accounts: (json['accounts'] as List<dynamic>?)
              ?.map((acc) => VendorBankAccount.fromJson(acc))
              .toList() ??
          [],
    );
  }
}

class VendorBankingDetailsResponse {
  final VendorApiModel vendor;
  final VendorBankAccount? primaryAccount;
  final List<VendorBankAccount> allAccounts;

  VendorBankingDetailsResponse({
    required this.vendor,
    this.primaryAccount,
    required this.allAccounts,
  });

  factory VendorBankingDetailsResponse.fromJson(Map<String, dynamic> json) {
    return VendorBankingDetailsResponse(
      vendor: VendorApiModel.fromJson(json['vendor'] ?? {}),
      primaryAccount: json['primary_account'] != null
          ? VendorBankAccount.fromJson(json['primary_account'])
          : null,
      allAccounts: (json['all_accounts'] as List<dynamic>?)
              ?.map((acc) => VendorBankAccount.fromJson(acc))
              .toList() ??
          [],
    );
  }
}

class DeleteResponse {
  final bool success;
  final String message;

  DeleteResponse({required this.success, required this.message});

  factory DeleteResponse.fromJson(Map<String, dynamic> json) {
    return DeleteResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
    );
  }
}
