import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ppv_components/common_widgets/button/primary_button.dart';
import 'package:ppv_components/common_widgets/button/secondary_button.dart';
import 'package:ppv_components/common_widgets/button/outlined_button.dart';
import 'package:ppv_components/features/approval_management/services/approval_rule_api_service.dart';
import 'package:ppv_components/features/approval_management/models/approval_rule_api_models.dart';
import 'package:ppv_components/features/approval_management/controllers/department_controller.dart';
import 'package:ppv_components/features/approval_management/services/department_api_client.dart';
import 'package:ppv_components/features/approval_management/controllers/project_controller.dart';
import 'package:ppv_components/features/approval_management/services/project_api_client.dart';

class CreateApprovalRulePage extends StatefulWidget {
  final String ruleType; // 'green_note', 'payment_note', 'reimbursement_note', 'bank_letter'

  const CreateApprovalRulePage({
    super.key,
    required this.ruleType,
  });

  @override
  State<CreateApprovalRulePage> createState() => _CreateApprovalRulePageState();
}

class _CreateApprovalRulePageState extends State<CreateApprovalRulePage> {
  final _formKey = GlobalKey<FormState>();
  final _ruleNameController = TextEditingController();
  final _ruleDescriptionController = TextEditingController();
  final _minAmountController = TextEditingController();
  final _maxAmountController = TextEditingController();
  final _testAmountController = TextEditingController();
  final TextInputFormatter _doubleInputFormatter = _DoubleInputFormatter();

  String? selectedDepartment;
  String? selectedDepartmentId;
  String? selectedProject;
  String? selectedProjectId;
  String? selectedTemplate;
  List<ApproverItem> approvers = [];
  bool _isSubmitting = false;
  final ApprovalRuleApiService _apiService = ApprovalRuleApiService();
  DepartmentController? _departmentController;
  ProjectController? _projectController;

