import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ppv_components/common_widgets/button/primary_button.dart';
import 'package:ppv_components/common_widgets/button/secondary_button.dart';
import 'package:ppv_components/common_widgets/custom_dropdown.dart';
import '../models/bank_models/bank_letter_model.dart';
import '../services/letter_storage_service.dart';
import '../models/transfer_models/transfer_enums.dart';
import '../models/transfer_models/transfer_model.dart';
import '../models/transfer_models/transfer_leg.dart';

class CreateTransferLetterForm extends StatefulWidget {
  final VoidCallback onCancel;

  const CreateTransferLetterForm({
    super.key,
    required this.onCancel,
  });

  @override
  State<CreateTransferLetterForm> createState() => _CreateTransferLetterFormState();
}

class _CreateTransferLetterFormState extends State<CreateTransferLetterForm> {
  final _formKey = GlobalKey<FormState>();
  String selectedStatus = 'Draft';
  final Map<String, String> _statusMap = {
    'Draft': 'LETTER_STATUS_DRAFT',
    'Pending Approval': 'LETTER_STATUS_PENDING_APPROVAL',
    'Approved': 'LETTER_STATUS_APPROVED',
    'Sent': 'LETTER_STATUS_SENT',
    'Acknowledged': 'LETTER_STATUS_ACKNOWLEDGED',
  };
  bool _isSubmitting = false;

  // Form controllers
  Transfer? selectedTransfer;
  final List<Transfer> availableTransfers = [
    Transfer(
      transferId: '1',
      transferReference: 'TR001',
      transferType: TransferType.internal,
      transferMode: TransferMode.oneToOne,
      totalAmount: 10000.00,
      purpose: 'Salary Transfer',
      remarks: 'Monthly salary payment',
      status: TransferStatus.approved,
      requestedById: '123e4567-e89b-12d3-a456-426614174000',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      transferLegs: [
        TransferLeg(
          id: '1-1',
          transferId: '1',
          sourceAccountId: 'ACC001',
          destinationAccountId: 'ACC002',
          amount: 10000.00,
          sourceAccount: SimpleEscrowAccount(
            id: 'ACC001',
            accountNumber: '1234567890',
            accountName: 'Main Account',
          ),
          destinationAccount: SimpleEscrowAccount(
            id: 'ACC002',
            accountNumber: '0987654321',
            accountName: 'Salary Account',
          ),
        ),
      ],
    ),
    Transfer(
      transferId: '2',
      transferReference: 'TR002',
      transferType: TransferType.external,
      transferMode: TransferMode.oneToMany,
      totalAmount: 25000.00,
      purpose: 'Vendor Payment',
      remarks: 'Payment for services',
      status: TransferStatus.completed,
      requestedById: '123e4567-e89b-12d3-a456-426614174000',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      transferLegs: [
        TransferLeg(
          id: '2-1',
          transferId: '2',
          sourceAccountId: 'ACC003',
          destinationVendorId: 'VEN001',
          amount: 25000.00,
          sourceAccount: SimpleEscrowAccount(
            id: 'ACC003',
            accountNumber: '5555666677',
            accountName: 'Project Account',
          ),
          destinationVendor: SimpleVendor(
            id: 'VEN001',
            name: 'ABC Suppliers',
            code: 'ABC001',
          ),
        ),
      ],
    ),
  ];
  final _bankNameController = TextEditingController();
  final _branchNameController = TextEditingController();
  final _bankAddressController = TextEditingController();
  final _subjectController = TextEditingController();
  final _letterContentController = TextEditingController();

  @override
  void dispose() {
    _bankNameController.dispose();
    _branchNameController.dispose();
    _bankAddressController.dispose();
    _subjectController.dispose();
    _letterContentController.dispose();
    super.dispose();
  }

