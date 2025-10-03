class PaymentNoteDetail {
  final String paymentNoteNo;
  final String noteNo;
  final String date;
  final String greenNoteNo;
  final String greenNoteAppDate;
  final String department;
  final String greenNoteApprover;
  final String subject;
  final String vendorCode;
  final String vendorName;
  final String invoiceNo;
  final String invoiceDate;
  final String invoiceAmount;
  final String invoiceApprovedBy;
  final String loaPoNo;
  final String loaPoAmount;
  final String loaPoDate;

  final String bankAccountHolder;
  final String bankName;
  final String bankAccountNumber;
  final String bankIfsc;

  final String recommendation;
  final List<ApprovalMatrixEntry> approvalMatrix;

  final PaymentSummary paymentSummary;

  final List<FlowStep> workflowSteps;

  PaymentNoteDetail({
    required this.paymentNoteNo,
    required this.noteNo,
    required this.date,
    required this.greenNoteNo,
    required this.greenNoteAppDate,
    required this.department,
    required this.greenNoteApprover,
    required this.subject,
    required this.vendorCode,
    required this.vendorName,
    required this.invoiceNo,
    required this.invoiceDate,
    required this.invoiceAmount,
    required this.invoiceApprovedBy,
    required this.loaPoNo,
    required this.loaPoAmount,
    required this.loaPoDate,
    required this.bankAccountHolder,
    required this.bankName,
    required this.bankAccountNumber,
    required this.bankIfsc,
    required this.recommendation,
    required this.approvalMatrix,
    required this.paymentSummary,
    required this.workflowSteps,
  });
}

class ApprovalMatrixEntry {
  final String role;
  final String name;
  final String designation;
  final String dateSignature;

  ApprovalMatrixEntry({
    required this.role,
    required this.name,
    required this.designation,
    required this.dateSignature,
  });
}

class PaymentSummary {
  final String taxableAmount;
  final String gst;
  final String otherCharges;
  final String grossAmount;
  final String tds;
  final String netPayableAmount;
  final String netPayableAmountRoundOff;
  final String netPayableWords;

  PaymentSummary({
    required this.taxableAmount,
    required this.gst,
    required this.otherCharges,
    required this.grossAmount,
    required this.tds,
    required this.netPayableAmount,
    required this.netPayableAmountRoundOff,
    required this.netPayableWords,
  });
}

class FlowStep {
  final int step;
  final String makerName;
  final String status;
  final String dateTime;
  final String nextApprover;

  FlowStep({
    required this.step,
    required this.makerName,
    required this.status,
    required this.dateTime,
    required this.nextApprover,
  });
}

class AttachedDoc {
  final int sno;
  final String fileName;
  final String uploadDate;
  final String uploadedBy;

  AttachedDoc({
    required this.sno,
    required this.fileName,
    required this.uploadDate,
    required this.uploadedBy,
  });
}
