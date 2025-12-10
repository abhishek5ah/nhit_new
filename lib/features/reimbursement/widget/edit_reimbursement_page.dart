import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ppv_components/features/reimbursement/models/reimbursement_models/travel_detail_model.dart';
import 'package:ppv_components/common_widgets/button/primary_button.dart';
import 'package:ppv_components/common_widgets/button/secondary_button.dart';

class EditReimbursementPage extends StatefulWidget {
  final ReimbursementNote note;

  const EditReimbursementPage({
    super.key,
    required this.note,
  });

  @override
  State<EditReimbursementPage> createState() => _EditReimbursementPageState();
}

class _EditReimbursementPageState extends State<EditReimbursementPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _projectController;
  late TextEditingController _employeeController;
  late TextEditingController _amountController;
  late TextEditingController _dateController;
  late TextEditingController _approverController;
  late TextEditingController _utrNumberController;
  late TextEditingController _utrDateController;
  late String _selectedStatus;

  final List<String> _statusOptions = ['Pending', 'Approved', 'Rejected', 'Paid', 'Sent for Approval', 'Draft', 'Payment Note Processed'];

  @override
  void initState() {
    super.initState();
    _projectController = TextEditingController(text: widget.note.projectName);
    _employeeController = TextEditingController(text: widget.note.employeeName);
    _amountController = TextEditingController(text: widget.note.amount);
    _dateController = TextEditingController(text: widget.note.date);
    _approverController = TextEditingController(text: widget.note.nextApprover);
    _utrNumberController = TextEditingController(text: widget.note.utrNumber);
    _utrDateController = TextEditingController(text: widget.note.utrDate);
    _selectedStatus = widget.note.status;
  }

  @override
  void dispose() {
    _projectController.dispose();
    _employeeController.dispose();
    _amountController.dispose();
    _dateController.dispose();
    _approverController.dispose();
    _utrNumberController.dispose();
    _utrDateController.dispose();
    super.dispose();
  }

  void _saveReimbursement() {
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: Implement save logic when backend is ready
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reimbursement updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
      context.go('/reimbursement-note');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SingleChildScrollView(
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
                _buildPaymentInformationSection(context, colorScheme, theme),
                const SizedBox(height: 24),
                _buildActionButtons(context, colorScheme),
              ],
            ),
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
                  'Edit Reimbursement Note',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Update reimbursement note details and information',
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
            onPressed: () => context.go('/reimbursement-note'),
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
                Icons.receipt_long,
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
                child: _buildInputField("Project Name", _projectController, theme),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInputField("Employee Name", _employeeController, theme),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInputField("Amount", _amountController, theme),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInputField("Date", _dateController, theme),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatusDropdown(theme),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInputField("Next Approver", _approverController, theme, required: false),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentInformationSection(BuildContext context, ColorScheme colorScheme, ThemeData theme) {
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
                Icons.payment,
                color: colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Payment Information',
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
                child: _buildInputField("UTR Number", _utrNumberController, theme, required: false),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInputField("UTR Date", _utrDateController, theme, required: false),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller,
    ThemeData theme, {
    bool readOnly = false,
    bool required = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          decoration: InputDecoration(
            filled: true,
            fillColor: readOnly
                ? theme.colorScheme.surfaceContainer.withValues(alpha: 0.3)
                : theme.colorScheme.surface,
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.5)),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
              borderRadius: BorderRadius.circular(8),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: theme.colorScheme.error),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: theme.colorScheme.error, width: 1.5),
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          validator: (val) {
            if (required && !readOnly && (val == null || val.isEmpty)) {
              return 'Please enter $label';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildStatusDropdown(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Status',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedStatus,
          decoration: InputDecoration(
            filled: true,
            fillColor: theme.colorScheme.surface,
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.5)),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          items: _statusOptions.map((status) {
            return DropdownMenuItem<String>(
              value: status,
              child: Text(status),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedStatus = value;
              });
            }
          },
          validator: (val) {
            if (val == null || val.isEmpty) {
              return 'Please select Status';
            }
            return null;
          },
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
          onPressed: () => context.go('/reimbursement-note'),
        ),
        const SizedBox(width: 12),
        PrimaryButton(
          label: 'Save Changes',
          onPressed: _saveReimbursement,
        ),
      ],
    );
  }
}