  void _loadTemplate() {
    setState(() {
      _subjectController.text = 'Request for Fund Transfer - {transfer_reference}';
      _letterContentController.text = '''Dear Sir/Madam,

We request you to kindly process the following fund transfer from our account:

Transfer Details:
- Transfer Reference: {transfer_reference}
- From Account: {from_account_name} ({from_account_number})
- To Account: {to_account_name} ({to_account_number})
- Amount: ₹{transfer_amount}
- Purpose: {transfer_purpose}

Please process this transfer at your earliest convenience and confirm the same.

Thank you for your cooperation.

Yours faithfully,
{creator_name}
{creator_designation}''';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Template loaded for Transfer Letter'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _createLetter() async {
    if (!_formKey.currentState!.validate() || selectedTransfer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields and select a transfer.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      final saveAsStatus = _statusMap[selectedStatus] ?? 'LETTER_STATUS_DRAFT';

      // Generate temporary letter ID
      final letterId = 'TL${DateTime.now().millisecondsSinceEpoch}';
      
      // Create letter object and store temporarily
      final letter = BankLetter(
        id: letterId,
        reference: 'NHIT/TL/${DateTime.now().year}/${selectedTransfer!.transferReference}',
        type: 'TRANSFER_LETTER',
        subject: _subjectController.text.trim(),
        bank: '${_bankNameController.text.trim()} - ${_branchNameController.text.trim()}',
        status: saveAsStatus,
        createdBy: 'Admin User',
        date: DateFormat('dd MMMM yyyy').format(DateTime.now()),
        content: _letterContentController.text.trim(),
      );
      
      // Store letter in memory
      LetterStorageService().storeLetter(letterId, letter);
      
      // Navigate directly to full preview page
      if (mounted) {
        context.go('/escrow/bank-letter/preview/$letterId');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 900;
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionCard(
            icon: Icons.swap_horiz,
            iconColor: Colors.teal,
            title: 'Transfer Details',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDropdownField(
                  label: 'Select Transfer',
                  value: selectedTransfer?.displayText,
                  items: availableTransfers.map((t) => t.displayText).toList(),
                  isRequired: true,
                  onChanged: (value) {
                    setState(() {
                      selectedTransfer = availableTransfers.firstWhere(
                        (t) => t.displayText == value,
                        orElse: () => availableTransfers.first,
                      );
                    });
                  },
                ),
                const SizedBox(height: 16),
                _buildFieldRow(
                  isSmallScreen: isSmallScreen,
                  children: [
                    _buildDropdownField(
                      label: 'Status',
                      value: selectedStatus,
                      items: const [
                        'Draft',
                        'Pending Approval',
                        'Approved',
                        'Sent',
                        'Acknowledged',
                      ],
                      isRequired: true,
                      onChanged: (value) {
                        setState(() {
                          selectedStatus = value ?? 'Draft';
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildSectionCard(
            icon: Icons.account_balance_outlined,
            iconColor: Colors.blue,
            title: 'Bank Information',
            child: Column(
              children: [
                _buildFieldRow(
                  isSmallScreen: isSmallScreen,
                  children: [
                    _buildTextField(
                      label: 'Bank Name',
                      hint: 'Enter bank name',
                      controller: _bankNameController,
                      isRequired: true,
                    ),
                    _buildTextField(
                      label: 'Branch Name',
                      hint: 'Enter branch name',
                      controller: _branchNameController,
                      isRequired: true,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'Bank Address',
                  hint: 'Enter bank address (optional)',
                  controller: _bankAddressController,
                  maxLines: 3,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildSectionCard(
            icon: Icons.description_outlined,
            iconColor: Colors.orange,
            title: 'Letter Details',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isSmallScreen) ...[
                  _buildTextField(
                    label: 'Subject',
                    hint: 'Enter letter subject',
                    controller: _subjectController,
                    isRequired: true,
                  ),
                  const SizedBox(height: 12),
                  SecondaryButton(
                    onPressed: _loadTemplate,
                    icon: Icons.file_download_outlined,
                    label: 'Load Template',
                  ),
                ] else ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: _buildTextField(
                          label: 'Subject',
                          hint: 'Enter letter subject',
                          controller: _subjectController,
                          isRequired: true,
                        ),
                      ),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: 190,
                        height: 56,
                        child: SecondaryButton(
                          onPressed: _loadTemplate,
                          icon: Icons.file_download_outlined,
                          label: 'Load Template',
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'Letter Content',
                  hint: 'Enter letter content',
                  controller: _letterContentController,
                  isRequired: true,
                  maxLines: 8,
                ),
                const SizedBox(height: 8),
                Text(
                  'Available placeholders: [transfer_reference], [from_account_name], [to_account_name], [transfer_amount], [creator_name]',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildSectionCard(
            icon: Icons.done_all_outlined,
            iconColor: Colors.purple,
            title: 'Actions',
            child: isSmallScreen
                ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SecondaryButton(
                  onPressed: widget.onCancel,
                  icon: Icons.cancel_outlined,
                  label: 'Cancel',
                ),
                const SizedBox(height: 12),
                PrimaryButton(
                  onPressed: _createLetter,
                  icon: Icons.send,
                  label: 'Create Letter',
                  isLoading: _isSubmitting,
                ),
              ],
            )
                : Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SecondaryButton(
                  onPressed: widget.onCancel,
                  icon: Icons.cancel_outlined,
                  label: 'Cancel',
                ),
                const SizedBox(width: 12),
                PrimaryButton(
                  onPressed: _createLetter,
                  icon: Icons.send,
                  label: 'Create Letter',
                  isLoading: _isSubmitting,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required Widget child,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildFieldRow({
    required bool isSmallScreen,
    required List<Widget> children,
  }) {
    if (isSmallScreen) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1) const SizedBox(height: 12),
          ],
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < children.length; i++) ...[
          Expanded(child: children[i]),
          if (i != children.length - 1) const SizedBox(width: 16),
        ],
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    bool isRequired = false,
    int maxLines = 1,
    String? helperText,
    bool enabled = true,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            if (isRequired) ...[
              const SizedBox(width: 4),
              Text(
                '*',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          enabled: enabled,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            helperText: helperText,
            hintStyle: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
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
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: colorScheme.outline.withValues(alpha: 0.5)),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: maxLines > 1 ? 16 : 14,
            ),
            filled: !enabled,
            fillColor: enabled ? null : colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          ),
          validator: isRequired
              ? (value) {
            if (value == null || value.isEmpty) {
              return 'This field is required';
            }
            return null;
          }
              : null,
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    bool isRequired = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            if (isRequired) ...[
              const SizedBox(width: 4),
              Text(
                '*',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        CustomDropdown(
          value: value,
          items: items,
          hint: 'Select $label',
          onChanged: onChanged,
        ),
      ],
    );
  }
}
