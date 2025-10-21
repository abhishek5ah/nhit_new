import 'package:ppv_components/features/payment_notes/model/detail_page_model.dart';

final paymentNoteDetailMockData = PaymentNoteDetail(
  paymentNoteNo: 'W/25-26/PN/2303',
  noteNo: 'W/25-26/PN/2200',
  date: '11/09/2025 08:15 PM',
  greenNoteNo: 'W/25-26/EN/2321',
  greenNoteAppDate: '08/09/2025 10:56 PM',
  department: 'ITS',
  greenNoteApprover: 'Rakshit Jain',
  subject:
  'Payment against Milestone - 1 (Mobilization Advance) for Design, Supply, Installation, Configuration, Integration, Testing & Commissioning of ATMS at Shivpuri Jhansi Project',
  vendorCode: 'E0789',
  vendorName: 'M/s Qualix Information Systems Llp',
  invoiceNo: 'QIS/PI/25-26/033',
  invoiceAmount: '13932915.00',
  invoiceDate: '22/08/2025',
  invoiceApprovedBy: 'Rakshit Jain',
  loaPoNo: 'NWPPL/ATMS/2024/01',
  loaPoAmount: '314889200.00',
  loaPoDate: '21/07/2025',
  bankAccountHolder: 'M/s Qualix Information Systems Llp',
  bankName: 'HDFC Bank',
  bankAccountNumber: '50200051262970',
  bankIfsc: 'HDFC0001592',
  recommendation: 'Proposed to release the payment',
  approvalMatrix: [
    ApprovalMatrixEntry(
      role: 'Maker',
      name: 'Dharmendra Kumar Meel',
      designation: 'Deputy Manager - F&A',
      dateSignature: '11/09/2025 08:15 PM',
    ),
  ],
  paymentSummary: PaymentSummary(
    taxableAmount: '1,39,32,915.00',
    gst: '0.00',
    otherCharges: '0.00',
    grossAmount: '1,39,32,915.00',
    tds: '2,78,658.00',
    netPayableAmount: '1,36,54,257.00',
    netPayableAmountRoundOff: '1,36,54,257.00',
    netPayableWords:
    'One Crore Thirty Six Lakh Fifty Four Thousand Two Hundred Fifty Seven only',
  ),
  workflowSteps: [
    FlowStep(
      step: 1,
      makerName: 'Dharmendra Kumar Meel',
      status: 'Draft',
      dateTime: '11/09/2025 08:15 PM',
      nextApprover: 'Ravi Kant Vij',
    ),
  ],
);

final List<AttachedDoc> attachedDocsMock = [
  AttachedDoc(
    sno: 1,
    fileName: 'Proforma Invoice',
    uploadDate: '28/08/2025 08:56 PM',
    uploadedBy: 'Neeraj Khadka',
  ),
  AttachedDoc(
    sno: 2,
    fileName: 'Qualix WO Items, Payments Milestone Term & Bank Guaranty',
    uploadDate: '28/08/2025 08:57 PM',
    uploadedBy: 'Neeraj Khadka',
  ),
  AttachedDoc(
    sno: 3,
    fileName: 'Qualix Cancelled Cheque',
    uploadDate: '28/08/2025 08:59 PM',
    uploadedBy: 'Neeraj Khadka',
  ),
  AttachedDoc(
    sno: 4,
    fileName: 'Qualix GST Certificate',
    uploadDate: '28/08/2025 08:59 PM',
    uploadedBy: 'Neeraj Khadka',
  ),
  AttachedDoc(
    sno: 5,
    fileName: 'Qualix MSME Certificate',
    uploadDate: '28/08/2025 08:59 PM',
    uploadedBy: 'Neeraj Khadka',
  ),
  AttachedDoc(
    sno: 6,
    fileName: 'Qualix PAN Card',
    uploadDate: '28/08/2025 09:00 PM',
    uploadedBy: 'Neeraj Khadka',
  ),
  AttachedDoc(
    sno: 7,
    fileName: 'Contract Agreement between NWPPL & Qualix',
    uploadDate: '28/08/2025 09:08 PM',
    uploadedBy: 'Neeraj Khadka',
  ),
  AttachedDoc(
    sno: 8,
    fileName: 'Audit Transaction Remarks',
    uploadDate: '01/09/2025 08:43 PM',
    uploadedBy: 'Concurrent Auditor',
  ),
  AttachedDoc(
    sno: 9,
    fileName: 'Revised Audit Transaction Remarks',
    uploadDate: '02/09/2025 08:42 PM',
    uploadedBy: 'Concurrent Auditor',
  ),
  AttachedDoc(
    sno: 10,
    fileName: 'Client Chart',
    uploadDate: '11/09/2025 08:12 PM',
    uploadedBy: 'Dharmendra Kumar Meel',
  ),
];
