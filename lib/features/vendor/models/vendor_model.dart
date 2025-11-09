import 'package:flutter/material.dart';

class Vendor {
  final int id;
  final String code;
  final String name;
  final String email;
  final String mobile;
  final String status;
  final String? vendorType;
  final String? fromAccountType;
  final String? project;
  final String? activityType;
  final String? vendorNickName;
  final String? shortName;
  final TaxInfo taxInfo;
  final MsmeInfo? msmeInfo;
  final LocationInfo locationInfo;
  final List<BankAccount> bankAccounts;

  Vendor({
    required this.id,
    required this.code,
    required this.name,
    required this.email,
    required this.mobile,
    required this.status,
    this.vendorType,
    this.fromAccountType,
    this.project,
    this.activityType,
    this.vendorNickName,
    this.shortName,
    required this.taxInfo,
    this.msmeInfo,
    required this.locationInfo,
    required this.bankAccounts,
  });

  Vendor copyWith({
    int? id,
    String? code,
    String? name,
    String? email,
    String? mobile,
    String? status,
    String? vendorType,
    String? fromAccountType,
    String? project,
    String? activityType,
    String? vendorNickName,
    String? shortName,
    TaxInfo? taxInfo,
    MsmeInfo? msmeInfo,
    LocationInfo? locationInfo,
    List<BankAccount>? bankAccounts,
  }) {
    return Vendor(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      email: email ?? this.email,
      mobile: mobile ?? this.mobile,
      status: status ?? this.status,
      vendorType: vendorType ?? this.vendorType,
      fromAccountType: fromAccountType ?? this.fromAccountType,
      project: project ?? this.project,
      activityType: activityType ?? this.activityType,
      vendorNickName: vendorNickName ?? this.vendorNickName,
      shortName: shortName ?? this.shortName,
      taxInfo: taxInfo ?? this.taxInfo,
      msmeInfo: msmeInfo ?? this.msmeInfo,
      locationInfo: locationInfo ?? this.locationInfo,
      bankAccounts: bankAccounts ?? this.bankAccounts,
    );
  }
}

class TaxInfo {
  final String? gstin;
  final String? pan;
  final bool isGstDefaulted;
  final String? section206abVerified;
  final String? incomeTaxType;
  final String? materialNature;

  TaxInfo({
    this.gstin,
    this.pan,
    this.isGstDefaulted = false,
    this.section206abVerified,
    this.incomeTaxType,
    this.materialNature,
  });

  TaxInfo copyWith({
    String? gstin,
    String? pan,
    bool? isGstDefaulted,
    String? section206abVerified,
    String? incomeTaxType,
    String? materialNature,
  }) {
    return TaxInfo(
      gstin: gstin ?? this.gstin,
      pan: pan ?? this.pan,
      isGstDefaulted: isGstDefaulted ?? this.isGstDefaulted,
      section206abVerified: section206abVerified ?? this.section206abVerified,
      incomeTaxType: incomeTaxType ?? this.incomeTaxType,
      materialNature: materialNature ?? this.materialNature,
    );
  }
}

class MsmeInfo {
  final String? classification;
  final bool isMsme;
  final String? registrationNumber;
  final String? startDate;
  final String? endDate;

  MsmeInfo({
    this.classification,
    this.isMsme = false,
    this.registrationNumber,
    this.startDate,
    this.endDate,
  });

  MsmeInfo copyWith({
    String? classification,
    bool? isMsme,
    String? registrationNumber,
    String? startDate,
    String? endDate,
  }) {
    return MsmeInfo(
      classification: classification ?? this.classification,
      isMsme: isMsme ?? this.isMsme,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}

class LocationInfo {
  final String country;
  final String state;
  final String city;
  final String address;

  LocationInfo({
    required this.country,
    required this.state,
    required this.city,
    required this.address,
  });

  LocationInfo copyWith({
    String? country,
    String? state,
    String? city,
    String? address,
  }) {
    return LocationInfo(
      country: country ?? this.country,
      state: state ?? this.state,
      city: city ?? this.city,
      address: address ?? this.address,
    );
  }
}

class BankAccount {
  final String accountNumber;
  final String ifscCode;
  final String bankName;
  final String? branchName;
  final String beneficiaryName;
  final String? accountName;
  late final bool isPrimary;

  BankAccount({
    required this.accountNumber,
    required this.ifscCode,
    required this.bankName,
    this.branchName,
    required this.beneficiaryName,
    this.accountName,
    this.isPrimary = false,
  });

  BankAccount copyWith({
    String? accountNumber,
    String? ifscCode,
    String? bankName,
    String? branchName,
    String? beneficiaryName,
    String? accountName,
    bool? isPrimary,
  }) {
    return BankAccount(
      accountNumber: accountNumber ?? this.accountNumber,
      ifscCode: ifscCode ?? this.ifscCode,
      bankName: bankName ?? this.bankName,
      branchName: branchName ?? this.branchName,
      beneficiaryName: beneficiaryName ?? this.beneficiaryName,
      accountName: accountName ?? this.accountName,
      isPrimary: isPrimary ?? this.isPrimary,
    );
  }
}
