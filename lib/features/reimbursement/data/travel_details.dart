

import 'package:ppv_components/features/reimbursement/models/reimbursement_models/reimbursement_note.dart';

final dummyReimbursement = ReimbursementNote(
  id: '1',
  noteNo: 'E/25-26/RN/0175',
  employeeName: 'Deepak Kumar',
  employeeId: 'NHIP122',
  employeeDesignation: 'Deputy Manager - F&A',
  createdAt: DateTime.parse('2025-09-08 20:38:00'),
  dateOfTravel: DateTime.parse('2025-09-01'),
  projectName: 'Corporate Office Delhi',
  department: 'Finance & Accounts',
  modeOfTravel: 'Train-2A',
  travelModeEligibility: '2A',
  initialApproverName: 'Sunil Kumar',
  approverDesignation: 'Assistant Vice President',
  purpose: 'Reimbursement of sweets & snacks for staff Refreshment',
  expenses: [
    ExpenseItem(
      expenseType: 'Sweets & snacks',
      billDate: '-',
      billNumber: '7185277431',
      vendorName: 'zomato',
      amount: 1336.00,
      supportingAvailable: true,
      remarks: 'Sweets & snacks for Refreshment of staff',
    ),
    ExpenseItem(
      expenseType: 'Sweets & snacks',
      billDate: '-',
      billNumber: '7239295300',
      vendorName: 'zomato',
      amount: 2283.00,
      supportingAvailable: true,
      remarks: 'Sweets & snacks for Refreshment of staff',
    ),
  ],
  totalPayable: 3619.00,
  advanceAdjusted: 0.00,
  netPayable: 3619.00,
  bankDetails: BankDetails(
    accountHolder: 'DEEPAK KUMAR',
    bankName: 'STATE BANK OF INDIA',
    accountNumber: '30373351359',
    ifsc: 'SBIN0005732',
  ),
  preparedByName: 'Deepak Kumar',
  preparedByDesignation: 'Deputy Manager - F&A',
  preparedBySignatureUrl: '', // empty string — no image required
);