  @override
  void initState() {
    super.initState();
    // Initialize controllers
    _departmentController = DepartmentController();
    _projectController = ProjectController();
    // Initialize API clients
    DepartmentApiClient().initialize();
    ProjectApiClient().initialize();
    // Fetch data after first frame to avoid listener issues
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _departmentController?.fetchDepartments();
      _projectController?.fetchProjects();
    });
  }

  // Department list
  final List<String> departments = [
    'Operations',
    'HR & Admin',
    'ITS',
    'EHS',
    'Finance & Accounts',
    'Secretarial',
    'Procurement',
    'I & A',
    'HR & Admin (Corporate)',
    'IT',
    'Concurrent/Internal Audit / Corp Communication',
    'HR & Admin (Admin HO)',
    'Traffic & Revenue',
    'Legal and Profession',
    'Civil & Maintenance',
  ];

  // Approver list
  final List<Map<String, String>> approversList = [
    {'name': 'Admin User', 'email' :'b8dd252a-352c-4687-a96a-dd711a3711d2'},
    {'name': 'Admin', 'email': 'admin@agetnada.com'},
    {'name': 'Kushal Vats', 'email': 'kvats69@gmail.com'},
    {'name': 'Deepak Kumar', 'email': 'deepakkumar@nhit.co.in'},
    {'name': 'Mahesh Yadav', 'email': 'maheshyadav@nhit.co.in'},
    {'name': 'Jatindra Nath Khadanga', 'email': 'jatindrakhadanga@nhit.co.in'},
    {'name': 'Priyabrata Ghosh', 'email': 'priyabrataghosh@nhit.co.in'},
    {'name': 'Naveen Kumar', 'email': 'naveenkumar@nhit.co.in'},
    {'name': 'Pawan Kumar (Consultant)', 'email': 'pawankumar@nhit.co.in'},
    {'name': 'Concurrent Auditor', 'email': 'paymentaudit@nhit.co.in'},
    {'name': 'Mathew George', 'email': 'cfo.nhim@nhit.co.in'},
    {'name': 'Rakshit Jain', 'email': 'md.nhim@nhit.co.in'},
    {'name': 'Shailendrasinh Rajput', 'email': 'shailendrasinh@nhit.co.in'},
  ];

  // Template options
  final List<Map<String, String>> templates = [
    {
      'name': 'Basic Approval – Single level approval for small amounts',
      'value': 'basic',
    },
    {
      'name': 'Standard Approval – Two level approval for medium amounts',
      'value': 'standard',
    },
    {
      'name': 'Complex Approval – Multi-level approval for large amounts',
      'value': 'complex',
    },
    {
      'name': 'Basic Expense Approval – Department head approval for small expenses',
      'value': 'basic_expense',
    },
    {
      'name': 'Standard Expense Approval – Department head + Finance approval',
      'value': 'standard_expense',
    },
  ];

  @override
  void dispose() {
    _ruleNameController.dispose();
    _ruleDescriptionController.dispose();
    _minAmountController.dispose();
    _maxAmountController.dispose();
    _testAmountController.dispose();
    _departmentController?.dispose();
    _projectController?.dispose();
    super.dispose();
  }

  String get ruleTypeTitle {
    switch (widget.ruleType) {
      case 'green_note':
        return 'Green Note (Expense)';
      case 'payment_note':
        return 'Payment Note';
      case 'reimbursement_note':
        return 'Reimbursement Note';
      case 'bank_letter':
        return 'Bank Letter';
      default:
        return 'Approval Rule';
    }
  }

  void _addApprover() {
    setState(() {
      approvers.add(ApproverItem(
        approver: null,
        level: approvers.length + 1,
        amount: 0.0,
      ));
    });
  }

  void _removeApprover(int index) {
    setState(() {
      approvers.removeAt(index);
    });
  }

  void _incrementAmount(TextEditingController controller, {double step = 0.25}) {
    final currentValue = double.tryParse(controller.text) ?? 0.0;
    final newValue = currentValue + step;
    controller.text = newValue.toStringAsFixed(2);
    setState(() {});
  }

  void _decrementAmount(TextEditingController controller, {double step = 0.25}) {
    final currentValue = double.tryParse(controller.text) ?? 0.0;
    final newValue = (currentValue - step).clamp(0.0, double.infinity);
    controller.text = newValue.toStringAsFixed(2);
    setState(() {});
  }

  void _testRule() {
    if (_testAmountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an amount to test')),
      );
      return;
    }
    // Test logic here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Testing approval rule...')),
    );
  }

  void _preview() {
    // Preview logic here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Preview approval rule...')),
    );
  }

  Future<void> _createRule() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    // Validate approvers
    if (approvers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one approver'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check if all approvers have required fields
    for (int i = 0; i < approvers.length; i++) {
      if (approvers[i].approver == null || approvers[i].approver!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please select an approver for Level ${i + 1}'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Parse amounts
      final minAmount = double.tryParse(_minAmountController.text.trim()) ?? 0.0;
      final maxAmount = double.tryParse(_maxAmountController.text.trim()) ?? 0.0;

      // Prepare approvers list
      final approverRequests = approvers.map((approver) {
        return ApproverRequest(
          reviewerId: approver.approver!,
          level: approver.level,
          maxAmount: approver.amount,
        );
      }).toList();

      // Create request
      final request = CreateApprovalRuleRequest(
        ruleName: _ruleNameController.text.trim(),
        description: _ruleDescriptionController.text.trim().isNotEmpty
            ? _ruleDescriptionController.text.trim()
            : null,
        departmentId: selectedDepartmentId,
        projectId: selectedProjectId,
        minAmount: minAmount,
        maxAmount: maxAmount,
        approvers: approverRequests,
      );

      // Call API
      final response = await _apiService.createApprovalRule(request);

      if (!mounted) return;

      if (response.success && response.data != null) {
        // Success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Approval rule "${response.data!.ruleName}" created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      } else {
        // Error from API
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Failed to create approval rule'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section (Create Escrow Page Style)
                  _buildHeader(context, constraints),
                  const SizedBox(height: 16),

                  // Form Section
                  _buildFormSection(context, constraints),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, BoxConstraints constraints) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final isSmallScreen = constraints.maxWidth < 600;

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline,
          width: 0.5,
        ),
      ),
      child: isSmallScreen
          ? Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.add_circle_outline,
                  size: 24,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create Approval Rule',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Create new approval rule for $ruleTypeTitle',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          OutlineButton(
            onPressed: () => Navigator.pop(context),
            icon: Icons.arrow_back,
            label: 'Back to Rules',
          ),
        ],
      )
          : Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.add_circle_outline,
              size: 28,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create Approval Rule',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Create new approval rule for $ruleTypeTitle',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          OutlineButton(
            onPressed: () => Navigator.pop(context),
            icon: Icons.arrow_back,
            label: 'Back to Rules',
          ),
        ],
      ),
    );
  }

  Widget _buildFormSection(BuildContext context, BoxConstraints constraints) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSmallScreen = constraints.maxWidth < 600;

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: colorScheme.outline,
          width: 0.5,
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Start Templates Section
            _buildQuickStartSection(context),
            const SizedBox(height: 24),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column - Rule Configuration
                Expanded(
                  flex: 2,
                  child: _buildRuleConfiguration(context),
                ),
                const SizedBox(width: 24),

                // Right Column - Approval Workflow
                Expanded(
                  flex: 3,
                  child: _buildApprovalWorkflow(context),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Bottom Action Buttons
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStartSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.flash_on,
                color: colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Quick Start Templates',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'for $ruleTypeTitle',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Choose a template to get started quickly, then customize as needed.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: selectedTemplate,
                  decoration: InputDecoration(
                    labelText: 'Select a template...',
                    filled: true,
                    fillColor: colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colorScheme.outline),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colorScheme.outline),
                    ),
                  ),
                  items: templates
                      .map((template) => DropdownMenuItem(
                    value: template['value'],
                    child: Text(
                      template['name']!,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedTemplate = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              SecondaryButton(
                label: 'Help',
                icon: Icons.help_outline,
                onPressed: () {},
              ),
              const SizedBox(width: 12),
              SecondaryButton(
                label: 'Test Rule',
                icon: Icons.play_arrow,
                onPressed: _testRule,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Custom Stepper Field with VERTICAL arrows (matching Image 1)
  Widget _buildStepperField({
    required TextEditingController controller,
    required String label,
    String? hintText,
    String? helperText,
    bool isRequired = false,
    double step = 0.25,
    bool showLabel = true,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabel) ...[
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
        ],
        SizedBox(
          height: 48,
          child: TextFormField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [_doubleInputFormatter],
            decoration: InputDecoration(
              hintText: hintText ?? '0.00',
              filled: true,
              fillColor: colorScheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.outline),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.outline),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.primary, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
              ),
              suffixIconConstraints: const BoxConstraints(
                minWidth: 34,
                maxWidth: 36,
                minHeight: 48,
                maxHeight: 48,
              ),
              suffixIcon: Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: _StepperIconButton(
                        icon: Icons.arrow_drop_up,
                        color: colorScheme.onSurface,
                        onTap: () => _incrementAmount(controller, step: step),
                      ),
                    ),
                    Expanded(
                      child: _StepperIconButton(
                        icon: Icons.arrow_drop_down,
                        color: colorScheme.onSurface,
                        onTap: () => _decrementAmount(controller, step: step),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            validator: (value) {
              if (isRequired && (value == null || value.trim().isEmpty)) {
                return '$label is required';
              }
              if (value != null &&
                  value.trim().isNotEmpty &&
                  double.tryParse(value.trim()) == null) {
                return 'Enter a valid number';
              }
              return null;
            },
            onChanged: (_) => setState(() {}),
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
    );
  }

  // Small helper for the vertical arrows to keep the UI tidy
  Widget _StepperIconButton({
    required IconData icon,
    VoidCallback? onTap,
    BorderRadius? borderRadius,
    Color? color,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: RoundedRectangleBorder(
          borderRadius: borderRadius ?? BorderRadius.zero,
        ),
        child: SizedBox.expand(
          child: Icon(
            icon,
            size: 18,
            color: color ?? colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ),
    );
  }

  Widget _buildRuleConfiguration(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.settings,
                color: colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Rule Configuration',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Rule Description
          Text(
            'Description',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _ruleDescriptionController,
            minLines: 2,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Optional: Add context or special instructions for this rule',
              hintStyle: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.4),
              ),
              filled: true,
              fillColor: colorScheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.outline),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.outline),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.primary, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Rule Name
          Text(
            'Rule Name',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _ruleNameController,
            decoration: InputDecoration(
              hintText: 'e.g., Standard Payment Approval',
              hintStyle: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.4),
              ),
              helperText: 'Optional: Give your rule a descriptive name',
              filled: true,
              fillColor: colorScheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.outline),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.outline),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.primary, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Department
          Text(
            'Department *',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          _departmentController == null
              ? Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colorScheme.outline),
                  ),
                  child: Center(
                    child: SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                )
              : ListenableBuilder(
            listenable: _departmentController!,
            builder: (context, _) {
              if (_departmentController!.isLoading) {
                return Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colorScheme.outline),
                  ),
                  child: Center(
                    child: SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                );
              }

              if (_departmentController!.errorMessage != null) {
                return Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colorScheme.error),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, color: colorScheme.error, size: 20),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            _departmentController!.errorMessage!,
                            style: TextStyle(color: colorScheme.error),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: Icon(Icons.refresh, color: colorScheme.error, size: 20),
                          onPressed: () => _departmentController?.fetchDepartments(),
                          tooltip: 'Retry',
                        ),
                      ],
                    ),
                  ),
                );
              }

              return DropdownButtonFormField<String>(
                value: selectedDepartmentId,
                decoration: InputDecoration(
                  hintText: 'Select Department',
                  helperText: 'Required: Rules must be scoped to a department',
                  helperStyle: TextStyle(color: colorScheme.error),
                  filled: true,
                  fillColor: colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.primary, width: 2),
                  ),
                ),
                items: _departmentController!.departmentList
                    .map((dept) => DropdownMenuItem(
                  value: dept.id,
                  child: Text(dept.name),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedDepartmentId = value;
                    selectedDepartment = _departmentController
                        ?.getDepartmentById(value!)?.name;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Department is required';
                  }
                  return null;
                },
              );
            },
          ),
          const SizedBox(height: 24),

          // Project
          Text(
            'Project *',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          _projectController == null
              ? Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colorScheme.outline),
                  ),
                  child: Center(
                    child: SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                )
              : ListenableBuilder(
            listenable: _projectController!,
            builder: (context, _) {
              if (_projectController!.isLoading) {
                return Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colorScheme.outline),
                  ),
                  child: Center(
                    child: SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                );
              }

              if (_projectController!.errorMessage != null) {
                return Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colorScheme.error),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, color: colorScheme.error, size: 20),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            _projectController!.errorMessage!,
                            style: TextStyle(color: colorScheme.error),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: Icon(Icons.refresh, color: colorScheme.error, size: 20),
                          onPressed: () => _projectController?.fetchProjects(),
                          tooltip: 'Retry',
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Check if projects list is empty
              if (!_projectController!.hasProjects) {
                return Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colorScheme.outline),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.info_outline, color: colorScheme.onSurfaceVariant, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'No Project Found',
                          style: TextStyle(color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return DropdownButtonFormField<String>(
                value: selectedProjectId,
                decoration: InputDecoration(
                  hintText: 'Select Project',
                  helperText: 'Required: Rules must be scoped to a project',
                  helperStyle: TextStyle(color: colorScheme.error),
                  filled: true,
                  fillColor: colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.primary, width: 2),
                  ),
                ),
                items: _projectController!.projectList
                    .map((project) => DropdownMenuItem(
                  value: project.projectId,
                  child: Text(project.projectName),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedProjectId = value;
                    selectedProject = _projectController
                        ?.getProjectById(value!)?.projectName;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Project is required';
                  }
                  return null;
                },
              );
            },
          ),
          const SizedBox(height: 24),

          // Minimum Amount - Vertical Stepper Field
          _buildStepperField(
            controller: _minAmountController,
            label: 'Minimum Amount *',
            hintText: '0.00',
            helperText: 'Minimum ${widget.ruleType.replaceAll('_', ' ')} amount for this rule',
            isRequired: true,
            step: 0.25,
          ),
          const SizedBox(height: 24),

          // Maximum Amount - Vertical Stepper Field
          _buildStepperField(
            controller: _maxAmountController,
            label: 'Maximum Amount',
            hintText: 'Leave empty for no limit',
            helperText: 'Leave empty for "above minimum amount"',
            isRequired: false,
            step: 0.25,
          ),
          const SizedBox(height: 24),

          // Test This Rule - Vertical Stepper Field
          Text(
            'Test This Rule',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildStepperField(
                  controller: _testAmountController,
                  label: ' ',
                  hintText: 'Enter amount to test',
                  showLabel: false,
                  step: 0.25,
                ),
              ),
              const SizedBox(width: 12),
              SecondaryButton(
                label: 'Test',
                onPressed: _testRule,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildApprovalWorkflow(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.green.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Approval Workflow',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
              PrimaryButton(
                label: 'Add Approver',
                icon: Icons.add,
                backgroundColor: Colors.green,
                onPressed: _addApprover,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Approvers List
          if (approvers.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.person_add_outlined,
                      size: 48,
                      color: colorScheme.onSurface.withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No approvers added yet',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Click "Add Approver" to start building your approval workflow',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            ...approvers.asMap().entries.map((entry) {
              final index = entry.key;
              final approver = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildApproverCard(context, approver, index),
              );
            }),

          const SizedBox(height: 24),

          // Approval Summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Approval Summary',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add approvers to see the approval flow summary',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApproverCard(BuildContext context, ApproverItem approver, int index) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: Icon(Icons.close, size: 18, color: colorScheme.error),
                onPressed: () => _removeApprover(index),
                tooltip: 'Remove Approver',
              ),
            ],
          ),
          Row(
            children: [
              // Level Field
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Level',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      initialValue: approver.level > 0 ? approver.level.toString() : '',
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Enter level',
                        filled: true,
                        fillColor: colorScheme.surfaceContainer,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: colorScheme.outline),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: colorScheme.primary, width: 2),
                        ),
                      ),
                      onChanged: (value) {
                        final parsed = int.tryParse(value.trim());
                        if (parsed != null) {
                          setState(() {
                            approvers[index] = approvers[index].copyWith(level: parsed);
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Approver Field
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Approver',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: approvers[index].approver,
                      isExpanded: true,
                      decoration: InputDecoration(
                        hintText: 'Select Approver',
                        filled: true,
                        fillColor: colorScheme.surfaceContainer,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: colorScheme.outline),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: colorScheme.outline),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: colorScheme.primary, width: 2),
                        ),
                      ),
                      selectedItemBuilder: (BuildContext context) {
                        return approversList.map<Widget>((approver) {
                          return Text(
                            '${approver['name']} (${approver['email']})',
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: colorScheme.onSurface,
                            ),
                          );
                        }).toList();
                      },
                      items: approversList
                          .map((approver) => DropdownMenuItem(
                                value: approver['email'],
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        approver['name']!,
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: colorScheme.onSurface,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        approver['email']!,
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                                          fontSize: 11,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          approvers[index] = approvers[index].copyWith(approver: value);
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Amount Field
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Amount',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      initialValue: approver.amount > 0 ? approver.amount.toStringAsFixed(0) : '',
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        hintText: '0',
                        prefixText: '₹ ',
                        filled: true,
                        fillColor: colorScheme.surfaceContainer,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: colorScheme.outline),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: colorScheme.primary, width: 2),
                        ),
                      ),
                      onChanged: (value) {
                        final parsed = double.tryParse(value.trim());
                        setState(() {
                          approvers[index] =
                              approvers[index].copyWith(amount: parsed ?? 0.0);
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          OutlineButton(
            label: 'Cancel',
            icon: Icons.close,
            onPressed: () => Navigator.pop(context),
          ),
          Row(
            children: [
              SecondaryButton(
                label: 'Preview',
                icon: Icons.visibility,
                onPressed: _preview,
              ),
              const SizedBox(width: 12),
              PrimaryButton(
                label: _isSubmitting ? 'Creating...' : 'Create Approval Rule',
                icon: _isSubmitting ? null : Icons.check,
                onPressed: _isSubmitting ? null : _createRule,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DoubleInputFormatter extends TextInputFormatter {
  final _pattern = RegExp(r'^\d*\.?\d*$');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty || _pattern.hasMatch(newValue.text)) {
      return newValue;
    }
    return oldValue;
  }
}

class ApproverItem {
  final String? approver;
  final int level;
  final double amount;

  ApproverItem({
    required this.approver,
    required this.level,
    required this.amount,
  });

  ApproverItem copyWith({
    String? approver,
    int? level,
    double? amount,
  }) {
    return ApproverItem(
      approver: approver ?? this.approver,
      level: level ?? this.level,
      amount: amount ?? this.amount,
    );
  }
}
