import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:ppv_components/common_widgets/button/primary_button.dart';
import 'package:ppv_components/common_widgets/button/secondary_button.dart';
import '../models/green_note_model.dart';
import '../services/green_note_service.dart';
import '../services/green_note_api_client.dart';

// Form Section Model
class FormSection {
  final String title;
  final IconData icon;
  final List<FormFieldConfig> fields;

  FormSection({
    required this.title,
    required this.icon,
    required this.fields,
  });
}

// Form Field Configuration
class FormFieldConfig {
  final String label;
  final String name;
  final FormFieldType type;
  final List<String>? options;
  final String? Function(String?)? validator;
  final bool? readOnly;
  final int? maxLines;

  FormFieldConfig({
    required this.label,
    required this.name,
    required this.type,
    this.options,
    this.validator,
    this.readOnly,
    this.maxLines,
  });
}

enum FormFieldType {
  text,
  dropdown,
  date,
  file,
}

class _InvoiceEntry {
  final TextEditingController invoiceNumberController = TextEditingController();
  final TextEditingController invoiceDateController = TextEditingController();
  final TextEditingController baseValueController = TextEditingController();
  final TextEditingController gstController = TextEditingController();
  final TextEditingController otherChargesController = TextEditingController();
  final TextEditingController totalValueController = TextEditingController(text: '0.00');
  final TextEditingController descriptionController = TextEditingController();

  void dispose() {
    invoiceNumberController.dispose();
    invoiceDateController.dispose();
    baseValueController.dispose();
    gstController.dispose();
    otherChargesController.dispose();
    totalValueController.dispose();
    descriptionController.dispose();
  }
}

