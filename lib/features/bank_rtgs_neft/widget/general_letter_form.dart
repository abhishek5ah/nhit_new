

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ppv_components/common_widgets/button/primary_button.dart';
import 'package:ppv_components/common_widgets/button/secondary_button.dart';
import 'package:ppv_components/common_widgets/custom_dropdown.dart';
import '../models/bank_models/bank_letter_model.dart';
import '../services/letter_storage_service.dart';

class CreateGeneralLetterForm extends StatefulWidget {
  final VoidCallback onCancel;

  const CreateGeneralLetterForm({
    super.key,
    required this.onCancel,
  });

  @override
  State<CreateGeneralLetterForm> createState() => _CreateGeneralLetterFormState();
}

class _CreateGeneralLetterFormState extends State<CreateGeneralLetterForm> {
  final _formKey = GlobalKey<FormState>();
  String selectedStatus = 'Draft';
  final Map<String, String> _statusMap = {
    'Draft': 'LETTER_STATUS_DRAFT',
    'Pending Approval': 'LETTER_STATUS_PENDING_APPROVAL',
    'Approved': 'LETTER_STATUS_APPROVED',
    'Sent': 'LETTER_STATUS_SENT',
    'Acknowledged': 'LETTER_STATUS_ACKNOWLEDGED',
  };

  String get _backendStatus => _statusMap[selectedStatus] ?? 'LETTER_STATUS_DRAFT';

  // Form controllers
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
      _subjectController.text = 'Request for Banking Assistance';
      _letterContentController.text = '''Dear Sir/Madam,

We are writing to request your assistance with the following matter:

[Please describe your request here]

We would appreciate your prompt attention to this matter.

Thank you for your cooperation.

Yours faithfully,
{creator_name}
{creator_designation}''';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Template loaded for General Letter'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Preview functionality removed - now handled by full preview page after creation

  Future<void> _createLetter() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      // Generate temporary letter ID
      final letterId = 'GL${DateTime.now().millisecondsSinceEpoch}';
      
      // Create letter object and store temporarily
      final letter = BankLetter(
        id: letterId,
        reference: 'NHIT/GL/${DateTime.now().year}/${letterId.substring(letterId.length - 6)}',
        type: 'GENERAL_LETTER',
        subject: _subjectController.text.trim(),
        bank: '${_bankNameController.text.trim()} - ${_branchNameController.text.trim()}',
        status: _backendStatus,
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSmallScreen = MediaQuery.of(context).size.width < 900;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionCard(
            icon: Icons.account_balance_outlined,
            iconColor: Colors.green,
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
            iconColor: Colors.blue,
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
                  'Available placeholders: [creator_name], [creator_designation]',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 16),
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
    required String value,
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
