class GreenNoteData {
  // Header
  final String companyName;
  final String noteTitle;
  final String date;
  final String project;
  final String department;
  final String noteNo;

  // PO / WO details
  final String purchaseWorkOrderNo;
  final String purchaseWorkOrderDate;
  final String amountPOWO;
  final String taxableValue;
  final String otherCharges;
  final String gst;
  final String totalPOWOValue;

  // Supplier & brief
  final String supplierName;
  final String vendorMSME;
  final String activityType;
  final String protestNoteRequired;
  final String briefDescription;
  final String invoiceNo;
  final String invoiceDate;
  final String invoiceTaxableValue;
  final String invoiceGST;
  final String invoiceOtherCharges;
  final String invoiceValue;

  // Contract info
  final String contractPeriod;
  final String periodOfSupply;
  final String contractCompleted;
  final String extensionExecuted;
  final String delayedDamages;

  // Budget
  final String budgetExpenditure;
  final String actualExpenditure;
  final String expenditureOverBudget;

  final String natureOfExpenses;
  final String milestoneStatus;
  final String milestoneRemarks;
  final String expenseWithinContract;

  // Signature block
  final String signatureName;
  final String signatureDesignation;
  final String signatureDate;

  // Supporting docs & comments - provide initial lists as list of maps
  // Each map: { 'sno','fileName','uploadDate','uploadedBy','path' }
  final List<Map<String, String>> initialAttachments;
  // Each comment: {'author','time','text'}
  final List<Map<String, String>> initialComments;

  // Flow / right column
  final String flowStepTitle;
  final String flowMaker;
  final String flowDate;
  final String flowStatus;
  final String nextApprover;

  GreenNoteData({
    required this.companyName,
    required this.noteTitle,
    required this.date,
    required this.project,
    required this.department,
    required this.noteNo,
    required this.purchaseWorkOrderNo,
    required this.purchaseWorkOrderDate,
    required this.amountPOWO,
    required this.taxableValue,
    required this.otherCharges,
    required this.gst,
    required this.totalPOWOValue,
    required this.supplierName,
    required this.vendorMSME,
    required this.activityType,
    required this.protestNoteRequired,
    required this.briefDescription,
    required this.invoiceNo,
    required this.invoiceDate,
    required this.invoiceTaxableValue,
    required this.invoiceGST,
    required this.invoiceOtherCharges,
    required this.invoiceValue,
    required this.contractPeriod,
    required this.periodOfSupply,
    required this.contractCompleted,
    required this.extensionExecuted,
    required this.delayedDamages,
    required this.budgetExpenditure,
    required this.actualExpenditure,
    required this.expenditureOverBudget,
    required this.natureOfExpenses,
    required this.milestoneStatus,
    required this.milestoneRemarks,
    required this.expenseWithinContract,
    required this.signatureName,
    required this.signatureDesignation,
    required this.signatureDate,
    required this.initialAttachments,
    required this.initialComments,
    required this.flowStepTitle,
    required this.flowMaker,
    required this.flowDate,
    required this.flowStatus,
    required this.nextApprover,
  });
}
