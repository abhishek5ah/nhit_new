
import 'package:ppv_components/features/expense/model/expense_detail_model.dart';

class GreenNoteDummy {
  final GreenNoteData dummy = GreenNoteData(
    companyName: 'NHIT Western Projects Private Limited',
    noteTitle: 'Note for Approval of Invoice payment',
    date: '11/09/2025 09:10 PM',
    project: 'Corporate Office Delhi',
    department: 'Operations',
    noteNo: 'W/25-26/EN/2548',
    purchaseWorkOrderNo: 'PIMA Agreement',
    purchaseWorkOrderDate: '30/03/2021',
    amountPOWO: 'Rs. 5,67,00,000.00',
    taxableValue: 'Rs. 5,67,00,000.00',
    otherCharges: 'Rs. 0.00',
    gst: 'Rs. 1,02,06,000.00',
    totalPOWOValue: 'Rs. 6,69,06,000.00',
    supplierName: 'National Highways Invit Project Managers Private Limited',
    vendorMSME: 'Non-MSME',
    activityType: 'N/A',
    protestNoteRequired: 'NO',
    briefDescription: 'PMC Fees for the Month of Aug 25 _Round 1&2 (NWPPL)',
    invoiceNo: '2025-26/PMC-13',
    invoiceDate: '08/09/2025',
    invoiceTaxableValue: '47,25,000.00',
    invoiceGST: '8,50,500.00',
    invoiceOtherCharges: '0.00',
    invoiceValue: '55,75,500.00',
    contractPeriod: 'From 01/04/2025 To 31/03/2026',
    periodOfSupply: 'from 01/08/2025 to 31/08/2025',
    contractCompleted: 'NO',
    extensionExecuted: 'NO',
    delayedDamages: 'No',
    budgetExpenditure: '6,69,06,000.00',
    actualExpenditure: '2,78,77,500.00',
    expenditureOverBudget: 'NO',
    natureOfExpenses: 'DCS-001 - Project Management Consultancies (PMC)',
    milestoneStatus: 'Yes',
    milestoneRemarks: 'NO',
    expenseWithinContract: 'Yes',
    signatureName: 'Sameer Khan',
    signatureDesignation: 'Executive - MIS Payables',
    signatureDate: '11/09/2025 09:10 PM',
    initialAttachments: [
      {
        'sno': '1',
        'fileName': 'Tax Invoice',
        'uploadDate': '11/09/2025 09:11 PM',
        'uploadedBy': 'Sameer Khan',
        'path': '' // keep empty to simulate not downloaded locally
      }
    ],
    initialComments: [
      {
        'author': 'Sameer Khan',
        'time': '(6 days ago) | (11/09/2025 09:11 PM)',
        'text': 'For Jatindra Ji - HR Compliances not applicable'
      }
    ],
    flowStepTitle: 'Step 1',
    flowMaker: 'Sameer Khan',
    flowDate: '11/09/2025 09:10 PM',
    flowStatus: 'Approved',
    nextApprover: 'Naveen Kumar',
  );
}

// Optional convenience export
final GreenNoteData myGreenNoteData = GreenNoteDummy().dummy;