// All Form Sections with Data
final List<FormSection> expenseFormSections = [
  FormSection(
    title: 'Basic Information',
    icon: Icons.info_outline,
    fields: [
      FormFieldConfig(
        label: 'Approval For',
        type: FormFieldType.dropdown,
        name: 'approvalFor',
        options: ['Invoice', 'Advance', 'Adhoc'],
        validator: (value) =>
        value == null || value.isEmpty ? 'Approval type required' : null,
      ),
      FormFieldConfig(
        label: 'Project Name',
        type: FormFieldType.dropdown,
        name: 'projectName',
        options: [
          'Abu Road',
          'Palanpur',
          'Vadodara',
          'Surat',
          'Rajkot',
          'Nanded',
          'Aurangabad',
          'Corporate Office Mumbai',
          'Corporate Office Delhi',
          'Other',
        ],
        validator: (value) =>
        value == null || value.isEmpty ? 'Project name required' : null,
      ),
    ],
  ),
  FormSection(
    title: 'Project Details',
    icon: Icons.folder_outlined,
    fields: [
      FormFieldConfig(
        label: 'User Department',
        type: FormFieldType.text,
        name: 'userDepartment',
        validator: (value) =>
        value == null || value.isEmpty ? 'Department required' : null,
      ),
      FormFieldConfig(
        label: 'Work/Purchase Order No.',
        type: FormFieldType.text,
        name: 'workPoNo',
        validator: (value) =>
        value == null || value.isEmpty ? 'PO number required' : null,
      ),
      FormFieldConfig(
        label: 'PO Number (if different from Order No.)',
        type: FormFieldType.text,
        name: 'poMemberDifferent',
        validator: (value) => null,
      ),
      FormFieldConfig(
        label: 'Work/Purchase Order Date',
        type: FormFieldType.date,
        name: 'workPoDate',
        validator: (value) =>
        value == null || value.isEmpty ? 'Date required' : null,
      ),
      FormFieldConfig(
        label: 'Expense Category Type *',
        type: FormFieldType.dropdown,
        name: 'expenseCategoryType',
        options: [
          'Select Expense Category',
          'EXPENSE_CATEGORY_CAPITAL',
          'EXPENSE_CATEGORY_REVENUE',
          'EXPENSE_CATEGORY_OPERATIONAL',
          'EXPENSE_CATEGORY_ADMINISTRATIVE',
          'EXPENSE_CATEGORY_MAINTENANCE',
        ],
        validator: (value) => value == null || value.isEmpty || value == 'Select Expense Category' 
            ? 'Expense Category is required' : null,
      ),
    ],
  ),
  FormSection(
    title: 'Financial Details',
    icon: Icons.account_balance_wallet_outlined,
    fields: [
      FormFieldConfig(
        label: 'Base Value',
        type: FormFieldType.text,
        name: 'orderBaseValue',
        validator: (value) => null,
      ),
      FormFieldConfig(
        label: 'Invoice Number',
        type: FormFieldType.text,
        name: 'invoiceNumber',
        validator: (value) => null,
      ),
      FormFieldConfig(
        label: 'Other Charges',
        type: FormFieldType.text,
        name: 'orderOtherCharges',
        validator: (value) => null,
      ),
      FormFieldConfig(
        label: 'Invoice Date',
        type: FormFieldType.date,
        name: 'invoiceDate',
        validator: (value) => null,
      ),
      FormFieldConfig(
        label: 'GST on Above',
        type: FormFieldType.text,
        name: 'orderGST',
        validator: (value) => null,
      ),
      FormFieldConfig(
        label: 'Taxable Value',
        type: FormFieldType.text,
        name: 'taxableValue',
        validator: (value) => null,
      ),
      FormFieldConfig(
        label: 'Total Amount',
        type: FormFieldType.text,
        name: 'totalAmount',
        validator: (value) => null,
        readOnly: true,
      ),
      FormFieldConfig(
        label: 'Add: GST on above',
        type: FormFieldType.text,
        name: 'addedGST',
        validator: (value) => null,
      ),
      FormFieldConfig(
        label: 'Invoice Other Charges',
        type: FormFieldType.text,
        name: 'invoiceOtherCharges',
        validator: (value) => null,
      ),
      FormFieldConfig(
        label: 'Invoice Value',
        type: FormFieldType.text,
        name: 'invoiceValue',
        validator: (value) => null,
      ),
    ],
  ),
  FormSection(
    title: 'Supplier & Classification',
    icon: Icons.business_outlined,
    fields: [
      FormFieldConfig(
        label: 'Name of Supplier *',
        type: FormFieldType.text,
        name: 'supplierName',
        validator: (value) =>
        value == null || value.isEmpty ? 'Supplier required' : null,
      ),
      FormFieldConfig(
        label: 'MSME Classification',
        type: FormFieldType.text,
        name: 'msmeClassification',
        validator: (value) => null,
        readOnly: true,
      ),
      FormFieldConfig(
        label: 'Activity Type',
        type: FormFieldType.text,
        name: 'activityType',
        validator: (value) => null,
        readOnly: true,
      ),
    ],
  ),
  FormSection(
    title: 'Contract Details',
    icon: Icons.description_outlined,
    fields: [
      FormFieldConfig(
        label: 'Whether Contract',
        type: FormFieldType.dropdown,
        name: 'whetherContract',
        options: ['Select', 'YES', 'NO'],
        validator: (value) => null,
      ),
      FormFieldConfig(
        label: 'Contract Period Start Date',
        type: FormFieldType.date,
        name: 'contractStartDate',
        validator: (value) => null,
      ),
      FormFieldConfig(
        label: 'Appointed Start Date',
        type: FormFieldType.date,
        name: 'appointedDate',
        validator: (value) => null,
      ),
      FormFieldConfig(
        label: 'End Date',
        type: FormFieldType.date,
        name: 'appointedEndDate',
        validator: (value) => null,
      ),
      FormFieldConfig(
        label: 'Contract Period Completed',
        type: FormFieldType.dropdown,
        name: 'contractCompleted',
        options: ['Select', 'YES', 'NO'],
        validator: (value) => null,
      ),
      FormFieldConfig(
        label: 'Period of Supply Start Date',
        type: FormFieldType.date,
        name: 'supplyStartDate',
        validator: (value) => null,
      ),
      FormFieldConfig(
        label: 'End Date',
        type: FormFieldType.date,
        name: 'supplyEndDate',
        validator: (value) => null,
      ),
    ],
  ),
  FormSection(
    title: 'Additional Information',
    icon: Icons.add_circle_outline,
    fields: [
      FormFieldConfig(
        label: 'Protest Note Raised',
        type: FormFieldType.dropdown,
        name: 'protestNote',
        options: ['Select', 'YES', 'NO'],
        validator: (value) => null,
      ),
      FormFieldConfig(
        label: 'Choose File (No file chosen)',
        type: FormFieldType.file,
        name: 'protestNoteFile',
        validator: (value) => null,
      ),
      FormFieldConfig(
        label: 'Brief of Goods / Services',
        type: FormFieldType.text,
        name: 'goodsBrief',
        validator: (value) => null,
        maxLines: 3,
      ),
      FormFieldConfig(
        label: 'Delayed damages',
        type: FormFieldType.text,
        name: 'delayedDamages',
        validator: (value) => null,
      ),
      FormFieldConfig(
        label: 'Select Nature of Expenses *',
        type: FormFieldType.dropdown,
        name: 'natureOfExpenses',
        options: [
          'Select Nature of Expenses',
          'NATURE_OHC_001_MANPOWER',
          'NATURE_OHC_002_STAFF_WELFARE',
          'NATURE_OHC_003_OFFICE_RENT_UTILITIES',
        ],
        validator: (value) => value == null || value.isEmpty || value == 'Select Nature of Expenses'
            ? 'Nature of Expenses is required' : null,
      ),
    ],
  ),
  FormSection(
    title: 'Budget Information',
    icon: Icons.pie_chart_outline,
    fields: [
      FormFieldConfig(
        label: 'Budget Expenditure',
        type: FormFieldType.text,
        name: 'budgetExpenditure',
        validator: (value) => null,
      ),
      FormFieldConfig(
        label: 'Actual Expenditure',
        type: FormFieldType.text,
        name: 'actualExpenditure',
        validator: (value) => null,
      ),
      FormFieldConfig(
        label: 'Expenditure over Budget',
        type: FormFieldType.text,
        name: 'expenditureOverBudget',
        validator: (value) => null,
        readOnly: true,
      ),
    ],
  ),
  FormSection(
    title: 'Contract Extension & Compliance',
    icon: Icons.fact_check_outlined,
    fields: [
      FormFieldConfig(
        label: 'Extension of contract period executed',
        type: FormFieldType.dropdown,
        name: 'contractExtension',
        options: ['Select', 'YES', 'NO'],
        validator: (value) => null,
      ),
      FormFieldConfig(
        label: 'Milestone Status - Achieved?',
        type: FormFieldType.dropdown,
        name: 'milestoneAchieved',
        options: ['Select', 'YES', 'NO'],
        validator: (value) => null,
      ),
      FormFieldConfig(
        label: 'Milestone Remarks (if any)',
        type: FormFieldType.text,
        name: 'milestoneRemarks',
        validator: (value) => null,
        maxLines: 2,
      ),
      FormFieldConfig(
        label: 'Choose File',
        type: FormFieldType.file,
        name: 'milestoneFile',
        validator: (value) => null,
      ),
      FormFieldConfig(
        label: 'Expense Amount within contract',
        type: FormFieldType.dropdown,
        name: 'expenseWithinContract',
        options: ['Select', 'YES', 'NO'],
        validator: (value) => null,
      ),
      FormFieldConfig(
        label: 'If payment approved with Deviation',
        type: FormFieldType.dropdown,
        name: 'paymentWithDeviation',
        options: ['Select', 'YES', 'NO'],
        validator: (value) => null,
      ),
      FormFieldConfig(
        label: 'Specify deviation (if any)',
        type: FormFieldType.text,
        name: 'deviationRemarks',
        validator: (value) => null,
        maxLines: 2,
      ),
      FormFieldConfig(
        label: 'Deviation Supporting Document',
        type: FormFieldType.file,
        name: 'deviationFile',
        validator: (value) => null,
      ),
    ],
  ),
  FormSection(
    title: 'HR Department (Optional)',
    icon: Icons.people_outline,
    fields: [
      FormFieldConfig(
        label: 'Documents Verified for Period of Workman/Supply',
        type: FormFieldType.text,
        name: 'documentsVerified',
        validator: (value) => null,
      ),
      FormFieldConfig(
        label: 'Whether All Documents Required Submitted',
        type: FormFieldType.dropdown,
        name: 'documentsSubmitted',
        options: ['Select', 'YES', 'NO'],
        validator: (value) => null,
      ),
      FormFieldConfig(
        label: 'Documents Discrepancy',
        type: FormFieldType.text,
        name: 'documentsDiscrepancy',
        validator: (value) => null,
        maxLines: 2,
      ),
      FormFieldConfig(
        label: 'Amount to be Retained for Non-Submission/Non-Compliance',
        type: FormFieldType.text,
        name: 'amountRetained',
        validator: (value) => null,
      ),
      FormFieldConfig(
        label: 'Remarks (If any)',
        type: FormFieldType.text,
        name: 'hrRemarks',
        validator: (value) => null,
        maxLines: 3,
      ),
      FormFieldConfig(
        label: 'Attachment (If any)',
        type: FormFieldType.file,
        name: 'hrAttachment',
        validator: (value) => null,
      ),
      FormFieldConfig(
        label: 'Auditor Remarks (If any)',
        type: FormFieldType.text,
        name: 'auditorRemarks',
        validator: (value) => null,
        maxLines: 3,
      ),
      FormFieldConfig(
        label: 'Remarks (If any)',
        type: FormFieldType.text,
        name: 'remarks',
        validator: (value) => null,
        maxLines: 3,
      ),
    ],
  ),
];

// Main Page Widget
class CreateNotePage extends StatefulWidget {
  const CreateNotePage({super.key});

  @override
  State<CreateNotePage> createState() => _CreateNotePageState();
}

class _CreateNotePageState extends State<CreateNotePage> {
  final Map<String, dynamic> _formValues = {};
  final Map<String, TextEditingController> _controllers = {};
  final _formKey = GlobalKey<FormState>();
  final Map<int, bool> _expandedSections = {};
  bool _multipleInvoicesEnabled = false;
  final List<_InvoiceEntry> _invoiceEntries = [];
  
  // Backend API integration
  final GreenNoteService _greenNoteService = GreenNoteService();
  bool _isSubmitting = false;
  
