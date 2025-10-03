// FILE: lib/models/travel_details.dart

class ExpenseItem {
  final String expenseType;
  final String billDate;
  final String billNumber;
  final String vendorName;
  final double amount;
  final bool supportingAvailable;
  final String remarks;

  ExpenseItem({
    required this.expenseType,
    required this.billDate,
    required this.billNumber,
    required this.vendorName,
    required this.amount,
    required this.supportingAvailable,
    required this.remarks,
  });
}

class BankDetails {
  final String accountHolder;
  final String bankName;
  final String accountNumber;
  final String ifsc;

  BankDetails({
    required this.accountHolder,
    required this.bankName,
    required this.accountNumber,
    required this.ifsc,
  });
}

class ReimbursementNote {
  final String id;
  final String noteNo;
  final String employeeName;
  final String employeeId;
  final String employeeDesignation;
  final DateTime createdAt;
  final DateTime dateOfTravel;
  final String projectName;
  final String department;
  final String modeOfTravel;
  final String travelModeEligibility;
  final String initialApproverName;
  final String approverDesignation;
  final String purpose;
  final List<ExpenseItem> expenses;
  final double totalPayable;
  final double advanceAdjusted;
  final double netPayable;
  final BankDetails bankDetails;
  final String preparedByName;
  final String preparedByDesignation;
  final String preparedBySignatureUrl;

  ReimbursementNote({
    required this.id,
    required this.noteNo,
    required this.employeeName,
    required this.employeeId,
    required this.employeeDesignation,
    required this.createdAt,
    required this.dateOfTravel,
    required this.projectName,
    required this.department,
    required this.modeOfTravel,
    required this.travelModeEligibility,
    required this.initialApproverName,
    required this.approverDesignation,
    required this.purpose,
    required this.expenses,
    required this.totalPayable,
    required this.advanceAdjusted,
    required this.netPayable,
    required this.bankDetails,
    required this.preparedByName,
    required this.preparedByDesignation,
    required this.preparedBySignatureUrl,
  });
}
