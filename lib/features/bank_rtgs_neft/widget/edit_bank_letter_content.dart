import 'package:flutter/material.dart';
import 'package:ppv_components/features/bank_rtgs_neft/models/bank_models/bank_letter_model.dart';
import 'package:ppv_components/common_widgets/button/primary_button.dart';
import 'package:ppv_components/common_widgets/button/secondary_button.dart';

class EditBankLetterContent extends StatefulWidget {
  final BankLetter letter;
  final Function(BankLetter) onSave;
  final VoidCallback onCancel;

  const EditBankLetterContent({
    super.key,
    required this.letter,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<EditBankLetterContent> createState() => _EditBankLetterContentState();
}

class _EditBankLetterContentState extends State<EditBankLetterContent> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _referenceController;
  late TextEditingController _typeController;
  late TextEditingController _subjectController;
  late TextEditingController _bankController;
  late TextEditingController _contentController;
  late String _selectedStatus;

  final List<String> _statusOptions = ['Sent', 'Pending Approval', 'Draft', 'Approved'];

  @override
  void initState() {
    super.initState();
    _referenceController = TextEditingController(text: widget.letter.reference);
    _typeController = TextEditingController(text: widget.letter.type);
    _subjectController = TextEditingController(text: widget.letter.subject);
    _bankController = TextEditingController(text: widget.letter.bank);
    _contentController = TextEditingController(text: widget.letter.content);
    _selectedStatus = widget.letter.status;
  }

  @override
  void dispose() {
    _referenceController.dispose();
    _typeController.dispose();
    _subjectController.dispose();
    _bankController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveLetter() {
    if (_formKey.currentState?.validate() ?? false) {
      final updatedLetter = widget.letter.copyWith(
        reference: _referenceController.text,
        type: _typeController.text,
        subject: _subjectController.text,
        bank: _bankController.text,
        status: _selectedStatus,
        content: _contentController.text,
      );
      widget.onSave(updatedLetter);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, colorScheme, theme),
              const SizedBox(height: 16),
              _buildLetterInfoSection(context, colorScheme, theme),
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
                  'Edit Bank Letter',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Update bank letter details and information',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          SecondaryButton(
            label: 'Back to Letters',
            icon: Icons.arrow_back,
            onPressed: widget.onCancel,
          ),
        ],
      ),
    );
  }

  Widget _buildLetterInfoSection(BuildContext context, ColorScheme colorScheme, ThemeData theme) {
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
                Icons.description,
                color: colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Letter Information',
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
                child: _buildInputField("Type", _typeController, theme),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInputField("Subject", _subjectController, theme),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInputField("Bank", _bankController, theme),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatusDropdown(theme),
              ),
              const Expanded(child: SizedBox()),
            ],
          ),
          const SizedBox(height: 16),
          _buildInputField("Content", _contentController, theme, maxLines: 4),
        ],
      ),
    );
  }

  Widget _buildInputField(
      String label,
      TextEditingController controller,
      ThemeData theme, {
        int maxLines = 1,
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
          maxLines: maxLines,
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
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: maxLines > 1 ? 14 : 14,
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
          onPressed: _saveLetter,
        ),
      ],
    );
  }
}
