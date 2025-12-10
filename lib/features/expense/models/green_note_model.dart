class Invoice {
  final String invoiceNumber;
  final String invoiceDate;
  final double taxableValue;
  final double gst;
  final double otherCharges;
  final double invoiceValue;

  Invoice({
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.taxableValue,
    required this.gst,
    required this.otherCharges,
    required this.invoiceValue,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      invoiceNumber: json['invoice_number'] ?? '',
      invoiceDate: json['invoice_date'] ?? '',
      taxableValue: (json['taxable_value'] ?? 0).toDouble(),
      gst: (json['gst'] ?? 0).toDouble(),
      otherCharges: (json['other_charges'] ?? 0).toDouble(),
      invoiceValue: (json['invoice_value'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'invoice_number': invoiceNumber,
      'invoice_date': invoiceDate,
      'taxable_value': taxableValue,
      'gst': gst,
      'other_charges': otherCharges,
      'invoice_value': invoiceValue,
    };
  }
}

class GreenNote {
  final String? id;
  final String projectName;
  final String supplierName;
  final String expenseCategory;
  final String protestNoteRaised;
  final String whetherContract;
  final String extensionOfContractPeriodExecuted;
  final String expenseAmountWithinContract;
  final String milestoneAchieved;
  final String paymentApprovedWithDeviation;
  final String requiredDocumentsSubmitted;
  final String documentsVerified;
  final String contractStartDate;
  final String contractEndDate;
  final String appointedStartDate;
  final String supplyPeriodStart;
  final String supplyPeriodEnd;
  final double baseValue;
  final double otherCharges;
  final double gst;
  final double totalAmount;
  final bool enableMultipleInvoices;
  final List<Invoice> invoices;
  final String status;
  final String approvalFor;
  final String departmentName;
  final String workOrderNo;
  final String poNumber;
  final String workOrderDate;
  final String expenseCategoryType;
  final String msmeClassification;
  final String activityType;
  final String briefOfGoodsServices;
  final String delayedDamages;
  final String natureOfExpenses;
  final String contractPeriodCompleted;
  final double budgetExpenditure;
  final double actualExpenditure;
  final double expenditureOverBudget;
  final String milestoneRemarks;
  final String specifyDeviation;
  final String documentsWorkdoneSupply;
  final String documentsDiscrepancy;
  final String remarks;
  final String auditorRemarks;
  final double amountRetainedForNonSubmission;
  final String? createdAt;
  final String? updatedAt;

  GreenNote({
    this.id,
    required this.projectName,
    required this.supplierName,
    required this.expenseCategory,
    required this.protestNoteRaised,
    required this.whetherContract,
    required this.extensionOfContractPeriodExecuted,
    required this.expenseAmountWithinContract,
    required this.milestoneAchieved,
    required this.paymentApprovedWithDeviation,
    required this.requiredDocumentsSubmitted,
    required this.documentsVerified,
    required this.contractStartDate,
    required this.contractEndDate,
    required this.appointedStartDate,
    required this.supplyPeriodStart,
    required this.supplyPeriodEnd,
    required this.baseValue,
    required this.otherCharges,
    required this.gst,
    required this.totalAmount,
    required this.enableMultipleInvoices,
    required this.invoices,
    required this.status,
    required this.approvalFor,
    required this.departmentName,
    required this.workOrderNo,
    required this.poNumber,
    required this.workOrderDate,
    required this.expenseCategoryType,
    required this.msmeClassification,
    required this.activityType,
    required this.briefOfGoodsServices,
    required this.delayedDamages,
    required this.natureOfExpenses,
    required this.contractPeriodCompleted,
    required this.budgetExpenditure,
    required this.actualExpenditure,
    required this.expenditureOverBudget,
    required this.milestoneRemarks,
    required this.specifyDeviation,
    required this.documentsWorkdoneSupply,
    required this.documentsDiscrepancy,
    required this.remarks,
    required this.auditorRemarks,
    required this.amountRetainedForNonSubmission,
    this.createdAt,
    this.updatedAt,
  });

  factory GreenNote.fromJson(Map<String, dynamic> json) {
    final noteData = json['note'] ?? json;
    
    return GreenNote(
      id: noteData['id']?.toString(),
      projectName: noteData['project_name'] ?? '',
      supplierName: noteData['supplier_name'] ?? '',
      expenseCategory: noteData['expense_category'] ?? '',
      protestNoteRaised: noteData['protest_note_raised'] ?? '',
      whetherContract: noteData['whether_contract'] ?? '',
      extensionOfContractPeriodExecuted: noteData['extension_of_contract_period_executed'] ?? '',
      expenseAmountWithinContract: noteData['expense_amount_within_contract'] ?? '',
      milestoneAchieved: noteData['milestone_achieved'] ?? '',
      paymentApprovedWithDeviation: noteData['payment_approved_with_deviation'] ?? '',
      requiredDocumentsSubmitted: noteData['required_documents_submitted'] ?? '',
      documentsVerified: noteData['documents_verified'] ?? '',
      contractStartDate: noteData['contract_start_date'] ?? '',
      contractEndDate: noteData['contract_end_date'] ?? '',
      appointedStartDate: noteData['appointed_start_date'] ?? '',
      supplyPeriodStart: noteData['supply_period_start'] ?? '',
      supplyPeriodEnd: noteData['supply_period_end'] ?? '',
      baseValue: (noteData['base_value'] ?? 0).toDouble(),
      otherCharges: (noteData['other_charges'] ?? 0).toDouble(),
      gst: (noteData['gst'] ?? 0).toDouble(),
      totalAmount: (noteData['total_amount'] ?? 0).toDouble(),
      enableMultipleInvoices: noteData['enable_multiple_invoices'] ?? false,
      invoices: (noteData['invoices'] as List<dynamic>?)
              ?.map((invoice) => Invoice.fromJson(invoice))
              .toList() ??
          [],
      status: noteData['status'] ?? 'pending',
      approvalFor: noteData['approval_for'] ?? '',
      departmentName: noteData['department_name'] ?? '',
      workOrderNo: noteData['work_order_no'] ?? '',
      poNumber: noteData['po_number'] ?? '',
      workOrderDate: noteData['work_order_date'] ?? '',
      expenseCategoryType: noteData['expense_category_type'] ?? '',
      msmeClassification: noteData['msme_classification'] ?? '',
      activityType: noteData['activity_type'] ?? '',
      briefOfGoodsServices: noteData['brief_of_goods_services'] ?? '',
      delayedDamages: noteData['delayed_damages'] ?? '',
      natureOfExpenses: noteData['nature_of_expenses'] ?? '',
      contractPeriodCompleted: noteData['contract_period_completed'] ?? '',
      budgetExpenditure: (noteData['budget_expenditure'] ?? 0).toDouble(),
      actualExpenditure: (noteData['actual_expenditure'] ?? 0).toDouble(),
      expenditureOverBudget: (noteData['expenditure_over_budget'] ?? 0).toDouble(),
      milestoneRemarks: noteData['milestone_remarks'] ?? '',
      specifyDeviation: noteData['specify_deviation'] ?? '',
      documentsWorkdoneSupply: noteData['documents_workdone_supply'] ?? '',
      documentsDiscrepancy: noteData['documents_discrepancy'] ?? '',
      remarks: noteData['remarks'] ?? '',
      auditorRemarks: noteData['auditor_remarks'] ?? '',
      amountRetainedForNonSubmission: (noteData['amount_retained_for_non_submission'] ?? 0).toDouble(),
      createdAt: noteData['created_at']?.toString(),
      updatedAt: noteData['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'note': {
        if (id != null) 'id': id,
        'project_name': projectName,
        'supplier_name': supplierName,
        'expense_category': expenseCategory,
        'protest_note_raised': protestNoteRaised,
        'whether_contract': whetherContract,
        'extension_of_contract_period_executed': extensionOfContractPeriodExecuted,
        'expense_amount_within_contract': expenseAmountWithinContract,
        'milestone_achieved': milestoneAchieved,
        'payment_approved_with_deviation': paymentApprovedWithDeviation,
        'required_documents_submitted': requiredDocumentsSubmitted,
        'documents_verified': documentsVerified,
        'contract_start_date': contractStartDate,
        'contract_end_date': contractEndDate,
        'appointed_start_date': appointedStartDate,
        'supply_period_start': supplyPeriodStart,
        'supply_period_end': supplyPeriodEnd,
        'base_value': baseValue,
        'other_charges': otherCharges,
        'gst': gst,
        'total_amount': totalAmount,
        'enable_multiple_invoices': enableMultipleInvoices,
        'invoices': invoices.map((invoice) => invoice.toJson()).toList(),
        'status': status,
        'approval_for': approvalFor,
        'department_name': departmentName,
        'work_order_no': workOrderNo,
        'po_number': poNumber,
        'work_order_date': workOrderDate,
        'expense_category_type': expenseCategoryType,
        'msme_classification': msmeClassification,
        'activity_type': activityType,
        'brief_of_goods_services': briefOfGoodsServices,
        'delayed_damages': delayedDamages,
        'nature_of_expenses': natureOfExpenses,
        'contract_period_completed': contractPeriodCompleted,
        'budget_expenditure': budgetExpenditure,
        'actual_expenditure': actualExpenditure,
        'expenditure_over_budget': expenditureOverBudget,
        'milestone_remarks': milestoneRemarks,
        'specify_deviation': specifyDeviation,
        'documents_workdone_supply': documentsWorkdoneSupply,
        'documents_discrepancy': documentsDiscrepancy,
        'remarks': remarks,
        'auditor_remarks': auditorRemarks,
        'amount_retained_for_non_submission': amountRetainedForNonSubmission,
      }
    };
  }
}
