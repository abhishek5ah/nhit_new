import 'package:ppv_components/features/vendor/data/models/vendor_api_models.dart';
import 'package:ppv_components/features/vendor/models/vendor_model.dart';

Vendor mapVendorApiToUi(VendorApiModel apiModel) {
  final status = _mapStatus(apiModel.status);

  final taxInfo = TaxInfo(
    gstin: apiModel.gstNumber,
    pan: apiModel.panNumber,
    isGstDefaulted: false,
    incomeTaxType: apiModel.paymentTerms,
  );

  final msmeInfo = apiModel.msmeRegistered
      ? MsmeInfo(
          classification: apiModel.msmeNumber != null ? 'Registered' : null,
          isMsme: apiModel.msmeRegistered,
          registrationNumber: apiModel.msmeNumber,
        )
      : null;

  final locationInfo = LocationInfo(
    country: apiModel.address.country,
    state: apiModel.address.state,
    city: apiModel.address.city,
    address: apiModel.address.street,
  );

  final bankAccounts = apiModel.accounts
      .map(
        (account) => BankAccount(
          accountNumber: account.accountNumber,
          ifscCode: account.ifscCode,
          bankName: account.bankName,
          branchName: account.branchName,
          beneficiaryName: account.accountHolderName,
          accountName: account.bankName,
          isPrimary: account.isPrimary,
        ),
      )
      .toList();

  return Vendor(
    id: apiModel.id ?? 0,
    code: apiModel.vendorCode,
    name: apiModel.name,
    email: apiModel.email,
    mobile: apiModel.phone,
    status: status,
    vendorType: apiModel.vendorType,
    fromAccountType: apiModel.paymentTerms,
    project: null,
    activityType: null,
    vendorNickName: apiModel.contactPerson,
    shortName: apiModel.name,
    taxInfo: taxInfo,
    msmeInfo: msmeInfo,
    locationInfo: locationInfo,
    bankAccounts: bankAccounts,
  );
}

String _mapStatus(String status) {
  switch (status.toUpperCase()) {
    case 'ACTIVE':
      return 'Active';
    case 'INACTIVE':
      return 'Inactive';
    case 'BLOCKED':
      return 'Blocked';
    default:
      return status;
  }
}
