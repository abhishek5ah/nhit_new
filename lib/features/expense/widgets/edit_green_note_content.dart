import 'package:flutter/material.dart';
import 'package:ppv_components/common_widgets/button/primary_button.dart';
import 'package:ppv_components/common_widgets/button/secondary_button.dart';
import '../models/green_note_model.dart';

class EditGreenNoteContent extends StatefulWidget {
  final GreenNote note;
  final Function(GreenNote) onSave;
  final VoidCallback onCancel;

  const EditGreenNoteContent({
    super.key,
    required this.note,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<EditGreenNoteContent> createState() => _EditGreenNoteContentState();
}

class _EditGreenNoteContentState extends State<EditGreenNoteContent> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _projectNameController;
  late TextEditingController _supplierNameController;
  late TextEditingController _departmentController;
  late TextEditingController _workOrderNoController;
  late TextEditingController _poNumberController;
  late TextEditingController _msmeController;
  late TextEditingController _activityTypeController;
  late TextEditingController _briefController;
  late TextEditingController _delayedDamagesController;
  late TextEditingController _documentsVerifiedController;
  late TextEditingController _milestoneRemarksController;
  late TextEditingController _deviationController;
  late TextEditingController _documentsDiscrepancyController;
  late TextEditingController _remarksController;
  late TextEditingController _auditorRemarksController;

  String? _selectedApprovalFor;
  String? _selectedExpenseCategoryType;
  String? _selectedNatureOfExpenses;
  String? _selectedStatus;
  String? _selectedProtestNote;
  String? _selectedWhetherContract;
  String? _selectedContractExtension;
  String? _selectedMilestoneAchieved;
  String? _selectedExpenseWithinContract;
  String? _selectedPaymentDeviation;
  String? _selectedDocumentsSubmitted;
  String? _selectedContractCompleted;

  final List<String> _approvalForOptions = [
    'APPROVAL_FOR_INVOICE',
    'APPROVAL_FOR_ADVANCE',
    'APPROVAL_FOR_ADHOC',
  ];

  final List<String> _expenseCategoryOptions = [
    'EXPENSE_CATEGORY_CAPITAL',
    'EXPENSE_CATEGORY_REVENUE',
    'EXPENSE_CATEGORY_OPERATIONAL',
    'EXPENSE_CATEGORY_ADMINISTRATIVE',
    'EXPENSE_CATEGORY_MAINTENANCE',
  ];

  final List<String> _natureOfExpensesOptions = [
    'NATURE_OHC_001_MANPOWER',
    'NATURE_OHC_002_STAFF_WELFARE',
    'NATURE_OHC_003_OFFICE_RENT_UTILITIES',
  ];

  final List<String> _statusOptions = [
    'STATUS_PENDING',
    'STATUS_APPROVED',
    'STATUS_REJECTED',
    'STATUS_DRAFT',
  ];

  final List<String> _yesNoOptions = ['YES', 'NO'];

  @override
  void initState() {
    super.initState();
    _projectNameController = TextEditingController(text: widget.note.projectName);
    _supplierNameController = TextEditingController(text: widget.note.supplierName);
    _departmentController = TextEditingController(text: widget.note.departmentName);
    _workOrderNoController = TextEditingController(text: widget.note.workOrderNo);
    _poNumberController = TextEditingController(text: widget.note.poNumber);
    _msmeController = TextEditingController(text: widget.note.msmeClassification);
    _activityTypeController = TextEditingController(text: widget.note.activityType);
    _briefController = TextEditingController(text: widget.note.briefOfGoodsServices);
    _delayedDamagesController = TextEditingController(text: widget.note.delayedDamages);
    _documentsVerifiedController = TextEditingController(text: widget.note.documentsVerified);
    _milestoneRemarksController = TextEditingController(text: widget.note.milestoneRemarks);
    _deviationController = TextEditingController(text: widget.note.specifyDeviation);
    _documentsDiscrepancyController = TextEditingController(text: widget.note.documentsDiscrepancy);
    _remarksController = TextEditingController(text: widget.note.remarks);
    _auditorRemarksController = TextEditingController(text: widget.note.auditorRemarks);

    _selectedApprovalFor = widget.note.approvalFor.isNotEmpty ? widget.note.approvalFor : _approvalForOptions.first;
    _selectedExpenseCategoryType = widget.note.expenseCategoryType.isNotEmpty ? widget.note.expenseCategoryType : _expenseCategoryOptions.first;
    _selectedNatureOfExpenses = widget.note.natureOfExpenses.isNotEmpty ? widget.note.natureOfExpenses : _natureOfExpensesOptions.first;
    _selectedStatus = widget.note.status.isNotEmpty ? widget.note.status : _statusOptions.first;
    
    _selectedProtestNote = _normalizeYesNo(widget.note.protestNoteRaised);
    _selectedWhetherContract = _normalizeYesNo(widget.note.whetherContract);
    _selectedContractExtension = _normalizeYesNo(widget.note.extensionOfContractPeriodExecuted);
    _selectedMilestoneAchieved = _normalizeYesNo(widget.note.milestoneAchieved);
    _selectedExpenseWithinContract = _normalizeYesNo(widget.note.expenseAmountWithinContract);
    _selectedPaymentDeviation = _normalizeYesNo(widget.note.paymentApprovedWithDeviation);
    _selectedDocumentsSubmitted = _normalizeYesNo(widget.note.requiredDocumentsSubmitted);
    _selectedContractCompleted = _normalizeYesNo(widget.note.contractPeriodCompleted);
  }

  String? _normalizeYesNo(String value) {
    if (value.toUpperCase() == 'YES') return 'YES';
    if (value.toUpperCase() == 'NO') return 'NO';
    return null;
  }

  @override
  void dispose() {
    _projectNameController.dispose();
    _supplierNameController.dispose();
    _departmentController.dispose();
    _workOrderNoController.dispose();
    _poNumberController.dispose();
    _msmeController.dispose();
    _activityTypeController.dispose();
    _briefController.dispose();
    _delayedDamagesController.dispose();
    _documentsVerifiedController.dispose();
    _milestoneRemarksController.dispose();
    _deviationController.dispose();
    _documentsDiscrepancyController.dispose();
    _remarksController.dispose();
    _auditorRemarksController.dispose();
    super.dispose();
  }

  void _saveNote() {
    if (_formKey.currentState?.validate() ?? false) {
      final updatedNote = GreenNote(
        id: widget.note.id,
        projectName: _projectNameController.text,
        supplierName: _supplierNameController.text,
        expenseCategory: widget.note.expenseCategory,
        protestNoteRaised: _selectedProtestNote ?? '',
        whetherContract: _selectedWhetherContract ?? '',
        extensionOfContractPeriodExecuted: _selectedContractExtension ?? '',
        expenseAmountWithinContract: _selectedExpenseWithinContract ?? '',
        milestoneAchieved: _selectedMilestoneAchieved ?? '',
        paymentApprovedWithDeviation: _selectedPaymentDeviation ?? '',
        requiredDocumentsSubmitted: _selectedDocumentsSubmitted ?? '',
        documentsVerified: _documentsVerifiedController.text,
        contractStartDate: widget.note.contractStartDate,
        contractEndDate: widget.note.contractEndDate,
        appointedStartDate: widget.note.appointedStartDate,
        supplyPeriodStart: widget.note.supplyPeriodStart,
        supplyPeriodEnd: widget.note.supplyPeriodEnd,
        baseValue: widget.note.baseValue,
        otherCharges: widget.note.otherCharges,
        gst: widget.note.gst,
        totalAmount: widget.note.totalAmount,
        enableMultipleInvoices: widget.note.enableMultipleInvoices,
        invoices: widget.note.invoices,
        status: _selectedStatus ?? widget.note.status,
        approvalFor: _selectedApprovalFor ?? widget.note.approvalFor,
        departmentName: _departmentController.text,
        workOrderNo: _workOrderNoController.text,
        poNumber: _poNumberController.text,
        workOrderDate: widget.note.workOrderDate,
        expenseCategoryType: _selectedExpenseCategoryType ?? widget.note.expenseCategoryType,
        msmeClassification: _msmeController.text,
        activityType: _activityTypeController.text,
        briefOfGoodsServices: _briefController.text,
        delayedDamages: _delayedDamagesController.text,
        natureOfExpenses: _selectedNatureOfExpenses ?? widget.note.natureOfExpenses,
        contractPeriodCompleted: _selectedContractCompleted ?? '',
        budgetExpenditure: widget.note.budgetExpenditure,
        actualExpenditure: widget.note.actualExpenditure,
        expenditureOverBudget: widget.note.expenditureOverBudget,
        milestoneRemarks: _milestoneRemarksController.text,
        specifyDeviation: _deviationController.text,
        documentsWorkdoneSupply: widget.note.documentsWorkdoneSupply,
        documentsDiscrepancy: _documentsDiscrepancyController.text,
        remarks: _remarksController.text,
        auditorRemarks: _auditorRemarksController.text,
        amountRetainedForNonSubmission: widget.note.amountRetainedForNonSubmission,
        createdAt: widget.note.createdAt,
        updatedAt: DateTime.now().toIso8601String(),
      );
      widget.onSave(updatedNote);
    }
  }

  String _getDropdownDisplayText(String value) {
    return value
        .replaceAll('EXPENSE_CATEGORY_', '')
        .replaceAll('APPROVAL_FOR_', '')
        .replaceAll('NATURE_OHC_001_', '')
        .replaceAll('NATURE_OHC_002_', '')
        .replaceAll('NATURE_OHC_003_', '')
        .replaceAll('STATUS_', '')
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, colorScheme, theme),
              const SizedBox(height: 16),
              _buildBasicInformationSection(context, colorScheme, theme),
              const SizedBox(height: 16),
              _buildComplianceSection(context, colorScheme, theme),
              const SizedBox(height: 16),
              _buildRemarksSection(context, colorScheme, theme),
              const SizedBox(height: 24),
              _buildActionButtons(context, colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme colorScheme, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.5),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.edit,
              size: 24,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit Expense Note',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Update expense note details and information',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          SecondaryButton(
            label: 'Back to Notes',
            icon: Icons.arrow_back,
            onPressed: widget.onCancel,
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInformationSection(BuildContext context, ColorScheme colorScheme, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.5),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info,
                color: colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Basic Information',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildInputField("Project Name *", _projectNameController, theme),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInputField("Supplier Name *", _supplierNameController, theme),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInputField("Department", _departmentController, theme),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdown("Approval For *", _selectedApprovalFor, _approvalForOptions, (value) {
                  setState(() => _selectedApprovalFor = value);
                }, theme),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInputField("Work Order No", _workOrderNoController, theme),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInputField("PO Number", _poNumberController, theme),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDropdown("Expense Category Type *", _selectedExpenseCategoryType, _expenseCategoryOptions, (value) {
                  setState(() => _selectedExpenseCategoryType = value);
                }, theme),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdown("Nature of Expenses *", _selectedNatureOfExpenses, _natureOfExpensesOptions, (value) {
                  setState(() => _selectedNatureOfExpenses = value);
                }, theme),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInputField("MSME Classification", _msmeController, theme, readOnly: true),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInputField("Activity Type", _activityTypeController, theme, readOnly: true),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDropdown("Status", _selectedStatus, _statusOptions, (value) {
                  setState(() => _selectedStatus = value);
                }, theme),
              ),
              const SizedBox(width: 16),
              Expanded(child: Container()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComplianceSection(BuildContext context, ColorScheme colorScheme, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.5),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.fact_check,
                color: colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Compliance & Verification',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildDropdown("Protest Note Raised", _selectedProtestNote, _yesNoOptions, (value) {
                  setState(() => _selectedProtestNote = value);
                }, theme),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdown("Whether Contract", _selectedWhetherContract, _yesNoOptions, (value) {
                  setState(() => _selectedWhetherContract = value);
                }, theme),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDropdown("Contract Extension", _selectedContractExtension, _yesNoOptions, (value) {
                  setState(() => _selectedContractExtension = value);
                }, theme),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdown("Milestone Achieved", _selectedMilestoneAchieved, _yesNoOptions, (value) {
                  setState(() => _selectedMilestoneAchieved = value);
                }, theme),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDropdown("Expense Within Contract", _selectedExpenseWithinContract, _yesNoOptions, (value) {
                  setState(() => _selectedExpenseWithinContract = value);
                }, theme),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdown("Payment With Deviation", _selectedPaymentDeviation, _yesNoOptions, (value) {
                  setState(() => _selectedPaymentDeviation = value);
                }, theme),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDropdown("Documents Submitted", _selectedDocumentsSubmitted, _yesNoOptions, (value) {
                  setState(() => _selectedDocumentsSubmitted = value);
                }, theme),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdown("Contract Completed", _selectedContractCompleted, _yesNoOptions, (value) {
                  setState(() => _selectedContractCompleted = value);
                }, theme),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInputField("Documents Verified", _documentsVerifiedController, theme),
          const SizedBox(height: 16),
          _buildInputField("Brief of Goods/Services", _briefController, theme, maxLines: 3),
          const SizedBox(height: 16),
          _buildInputField("Delayed Damages", _delayedDamagesController, theme),
        ],
      ),
    );
  }

  Widget _buildRemarksSection(BuildContext context, ColorScheme colorScheme, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.5),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.comment,
                color: colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Remarks & Comments',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildInputField("Milestone Remarks", _milestoneRemarksController, theme, maxLines: 3),
          const SizedBox(height: 16),
          _buildInputField("Specify Deviation", _deviationController, theme, maxLines: 3),
          const SizedBox(height: 16),
          _buildInputField("Documents Discrepancy", _documentsDiscrepancyController, theme, maxLines: 3),
          const SizedBox(height: 16),
          _buildInputField("Remarks", _remarksController, theme, maxLines: 3),
          const SizedBox(height: 16),
          _buildInputField("Auditor Remarks", _auditorRemarksController, theme, maxLines: 3),
        ],
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, ThemeData theme, {int maxLines = 1, bool readOnly = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          maxLines: maxLines,
          decoration: InputDecoration(
            filled: true,
            fillColor: readOnly ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5) : theme.colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.5)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          validator: label.contains('*') ? (value) {
            if (value == null || value.isEmpty) {
              return '$label is required';
            }
            return null;
          } : null,
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, String? value, List<String> options, Function(String?) onChanged, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            filled: true,
            fillColor: theme.colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.5)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          items: options.map((option) {
            return DropdownMenuItem<String>(
              value: option,
              child: Text(_getDropdownDisplayText(option)),
            );
          }).toList(),
          onChanged: onChanged,
          validator: label.contains('*') ? (value) {
            if (value == null || value.isEmpty) {
              return '$label is required';
            }
            return null;
          } : null,
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SecondaryButton(
          label: 'Cancel',
          icon: Icons.close,
          onPressed: widget.onCancel,
        ),
        const SizedBox(width: 12),
        PrimaryButton(
          label: 'Save Changes',
          icon: Icons.save,
          onPressed: _saveNote,
        ),
      ],
    );
  }
}