  // Financial Details Controllers
  final Map<String, TextEditingController> _financialControllers = {
    'orderBaseValue': TextEditingController(),
    'orderOtherCharges': TextEditingController(),
    'orderGST': TextEditingController(),
    'totalAmount': TextEditingController(text: '0.00'),
    'invoiceNumber': TextEditingController(),
    'invoiceDate': TextEditingController(),
    'taxableValue': TextEditingController(),
    'addedGST': TextEditingController(),
    'invoiceOtherCharges': TextEditingController(),
    'invoiceValue': TextEditingController(text: '0.00'),
  };
  TextEditingController _finCtrl(String key) => _financialControllers[key]!;
  late final TextEditingController _budgetExpenditureController;
  late final TextEditingController _actualExpenditureController;
  late final TextEditingController _expenditureOverBudgetController;
  String _budgetStatus = '(On Budget)';
  Color _budgetStatusColor = Colors.grey;

  PlatformFile? _contractExtensionFile;
  PlatformFile? _deviationFile;
  PlatformFile? _hrAttachmentFile;
  PlatformFile? _protestNoteFile;
  
  // Supplier auto-mapping state
  bool _isLoadingSupplier = false;
  String? _supplierError;

  void _resetForm() {
    _formKey.currentState?.reset();
    _formValues.clear();
    for (final controller in _controllers.values) {
      controller
        ..text = ''
        ..clear();
    }
    setState(() {
      _multipleInvoicesEnabled = false;
      _contractExtensionFile = null;
      _deviationFile = null;
      _hrAttachmentFile = null;
      _protestNoteFile = null;
      _invoiceEntries.clear();
    });
  }

