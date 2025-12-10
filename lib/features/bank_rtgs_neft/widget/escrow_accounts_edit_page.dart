import 'package:flutter/material.dart';
import 'package:ppv_components/features/bank_rtgs_neft/models/escrow_account_response.dart' show EscrowAccountData;
import 'package:ppv_components/common_widgets/button/primary_button.dart';
import 'package:ppv_components/common_widgets/button/secondary_button.dart';

class EditEscrowAccountContent extends StatefulWidget {
  final EscrowAccountData account;
  final Function(EscrowAccountData) onSave;
  final VoidCallback onCancel;

  const EditEscrowAccountContent({
    super.key,
    required this.account,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<EditEscrowAccountContent> createState() => _EditEscrowAccountContentState();
}

class _EditEscrowAccountContentState extends State<EditEscrowAccountContent> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _accountNameController;
  late TextEditingController _accountNumberController;
  late TextEditingController _bankController;
  late TextEditingController _typeController;
  late TextEditingController _balanceController;
  late String _selectedStatus;
  String? _selectedAccountType;
  final List<String> _accountTypeOptions = ['Savings Account', 'Current Account'];

  // Use lowercase values to match backend (e.g. "active", "inactive"),
  // and format them for display in the dropdown.
  final List<String> _statusOptions = ['active', 'inactive'];

  @override
  void initState() {
    super.initState();
    _accountNameController = TextEditingController(text: widget.account.accountName);
    _accountNumberController = TextEditingController(text: widget.account.accountNumber);
    _bankController = TextEditingController(text: widget.account.bankName);
    _typeController = TextEditingController(text: widget.account.accountType);
    _balanceController = TextEditingController(text: widget.account.balance.toString());
    _selectedAccountType = _mapAccountTypeFromApi(widget.account.accountType);
    // Normalise incoming status from backend to lowercase and
    // fall back to the first option if it's unexpected.
    final backendStatus = widget.account.status.toLowerCase();
    _selectedStatus = _statusOptions.contains(backendStatus)
        ? backendStatus
        : _statusOptions.first;
  }

  @override
  void dispose() {
    _accountNameController.dispose();
    _accountNumberController.dispose();
    _bankController.dispose();
    _typeController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  void _saveAccount() {
    if (_formKey.currentState?.validate() ?? false) {
      final updatedAccount = EscrowAccountData(
        accountId: widget.account.accountId,
        accountName: _accountNameController.text,
        accountNumber: _accountNumberController.text,
        bankName: _bankController.text,
        branchName: widget.account.branchName,
        ifscCode: widget.account.ifscCode,
        balance: double.tryParse(_balanceController.text) ?? widget.account.balance,
        availableBalance: widget.account.availableBalance,
        accountType: _mapAccountTypeToApi(_selectedAccountType ?? widget.account.accountType),
        status: _selectedStatus,
        description: widget.account.description,
        authorizedSignatories: widget.account.authorizedSignatories,
        createdById: widget.account.createdById,
        organizationId: widget.account.organizationId,
        createdAt: widget.account.createdAt,
        updatedAt: DateTime.now(),
      );
      widget.onSave(updatedAccount);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal:24, vertical: 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              _buildHeader(context, colorScheme, theme),
              const SizedBox(height: 16),

              // Basic Information Section
              _buildBasicInformationSection(context, colorScheme, theme),
              const SizedBox(height: 24),

              // Action Buttons
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
                  'Edit Escrow Account',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Update escrow account details and information',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          SecondaryButton(
            label: 'Back to Accounts',
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
                Icons.account_balance,
                color: colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Account Information',
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
                child: _buildInputField("Account Name", _accountNameController, theme),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInputField("Account Number", _accountNumberController, theme),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInputField("Bank", _bankController, theme),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildAccountTypeDropdown(theme),
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
                child: _buildInputField("Balance", _balanceController, theme, readOnly: true),
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
      {bool readOnly = false}
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
            if (!readOnly && (val == null || val.isEmpty)) {
              return 'Please enter $label';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildAccountTypeDropdown(ThemeData theme) {
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Type',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedAccountType,
          decoration: InputDecoration(
            filled: true,
            fillColor: colorScheme.surface,
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: colorScheme.outline.withValues(alpha: 0.5)),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          items: _accountTypeOptions.map((type) {
            return DropdownMenuItem<String>(
              value: type,
              child: Text(type),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedAccountType = value;
              });
            }
          },
          validator: (val) {
            if (val == null || val.isEmpty) {
              return 'Please select Type';
            }
            return null;
          },
        ),
      ],
    );
  }

  String _mapAccountTypeFromApi(String apiType) {
    switch (apiType.toUpperCase()) {
      case 'SAVINGS':
        return 'Savings Account';
      case 'CURRENT':
        return 'Current Account';
      default:
        return 'Current Account';
    }
  }

  String _mapAccountTypeToApi(String value) {
    switch (value) {
      case 'Savings Account':
        return 'SAVINGS';
      case 'Current Account':
        return 'CURRENT';
      default:
        return value.toUpperCase();
    }
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
            // Capitalize for display while keeping the value lowercase.
            final label = status[0].toUpperCase() + status.substring(1).toLowerCase();
            return DropdownMenuItem<String>(
              value: status,
              child: Text(label),
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
          onPressed: _saveAccount,
        ),
      ],
    );
  }
}
