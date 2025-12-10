import 'package:flutter/material.dart';
import 'package:ppv_components/features/bank_rtgs_neft/models/bank_models/account_transfer_model.dart';
import 'package:ppv_components/common_widgets/button/primary_button.dart';
import 'package:ppv_components/common_widgets/button/secondary_button.dart';

class EditTransferContent extends StatefulWidget {
  final AccountTransfer transfer;
  final Function(AccountTransfer) onSave;
  final VoidCallback onCancel;

  const EditTransferContent({
    super.key,
    required this.transfer,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<EditTransferContent> createState() => _EditTransferContentState();
}

class _EditTransferContentState extends State<EditTransferContent> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _referenceController;
  late TextEditingController _fromAccountController;
  late TextEditingController _toAccountController;
  late TextEditingController _amountController;
  late TextEditingController _typeController;
  late String _selectedStatus;

  final List<String> _statusOptions = ['Completed', 'Pending Approval', 'In Progress'];

  @override
  void initState() {
    super.initState();
    _referenceController = TextEditingController(text: widget.transfer.reference);
    _fromAccountController = TextEditingController(text: widget.transfer.fromAccount);
    _toAccountController = TextEditingController(text: widget.transfer.toAccount);
    _amountController = TextEditingController(text: widget.transfer.amount);
    _typeController = TextEditingController(text: widget.transfer.type);
    _selectedStatus = widget.transfer.status;
  }

  @override
  void dispose() {
    _referenceController.dispose();
    _fromAccountController.dispose();
    _toAccountController.dispose();
    _amountController.dispose();
    _typeController.dispose();
    super.dispose();
  }

  void _saveTransfer() {
    if (_formKey.currentState?.validate() ?? false) {
      final updatedTransfer = widget.transfer.copyWith(
        reference: _referenceController.text,
        fromAccount: _fromAccountController.text,
        toAccount: _toAccountController.text,
        amount: _amountController.text,
        type: _typeController.text,
        status: _selectedStatus,
      );
      widget.onSave(updatedTransfer);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal:24, vertical:24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, colorScheme, theme),
              const SizedBox(height: 16),
              _buildTransferInfoSection(context, colorScheme, theme),
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
                  'Edit Transfer',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Update transfer details and information',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          SecondaryButton(
            label: 'Back to Transfers',
            icon: Icons.arrow_back,
            onPressed: widget.onCancel,
          ),
        ],
      ),
    );
  }

  Widget _buildTransferInfoSection(BuildContext context, ColorScheme colorScheme, ThemeData theme) {
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
                Icons.swap_horiz,
                color: colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Transfer Information',
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
                child: _buildInputField("Reference", _referenceController, theme),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInputField("From Account", _fromAccountController, theme),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInputField("To Account", _toAccountController, theme),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInputField("Amount", _amountController, theme),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInputField("Type", _typeController, theme),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatusDropdown(theme),
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
      ThemeData theme,
      ) {
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
            if (val == null || val.isEmpty) {
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
          onPressed: widget.onCancel,
        ),
        const SizedBox(width: 12),
        PrimaryButton(
          label: 'Save Changes',
          icon: Icons.check,
          onPressed: _saveTransfer,
        ),
      ],
    );
  }
}