  Future<void> _submitGreenNote() async {
    // Comprehensive validation
    final validationErrors = <String>[];
    
    // Required field validation
    if ((_formValues['approvalFor'] ?? _controllers['approvalFor']?.text ?? '').isEmpty) {
      validationErrors.add('Approval For is required');
    }
    if ((_formValues['projectName'] ?? _controllers['projectName']?.text ?? '').isEmpty) {
      validationErrors.add('Project Name is required');
    }
    if ((_formValues['userDepartment'] ?? _controllers['userDepartment']?.text ?? '').isEmpty) {
      validationErrors.add('User Department is required');
    }
    if ((_controllers['workPoNo']?.text ?? '').isEmpty) {
      validationErrors.add('Work/Purchase Order No. is required');
    }
    if ((_controllers['workPoDate']?.text ?? '').isEmpty) {
      validationErrors.add('Work/Purchase Order Date is required');
    }
    if ((_controllers['supplierName']?.text ?? '').isEmpty) {
      validationErrors.add('Supplier Name is required');
    }
    
    // Expense Category Type validation
    final expenseCategoryType = _formValues['expenseCategoryType'] ?? '';
    if (expenseCategoryType.isEmpty || expenseCategoryType == 'Select Expense Category') {
      validationErrors.add('Expense Category Type is required');
    }
    
    // Nature of Expenses validation
    final natureOfExpenses = _formValues['natureOfExpenses'] ?? _controllers['natureOfExpenses']?.text ?? '';
    if (natureOfExpenses.isEmpty || natureOfExpenses == 'Select Nature of Expenses') {
      validationErrors.add('Nature of Expenses is required');
    }
    
    // Invoice validation
    if (_multipleInvoicesEnabled) {
      if (_invoiceEntries.isEmpty) {
        validationErrors.add('At least one invoice is required when multiple invoices is enabled');
      } else {
        for (int i = 0; i < _invoiceEntries.length; i++) {
          final entry = _invoiceEntries[i];
          if (entry.invoiceNumberController.text.trim().isEmpty) {
            validationErrors.add('Invoice ${i + 1}: Invoice Number is required');
          }
          if (entry.invoiceDateController.text.trim().isEmpty) {
            validationErrors.add('Invoice ${i + 1}: Invoice Date is required');
          }
          final invoiceValue = double.tryParse(entry.totalValueController.text);
          if (invoiceValue == null || invoiceValue <= 0) {
            validationErrors.add('Invoice ${i + 1}: Invoice Value must be greater than zero');
          }
        }
      }
    } else {
      // Single invoice validation
      if ((_financialControllers['invoiceNumber']?.text ?? '').isEmpty) {
        validationErrors.add('Invoice Number is required');
      }
      final invoiceValue = double.tryParse(_financialControllers['invoiceValue']?.text ?? '0');
      if (invoiceValue == null || invoiceValue <= 0) {
        validationErrors.add('Invoice Value must be greater than zero');
      }
    }
    
    // Date validation
    final contractEndDate = _controllers['appointedEndDate']?.text ?? '';
    if (contractEndDate.isEmpty) {
      validationErrors.add('Contract End Date is required');
    }
    
    if (validationErrors.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(validationErrors.join('\n')),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 5),
        ),
      );
      return;
    }
    
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill all required fields'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Build invoices list
      final List<Invoice> invoices = [];
      if (_multipleInvoicesEnabled && _invoiceEntries.isNotEmpty) {
        for (final entry in _invoiceEntries) {
          invoices.add(Invoice(
            invoiceNumber: entry.invoiceNumberController.text.trim(),
            invoiceDate: _formatDateForApi(entry.invoiceDateController.text.trim()),
            taxableValue: double.tryParse(entry.baseValueController.text) ?? 0,
            gst: double.tryParse(entry.gstController.text) ?? 0,
            otherCharges: double.tryParse(entry.otherChargesController.text) ?? 0,
            invoiceValue: double.tryParse(entry.totalValueController.text) ?? 0,
          ));
        }
      } else {
        // Single invoice from financial details
        invoices.add(Invoice(
          invoiceNumber: _financialControllers['invoiceNumber']!.text.trim(),
          invoiceDate: _formatDateForApi(_financialControllers['invoiceDate']!.text.trim()),
          taxableValue: double.tryParse(_financialControllers['taxableValue']!.text) ?? 0,
          gst: double.tryParse(_financialControllers['addedGST']!.text) ?? 0,
          otherCharges: double.tryParse(_financialControllers['invoiceOtherCharges']!.text) ?? 0,
          invoiceValue: double.tryParse(_financialControllers['invoiceValue']!.text) ?? 0,
        ));
      }

      // Map approval_for enum - EXACT backend match
      String approvalForValue = 'APPROVAL_FOR_INVOICE';
      final approvalFor = _formValues['approvalFor'] ?? _controllers['approvalFor']?.text ?? 'Invoice';
      if (approvalFor.toLowerCase().contains('invoice')) approvalForValue = 'APPROVAL_FOR_INVOICE';
      else if (approvalFor.toLowerCase().contains('advance')) approvalForValue = 'APPROVAL_FOR_ADVANCE';
      else if (approvalFor.toLowerCase().contains('adhoc')) approvalForValue = 'APPROVAL_FOR_ADHOC';

      // Get expense_category_type directly from dropdown - EXACT backend match
      String expenseCategoryTypeValue = _formValues['expenseCategoryType'] ?? 'EXPENSE_CATEGORY_OPERATIONAL';
      if (expenseCategoryTypeValue == 'Select Expense Category') {
        expenseCategoryTypeValue = 'EXPENSE_CATEGORY_OPERATIONAL';
      }
      
      // Map expense_category text from enum for display
      String expenseCategoryText = '';
      switch (expenseCategoryTypeValue) {
        case 'EXPENSE_CATEGORY_CAPITAL':
          expenseCategoryText = 'Capital';
          break;
        case 'EXPENSE_CATEGORY_REVENUE':
          expenseCategoryText = 'Revenue';
          break;
        case 'EXPENSE_CATEGORY_OPERATIONAL':
          expenseCategoryText = 'Operational';
          break;
        case 'EXPENSE_CATEGORY_ADMINISTRATIVE':
          expenseCategoryText = 'Administrative';
          break;
        case 'EXPENSE_CATEGORY_MAINTENANCE':
          expenseCategoryText = 'Maintenance';
          break;
      }

      // Get nature_of_expenses directly from dropdown - EXACT backend match
      String natureOfExpensesValue = _formValues['natureOfExpenses'] ?? _controllers['natureOfExpenses']?.text ?? 'NATURE_OHC_001_MANPOWER';
      if (natureOfExpensesValue == 'Select Nature of Expenses') {
        natureOfExpensesValue = 'NATURE_OHC_001_MANPOWER';
      }

      // Helper function to map YesNo dropdown values to backend enum
      String mapYesNoEnum(String? value) {
        if (value == null || value.isEmpty || value == 'Select') return '';
        return value.toUpperCase(); // YES or NO
      }

      // Build GreenNote object - NO DEFAULT VALUES, send empty strings for NULL prevention
      final greenNote = GreenNote(
        projectName: _formValues['projectName'] ?? _controllers['projectName']?.text ?? '',
        supplierName: _controllers['supplierName']?.text ?? '',
        expenseCategory: expenseCategoryText,
        protestNoteRaised: mapYesNoEnum(_formValues['protestNote']),
        whetherContract: mapYesNoEnum(_formValues['whetherContract']),
        extensionOfContractPeriodExecuted: mapYesNoEnum(_formValues['contractExtension']),
        expenseAmountWithinContract: mapYesNoEnum(_formValues['expenseWithinContract']),
        milestoneAchieved: mapYesNoEnum(_formValues['milestoneAchieved']),
        paymentApprovedWithDeviation: mapYesNoEnum(_formValues['paymentWithDeviation']),
        requiredDocumentsSubmitted: mapYesNoEnum(_formValues['documentsSubmitted']),
        documentsVerified: _controllers['documentsVerified']?.text ?? '',
        contractStartDate: _formatDateForApi(_controllers['contractStartDate']?.text ?? ''),
        contractEndDate: _formatDateForApi(_controllers['appointedEndDate']?.text ?? ''),
        appointedStartDate: _formatDateForApi(_controllers['appointedDate']?.text ?? ''),
        supplyPeriodStart: _formatDateForApi(_controllers['supplyStartDate']?.text ?? ''),
        supplyPeriodEnd: _formatDateForApi(_controllers['supplyEndDate']?.text ?? ''),
        baseValue: double.tryParse(_financialControllers['orderBaseValue']?.text ?? '') ?? 0.0,
        otherCharges: double.tryParse(_financialControllers['orderOtherCharges']?.text ?? '') ?? 0.0,
        gst: double.tryParse(_financialControllers['orderGST']?.text ?? '') ?? 0.0,
        totalAmount: double.tryParse(_financialControllers['totalAmount']?.text ?? '') ?? 0.0,
        enableMultipleInvoices: _multipleInvoicesEnabled,
        invoices: invoices,
        status: 'STATUS_PENDING',
        approvalFor: approvalForValue,
        departmentName: _controllers['userDepartment']?.text.trim() ?? '',
        workOrderNo: _controllers['workPoNo']?.text.trim() ?? '',
        poNumber: _controllers['poMemberDifferent']?.text.trim() ?? '',
        workOrderDate: _formatDateForApi(_controllers['workPoDate']?.text ?? ''),
        expenseCategoryType: expenseCategoryTypeValue,
        msmeClassification: _controllers['msmeClassification']?.text ?? '',
        activityType: _controllers['activityType']?.text ?? '',
        briefOfGoodsServices: _controllers['goodsBrief']?.text ?? '',
        delayedDamages: _controllers['delayedDamages']?.text ?? '',
        natureOfExpenses: natureOfExpensesValue,
        contractPeriodCompleted: mapYesNoEnum(_formValues['contractCompleted']),
        budgetExpenditure: double.tryParse(_budgetExpenditureController.text) ?? 0.0,
        actualExpenditure: double.tryParse(_actualExpenditureController.text) ?? 0.0,
        expenditureOverBudget: double.tryParse(_expenditureOverBudgetController.text) ?? 0.0,
        milestoneRemarks: _controllers['milestoneRemarks']?.text ?? '',
        specifyDeviation: _controllers['deviationRemarks']?.text ?? '',
        documentsWorkdoneSupply: _controllers['documentsVerified']?.text ?? '',
        documentsDiscrepancy: _controllers['documentsDiscrepancy']?.text ?? '',
        remarks: _controllers['hrRemarks']?.text ?? '',
        auditorRemarks: _controllers['auditorRemarks']?.text ?? '',
        amountRetainedForNonSubmission: double.tryParse(_controllers['amountRetained']?.text ?? '') ?? 0.0,
      );

      print('📤 Submitting Green Note to API...');
      print('🔍 Debug - Department Name: ${_formValues['userDepartment']}');
      print('🔍 Debug - Work Order No: ${_controllers['workPoNo']?.text}');
      print('🔍 Debug - PO Number: ${_controllers['poMemberDifferent']?.text}');
      print('Payload: ${greenNote.toJson()}');

      // Call backend API
      final createdNote = await _greenNoteService.createGreenNote(greenNote);

      print('✅ Green Note created successfully: ${createdNote.id}');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Green Note created successfully! ID: ${createdNote.id}'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
        _resetForm();
        // Navigate to all notes page to view the created note
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            context.go('/expense/all-notes');
          }
        });
      }
    } catch (e) {
      print('❌ Error creating Green Note: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create Green Note: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  String _formatDateForApi(String dateStr) {
    if (dateStr.isEmpty) return '';
    try {
      // Handle DD-MM-YYYY or DD/MM/YYYY format
      final parts = dateStr.split(RegExp(r'[-/]'));
      if (parts.length == 3) {
        final day = parts[0].padLeft(2, '0');
        final month = parts[1].padLeft(2, '0');
        final year = parts[2];
        return '$year-$month-$day'; // YYYY-MM-DD
      }
      return dateStr;
    } catch (e) {
      return dateStr;
    }
  }

  @override
  void initState() {
    super.initState();
    // Initialize API client
    GreenNoteApiClient().initialize();
    
    // Initialize all sections as expanded
    for (int i = 0; i < expenseFormSections.length; i++) {
      _expandedSections[i] = true;
    }
    // Initialize controllers for all fields
    for (var section in expenseFormSections) {
      for (var field in section.fields) {
        _controllers[field.name] = TextEditingController();
      }
    }

    _budgetExpenditureController = _controllers['budgetExpenditure']!;
    _actualExpenditureController = _controllers['actualExpenditure']!;
    _expenditureOverBudgetController = _controllers['expenditureOverBudget']!;
    _expenditureOverBudgetController.text = '0.00';
    
    // Add listeners for real-time calculations
    _financialControllers['orderBaseValue']!.addListener(_calculateTotalAmount);
    _financialControllers['orderOtherCharges']!.addListener(_calculateTotalAmount);
    _financialControllers['orderGST']!.addListener(_calculateTotalAmount);

    _financialControllers['taxableValue']!.addListener(_calculateInvoiceValue);
    _financialControllers['addedGST']!.addListener(_calculateInvoiceValue);
    _financialControllers['invoiceOtherCharges']!.addListener(_calculateInvoiceValue);

    _budgetExpenditureController.addListener(_calculateBudgetDifference);
    _actualExpenditureController.addListener(_calculateBudgetDifference);
    
    // Add listeners for multiple invoice calculations
    for (final entry in _invoiceEntries) {
      _addInvoiceListeners(entry);
    }
    
    // Add listener for supplier name to trigger auto-mapping
    _controllers['supplierName']?.addListener(_onSupplierNameChanged);
  }
  
  void _onSupplierNameChanged() {
    final supplierName = _controllers['supplierName']?.text ?? '';
    if (supplierName.length >= 3) {
      // Debounce: only fetch after user stops typing for 500ms
      Future.delayed(const Duration(milliseconds: 500), () {
        if (supplierName == _controllers['supplierName']?.text) {
          _fetchSupplierDetails(supplierName);
        }
      });
    }
  }
  
  Future<void> _fetchSupplierDetails(String supplierName) async {
    setState(() {
      _isLoadingSupplier = true;
      _supplierError = null;
    });
    
    try {
      // TODO: Replace with actual supplier API endpoint when available
      // For now, using mock logic based on supplier name
      // GET /suppliers?name={supplier_name}
      
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Mock supplier data mapping
      // Replace this with actual API call:
      // final response = await _greenNoteService.getSupplierByName(supplierName);
      
      String msmeClassification = 'Non-MSME';
      String activityType = 'Services';
      
      // Mock mapping logic (replace with actual API response)
      if (supplierName.toLowerCase().contains('national highways')) {
        msmeClassification = 'Non-MSME';
        activityType = 'Consultancy';
      } else if (supplierName.toLowerCase().contains('surya')) {
        msmeClassification = 'MSE';
        activityType = 'Supply';
      }
      
      setState(() {
        _controllers['msmeClassification']?.text = msmeClassification;
        _controllers['activityType']?.text = activityType;
        _isLoadingSupplier = false;
      });
    } catch (e) {
      setState(() {
        _supplierError = 'Supplier not found';
        _controllers['msmeClassification']?.text = '';
        _controllers['activityType']?.text = '';
        _isLoadingSupplier = false;
      });
    }
  }

  Widget _buildHrDepartmentContent(
    BuildContext context,
    FormSection section,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Future<void> pickHrAttachment() async {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['pdf', 'doc', 'docx', 'xls', 'xlsx'],
      );
      if (result != null && result.files.isNotEmpty) {
        final picked = result.files.first;
        setState(() {
          _hrAttachmentFile = picked;
          _controllers['hrAttachment']?.text = picked.name;
        });
      }
    }

    Widget buildField(String name) {
      final config = _getFieldConfig(section, name);
      if (config == null) return const SizedBox.shrink();
      return _buildFormField(context, config);
    }

    Widget attachmentPicker() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Attachment (if any)',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: pickHrAttachment,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Choose File',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _hrAttachmentFile?.name ?? 'No file chosen',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'PDF, DOC, XLS max 10MB',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      );
    }

    List<Widget> withSpacing(List<Widget> children) {
      return [
        for (int i = 0; i < children.length; i++)
          Padding(
            padding: EdgeInsets.only(bottom: i == children.length - 1 ? 0 : 16),
            child: children[i],
          ),
      ];
    }

    final leftColumn = withSpacing([
      buildField('documentsVerified'),
      buildField('documentsDiscrepancy'),
      buildField('hrRemarks'),
      buildField('auditorRemarks'),
    ]);

    final rightColumn = withSpacing([
      buildField('documentsSubmitted'),
      buildField('amountRetained'),
      attachmentPicker(),
    ]);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 900;
        if (isSmallScreen) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...leftColumn,
              const SizedBox(height: 16),
              ...rightColumn,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: leftColumn,
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: rightColumn,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildContractExtensionContent(
    BuildContext context,
    FormSection section,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Future<void> selectFile(String controllerKey, ValueSetter<PlatformFile?> setter) async {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['pdf', 'doc', 'docx', 'xls', 'xlsx'],
      );
      if (result != null && result.files.isNotEmpty) {
        final picked = result.files.first;
        setState(() {
          setter(picked);
          _controllers[controllerKey]?.text = picked.name;
        });
      }
    }

    Widget buildField(String name) {
      final config = _getFieldConfig(section, name);
      if (config == null) return const SizedBox.shrink();
      return SizedBox(width: double.infinity, child: _buildFormField(context, config));
    }

    Widget buildFilePicker({
      required String controllerKey,
      required String label,
      required PlatformFile? file,
      required ValueSetter<PlatformFile?> setter,
      String? helperText,
    }) {
      return SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => selectFile(controllerKey, setter),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Choose File',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        file?.name ?? 'No file chosen',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (helperText != null) ...[
              const SizedBox(height: 6),
              Text(
                helperText,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ],
        ),
      );
    }

    Widget buildColumn(List<Widget> widgets) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < widgets.length; i++) ...[
            if (i != 0) const SizedBox(height: 16),
            widgets[i],
          ],
        ],
      );
    }

    final leftColumnWidgets = [
      buildField('contractExtension'),
      buildFilePicker(
        controllerKey: 'milestoneFile',
        label: 'Upload supporting document (contract extension)',
        file: _contractExtensionFile,
        setter: (file) => _contractExtensionFile = file,
        helperText:
            'Upload supporting document if extension is Yes (PDF, DOC, XLS max 10MB)',
      ),
      buildField('expenseWithinContract'),
      buildField('deviationRemarks'),
    ];

    final rightColumnWidgets = [
      buildField('milestoneAchieved'),
      buildField('milestoneRemarks'),
      buildField('paymentWithDeviation'),
      buildFilePicker(
        controllerKey: 'deviationFile',
        label: 'Upload supporting document (deviation)',
        file: _deviationFile,
        setter: (file) => _deviationFile = file,
        helperText:
            'Upload supporting document if deviations is Yes (PDF, DOC, XLS max 10MB)',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 900;

        if (isSmallScreen) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildColumn(leftColumnWidgets),
              const SizedBox(height: 16),
              buildColumn(rightColumnWidgets),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: buildColumn(leftColumnWidgets)),
            const SizedBox(width: 24),
            Expanded(child: buildColumn(rightColumnWidgets)),
          ],
        );
      },
    );
  }

  Widget _buildContractDetailsContent(
    BuildContext context,
    FormSection section,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    const contractFields = [
      'contractStartDate',
      'appointedDate',
      'appointedEndDate',
    ];
    const supplyFields = [
      'supplyStartDate',
      'supplyEndDate',
      'contractCompleted',
    ];

    Widget buildColumn(String title, List<String> fieldNames) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            ...List.generate(fieldNames.length, (index) {
              final name = fieldNames[index];
              final fieldConfig = _getFieldConfig(section, name);
              if (fieldConfig == null) return const SizedBox.shrink();
              return Padding(
                padding: EdgeInsets.only(bottom: index == fieldNames.length - 1 ? 0 : 16),
                child: _buildFormField(context, fieldConfig),
              );
            }),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 900;
        if (isSmallScreen) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildColumn('Contract Period', contractFields),
              const SizedBox(height: 16),
              buildColumn('Supply Period', supplyFields),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: buildColumn('Contract Period', contractFields)),
            const SizedBox(width: 32),
            Expanded(child: buildColumn('Supply Period', supplyFields)),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    // Dispose all controllers
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    for (final entry in _invoiceEntries) {
      entry.dispose();
    }
    for (final controller in _financialControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
  
  void _calculateTotalAmount() {
    final baseValue = double.tryParse(_financialControllers['orderBaseValue']?.text.replaceAll(',', '') ?? '') ?? 0.0;
    final otherCharges = double.tryParse(_financialControllers['orderOtherCharges']?.text.replaceAll(',', '') ?? '') ?? 0.0;
    final gst = double.tryParse(_financialControllers['orderGST']?.text.replaceAll(',', '') ?? '') ?? 0.0;
    final total = baseValue + otherCharges + gst;
    _financialControllers['totalAmount']?.text = total.toStringAsFixed(2);
  }
  
  void _calculateInvoiceValue() {
    final taxableValue = double.tryParse(_financialControllers['taxableValue']?.text.replaceAll(',', '') ?? '') ?? 0.0;
    final gst = double.tryParse(_financialControllers['addedGST']?.text.replaceAll(',', '') ?? '') ?? 0.0;
    final otherCharges = double.tryParse(_financialControllers['invoiceOtherCharges']?.text.replaceAll(',', '') ?? '') ?? 0.0;
    final invoiceTotal = taxableValue + gst + otherCharges;
    _financialControllers['invoiceValue']?.text = invoiceTotal.toStringAsFixed(2);
  }

  void _calculateBudgetDifference() {
    if (!mounted) return;

    final budgetExpenditure = double.tryParse(_budgetExpenditureController.text.replaceAll(',', '')) ?? 0.0;
    final actualExpenditure = double.tryParse(_actualExpenditureController.text.replaceAll(',', '')) ?? 0.0;
    final difference = actualExpenditure - budgetExpenditure;

    _expenditureOverBudgetController.text = difference.abs().toStringAsFixed(2);

    setState(() {
      if (difference > 0) {
        _budgetStatus = '(Over Budget)';
        _budgetStatusColor = Colors.red;
      } else if (difference < 0) {
        _budgetStatus = '(Under Budget)';
        _budgetStatusColor = Colors.green;
      } else {
        _budgetStatus = '(On Budget)';
        _budgetStatusColor = Colors.grey;
      }
    });
  }

  void _adjustBudgetValue(TextEditingController controller, double delta) {
    final current = double.tryParse(controller.text) ?? 0.0;
    double nextValue = current + delta;
    if (nextValue < 0) nextValue = 0;
    controller.text = nextValue.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                _buildHeader(context),
                const SizedBox(height: 16),

                // Form Sections
                ...List.generate(expenseFormSections.length, (index) {
                  final section = expenseFormSections[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildFormSection(context, section, index),
                  );
                }),

                // Action Buttons
                _buildActionButtons(context),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.note_add,
              size: 24,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create Expense Note',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Fill in the details to create a new expense note',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormSection(BuildContext context, FormSection section, int sectionIndex) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final isExpanded = _expandedSections[sectionIndex] ?? true;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Section Header
          InkWell(
            onTap: () {
              setState(() {
                _expandedSections[sectionIndex] = !isExpanded;
              });
            },
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainer,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Row(
                children: [
                  Icon(
                    section.icon,
                    size: 20,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      section.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ],
              ),
            ),
          ),

          // Section Content
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.all(16),
              child: section.title == 'Financial Details'
                  ? _buildFinancialDetailsContent(context, section)
                  : section.title == 'Budget Information'
                      ? _buildBudgetInformationSection(context)
                      : section.title == 'Contract Details'
                      ? _buildContractDetailsContent(context, section)
                      : section.title == 'Contract Extension & Compliance'
                          ? _buildContractExtensionContent(context, section)
                          : section.title == 'HR Department (Optional)'
                              ? _buildHrDepartmentContent(context, section)
                              : LayoutBuilder(
                          builder: (context, constraints) {
                            final isSmallScreen = constraints.maxWidth < 720;
                            final fieldWidth = isSmallScreen
                                ? constraints.maxWidth
                                : (constraints.maxWidth - 24) / 2;

                            return Wrap(
                              spacing: 24,
                              runSpacing: 16,
                              children: section.fields.map((field) {
                                return SizedBox(
                                  width: fieldWidth,
                                  child: _buildFormField(context, field),
                                );
                              }).toList(),
                            );
                          },
                        ),
            ),
        ],
      ),
    );
  }

  Widget _buildFinancialDetailsContent(
    BuildContext context,
    FormSection section,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Widget buildOrderAmountColumn() {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Amount',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            _buildCalculatedTextField('Base Value', _finCtrl('orderBaseValue'), false),
            const SizedBox(height: 16),
            _buildCalculatedTextField('Other Charges', _finCtrl('orderOtherCharges'), false),
            const SizedBox(height: 16),
            _buildCalculatedTextField('GST on Above', _finCtrl('orderGST'), false),
            const SizedBox(height: 16),
            _buildCalculatedTextField('Total Amount', _finCtrl('totalAmount'), true),
          ],
        ),
      );
    }

    Widget buildInvoiceDetailsColumn() {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Invoice Details',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.primary,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Multiple Invoices (Optional)',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Transform.scale(
                      scale: 0.8,
                      child: Switch(
                        value: _multipleInvoicesEnabled,
                        onChanged: (value) {
                          setState(() {
                            _multipleInvoicesEnabled = value;
                          });
                        },
                        activeColor: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildCalculatedTextField('Invoice Number', _finCtrl('invoiceNumber'), false),
            const SizedBox(height: 16),
            _buildDateField('Invoice Date', _finCtrl('invoiceDate')),
            const SizedBox(height: 16),
            _buildCalculatedTextField('Taxable Value', _finCtrl('taxableValue'), false),
            const SizedBox(height: 16),
            _buildCalculatedTextField('Add: GST on Above', _finCtrl('addedGST'), false),
            const SizedBox(height: 16),
            _buildCalculatedTextField('Invoice Other Charges', _finCtrl('invoiceOtherCharges'), false),
            const SizedBox(height: 16),
            _buildCalculatedTextField('Invoice Value', _finCtrl('invoiceValue'), true),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 900;
        if (isSmallScreen) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildOrderAmountColumn(),
              const SizedBox(height: 16),
              buildInvoiceDetailsColumn(),
              const SizedBox(height: 16),
              _buildMultipleInvoicesCard(context),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: buildOrderAmountColumn()),
                const SizedBox(width: 32),
                Expanded(child: buildInvoiceDetailsColumn()),
              ],
            ),
            const SizedBox(height: 16),
            _buildMultipleInvoicesCard(context),
          ],
        );
      },
    );
  }
  
  Widget _buildBudgetInformationSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    Widget buildEditableBudgetField(String label, TextEditingController controller) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: controller,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    decoration: const InputDecoration(border: InputBorder.none, isDense: true),
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 20,
                      width: 20,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        iconSize: 18,
                        icon: const Icon(Icons.keyboard_arrow_up),
                        onPressed: () => _adjustBudgetValue(controller, 0.01),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                      width: 20,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        iconSize: 18,
                        icon: const Icon(Icons.keyboard_arrow_down),
                        onPressed: () => _adjustBudgetValue(controller, -0.01),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      );
    }

    Widget buildReadOnlyDifferenceField() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Expenditure over Budget',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _expenditureOverBudgetController.text,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _budgetStatus,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: _budgetStatusColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.pie_chart_outline, color: colorScheme.primary, size: 18),
            const SizedBox(width: 8),
            Text(
              'Budget Information',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final isSmall = constraints.maxWidth < 720;
            if (isSmall) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildEditableBudgetField('Budget Expenditure', _budgetExpenditureController),
                  const SizedBox(height: 16),
                  buildEditableBudgetField('Actual Expenditure', _actualExpenditureController),
                  const SizedBox(height: 16),
                  buildReadOnlyDifferenceField(),
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: buildEditableBudgetField('Budget Expenditure', _budgetExpenditureController)),
                const SizedBox(width: 16),
                Expanded(child: buildEditableBudgetField('Actual Expenditure', _actualExpenditureController)),
                const SizedBox(width: 16),
                Expanded(child: buildReadOnlyDifferenceField()),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildCalculatedTextField(String label, TextEditingController controller, bool isReadOnly) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: isReadOnly,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: isReadOnly ? null : [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          ],
          decoration: InputDecoration(
            filled: true,
            fillColor: isReadOnly 
                ? colorScheme.surfaceContainerHighest.withOpacity(0.5)
                : colorScheme.surface,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          validator: isReadOnly ? null : (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter $label';
            }
            final number = double.tryParse(value);
            if (number == null) {
              return 'Please enter a valid number';
            }
            return null;
          },
        ),
      ],
    );
  }
  
  Widget _buildDateField(String label, TextEditingController controller) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: colorScheme.surface,
            suffixIcon: Icon(Icons.calendar_today, size: 18, color: colorScheme.primary),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (date != null) {
              controller.text = '${date.day}/${date.month}/${date.year}';
            }
          },
        ),
      ],
    );
  }
  

  FormFieldConfig? _getFieldConfig(FormSection section, String fieldName) {
    try {
      return section.fields.firstWhere((field) => field.name == fieldName);
    } catch (_) {
      return null;
    }
  }

  Widget _buildMultipleInvoicesCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (!_multipleInvoicesEnabled) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Icon(Icons.new_releases_outlined, color: colorScheme.primary, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'New Feature! You can now add multiple invoices to a single expense note.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildInvoiceEntriesList(context),
          ),
        ],
      ),
    );
  }
  

  Widget _buildInvoiceEntriesList(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        ...List.generate(_invoiceEntries.length, (index) {
          final invoiceEntry = _invoiceEntries[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Invoice Entry ${index + 1}',
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isSmallScreen = constraints.maxWidth < 720;
                    final fieldWidth = isSmallScreen
                        ? constraints.maxWidth
                        : (constraints.maxWidth - 24) / 2;
                    return Wrap(
                      spacing: 24,
                      runSpacing: 16,
                      children: [
                        _buildInvoiceTextField(context, 'Invoice Number *', invoiceEntry.invoiceNumberController, fieldWidth),
                        _buildInvoiceDateField(context, invoiceEntry.invoiceDateController, fieldWidth),
                        _buildInvoiceTextField(context, 'Base Value (₹)', invoiceEntry.baseValueController, fieldWidth, isNumeric: true),
                        _buildInvoiceTextField(context, 'GST (₹)', invoiceEntry.gstController, fieldWidth, isNumeric: true),
                        _buildInvoiceTextField(context, 'Other Charges (₹)', invoiceEntry.otherChargesController, fieldWidth, isNumeric: true),
                        _buildInvoiceTextField(context, 'Total Value (₹)', invoiceEntry.totalValueController, fieldWidth, readOnly: true),
                        SizedBox(
                          width: fieldWidth,
                          child: TextFormField(
                            controller: invoiceEntry.descriptionController,
                            decoration: const InputDecoration(
                              labelText: 'Description (Optional)',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 3,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                if (_invoiceEntries.length > 1) ...[
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _invoiceEntries.removeAt(index).dispose();
                        });
                      },
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colorScheme.error.withOpacity(0.15),
                        ),
                        child: Icon(
                          Icons.delete_outline_rounded,
                          size: 18,
                          color: colorScheme.error,
                        ),
                      ),
                      label: Text(
                        'Remove Invoice',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.error,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        backgroundColor: colorScheme.error.withOpacity(0.08),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                          side: BorderSide(
                            color: colorScheme.error.withOpacity(0.3),
                          ),
                        ),
                        overlayColor: colorScheme.error.withOpacity(0.12),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        }).toList(),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () {
              setState(() {
                final newEntry = _InvoiceEntry();
                _invoiceEntries.add(newEntry);
                _addInvoiceListeners(newEntry);
              });
            },
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('Add Invoice Entry'),
          ),
        ),
        const SizedBox(height: 16),
        _buildInvoiceTotals(context),
      ],
    );
  }

  Widget _buildInvoiceTextField(
    BuildContext context,
    String label,
    TextEditingController controller,
    double width, {
    bool readOnly = false,
    bool isNumeric = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: width,
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: isNumeric ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
        inputFormatters: isNumeric ? [
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
        ] : null,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.3)),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
        validator: label.contains('*') && !readOnly ? (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Required';
          }
          return null;
        } : null,
      ),
    );
  }
  
  void _addInvoiceListeners(_InvoiceEntry entry) {
    entry.baseValueController.addListener(() => _calculateInvoiceEntryTotal(entry));
    entry.gstController.addListener(() => _calculateInvoiceEntryTotal(entry));
    entry.otherChargesController.addListener(() => _calculateInvoiceEntryTotal(entry));
  }
  
  void _calculateInvoiceEntryTotal(_InvoiceEntry entry) {
    final baseValue = double.tryParse(entry.baseValueController.text.replaceAll(',', '')) ?? 0.0;
    final gst = double.tryParse(entry.gstController.text.replaceAll(',', '')) ?? 0.0;
    final otherCharges = double.tryParse(entry.otherChargesController.text.replaceAll(',', '')) ?? 0.0;
    final total = baseValue + gst + otherCharges;
    entry.totalValueController.text = total.toStringAsFixed(2);
    
    // Trigger rebuild to update totals
    if (mounted) {
      setState(() {});
    }
  }

  Widget _buildInvoiceDateField(BuildContext context, TextEditingController controller, double width) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: width,
      child: TextFormField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: 'Invoice Date *',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.3)),
          ),
          suffixIcon: Icon(Icons.calendar_today, size: 18, color: colorScheme.onSurface.withOpacity(0.6)),
        ),
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );
          if (date != null) {
            final formattedDate = '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
            controller.text = formattedDate;
          }
        },
      ),
    );
  }

  Widget _buildInvoiceTotals(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Calculate totals from all invoice entries
    double totalInvoiceValue = 0.0;
    double totalGST = 0.0;
    
    for (final entry in _invoiceEntries) {
      totalInvoiceValue += double.tryParse(entry.totalValueController.text) ?? 0.0;
      totalGST += double.tryParse(entry.gstController.text) ?? 0.0;
    }
    
    // Update financial details total amount
    if (_multipleInvoicesEnabled && totalInvoiceValue > 0) {
      _financialControllers['totalAmount']?.text = totalInvoiceValue.toStringAsFixed(2);
    }
    
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total Invoice Value', style: theme.textTheme.labelLarge),
                const SizedBox(height: 8),
                Text('₹${totalInvoiceValue.toStringAsFixed(2)}', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total GST', style: theme.textTheme.labelLarge),
                const SizedBox(height: 8),
                Text('₹${totalGST.toStringAsFixed(2)}', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ],
    );
  }


  String _getDropdownDisplayText(String value) {
    // Convert backend enum values to user-friendly display text
    switch (value) {
      case 'EXPENSE_CATEGORY_CAPITAL':
        return 'Capital';
      case 'EXPENSE_CATEGORY_REVENUE':
        return 'Revenue';
      case 'EXPENSE_CATEGORY_OPERATIONAL':
        return 'Operational';
      case 'EXPENSE_CATEGORY_ADMINISTRATIVE':
        return 'Administrative';
      case 'EXPENSE_CATEGORY_MAINTENANCE':
        return 'Maintenance';
      case 'NATURE_OHC_001_MANPOWER':
        return 'Manpower';
      case 'NATURE_OHC_002_STAFF_WELFARE':
        return 'Staff Welfare';
      case 'NATURE_OHC_003_OFFICE_RENT_UTILITIES':
        return 'Office Rent & Utilities';
      default:
        return value;
    }
  }
  
  String _getExpenseCategoryText(String enumValue) {
    switch (enumValue) {
      case 'EXPENSE_CATEGORY_CAPITAL':
        return 'Capital';
      case 'EXPENSE_CATEGORY_REVENUE':
        return 'Revenue';
      case 'EXPENSE_CATEGORY_OPERATIONAL':
        return 'Operational';
      case 'EXPENSE_CATEGORY_ADMINISTRATIVE':
        return 'Administrative';
      case 'EXPENSE_CATEGORY_MAINTENANCE':
        return 'Maintenance';
      default:
        return '';
    }
  }

  Widget _buildFilePickerField(BuildContext context, FormFieldConfig field) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          field.label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final result = await FilePicker.platform.pickFiles(
              type: FileType.custom,
              allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'jpg', 'jpeg', 'png'],
            );
            if (result != null && result.files.isNotEmpty) {
              final picked = result.files.first;
              setState(() {
                _controllers[field.name]?.text = picked.name;
                // Store file based on field name
                if (field.name == 'protestNoteFile') {
                  _protestNoteFile = picked;
                } else if (field.name == 'milestoneFile') {
                  _contractExtensionFile = picked;
                } else if (field.name == 'deviationFile') {
                  _deviationFile = picked;
                } else if (field.name == 'hrAttachment') {
                  _hrAttachmentFile = picked;
                }
              });
            }
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Choose File',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _controllers[field.name]?.text.isNotEmpty == true
                        ? _controllers[field.name]!.text
                        : 'No file chosen',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'PDF, DOC, XLS, Images max 10MB',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildFormField(BuildContext context, FormFieldConfig field) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    switch (field.type) {
      case FormFieldType.text:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _controllers[field.name],
              decoration: InputDecoration(
                labelText: field.label,
                labelStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
                filled: true,
                fillColor: colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                suffixIcon: field.name == 'supplierName' && _isLoadingSupplier
                    ? const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : null,
              ),
              readOnly: field.readOnly ?? false,
              maxLines: field.maxLines ?? 1,
              validator: field.validator,
              onChanged: (value) {
                setState(() {
                  _formValues[field.name] = value;
                });
              },
            ),
            if (field.name == 'supplierName' && _supplierError != null)
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 12),
                child: Text(
                  _supplierError!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.error,
                  ),
                ),
              ),
          ],
        );

      case FormFieldType.dropdown:
        return IgnorePointer(
          ignoring: field.readOnly ?? false,
          child: Opacity(
            opacity: (field.readOnly ?? false) ? 0.6 : 1.0,
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: field.label,
                labelStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
                filled: true,
                fillColor: (field.readOnly ?? false) 
                    ? colorScheme.surfaceContainerHighest.withOpacity(0.5)
                    : colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              items: field.options?.map((option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(
                    _getDropdownDisplayText(option),
                    style: theme.textTheme.bodyMedium,
                  ),
                );
              }).toList(),
              validator: field.validator,
              value: _formValues[field.name],
              onChanged: (field.readOnly ?? false) ? null : (value) {
                setState(() {
                  _formValues[field.name] = value;
                  // Auto-populate expense_category when expenseCategoryType changes
                  if (field.name == 'expenseCategoryType' && value != null) {
                    _controllers['expenseCategory']?.text = _getExpenseCategoryText(value);
                  }
                });
              },
            ),
          ),
        );

      case FormFieldType.file:
        return _buildFilePickerField(context, field);

      case FormFieldType.date:
        return TextFormField(
          controller: _controllers[field.name],
          decoration: InputDecoration(
            labelText: field.label,
            labelStyle: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
            filled: true,
            fillColor: colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            suffixIcon: Icon(
              Icons.calendar_today,
              size: 18,
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          readOnly: true,
          validator: field.validator,
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (date != null) {
              final formattedDate = '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
              setState(() {
                _formValues[field.name] = formattedDate;
                _controllers[field.name]?.text = formattedDate;
              });
            }
          },
        );
    }
  }

  Widget _buildActionButtons(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Widget buildResetButton() {
      return SecondaryButton(
        label: 'Reset',
        onPressed: _resetForm,
      );
    }

    Widget buildCancelButton() {
      return SecondaryButton(
        label: 'Cancel',
        backgroundColor: colorScheme.error.withOpacity(0.08),
        onPressed: () => Navigator.of(context).maybePop(),
      );
    }

    Widget buildCreateButton() {
      return PrimaryButton(
        label: _isSubmitting ? 'Creating...' : 'Create Expense Note',
        onPressed: _isSubmitting ? null : _submitGreenNote,
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          buildResetButton(),
          const SizedBox(width: 12),
          buildCancelButton(),
          const SizedBox(width: 12),
          buildCreateButton(),
        ],
      ),
    );
  }
}
