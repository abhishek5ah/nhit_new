import 'package:flutter/material.dart';
import 'package:ppv_components/common_widgets/button/primary_button.dart';
import 'package:ppv_components/common_widgets/button/secondary_button.dart';
import 'package:ppv_components/common_widgets/dropdown.dart';
import '../models/bank_models/bank_letter_form_data.dart';
import 'bank_letter_preview_page.dart';

class BankLetterFormPage extends StatefulWidget {
  const BankLetterFormPage({super.key});

  @override
  State<BankLetterFormPage> createState() => _BankLetterFormPageState();
}

class _BankLetterFormPageState extends State<BankLetterFormPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Form Controllers
  final _bankNameController = TextEditingController();
  final _branchNameController = TextEditingController();
  final _bankAddressController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _accountHolderNameController = TextEditingController();
  final _ifscCodeController = TextEditingController();
  final _subjectController = TextEditingController();
  final _contentController = TextEditingController();
  final _requestedByController = TextEditingController();
  final _designationController = TextEditingController();
  
  String selectedLetterType = 'Transfer Letter';
  DateTime selectedDate = DateTime.now();

  final List<String> letterTypes = [
    'Transfer Letter',
    'Payment Letter',
    'General Letter',
    'Account Opening Letter',
    'Closure Letter',
  ];

  @override
  void dispose() {
    _bankNameController.dispose();
    _branchNameController.dispose();
    _bankAddressController.dispose();
    _accountNumberController.dispose();
    _accountHolderNameController.dispose();
    _ifscCodeController.dispose();
    _subjectController.dispose();
    _contentController.dispose();
    _requestedByController.dispose();
    _designationController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _bankNameController.clear();
    _branchNameController.clear();
    _bankAddressController.clear();
    _accountNumberController.clear();
    _accountHolderNameController.clear();
    _ifscCodeController.clear();
    _subjectController.clear();
    _contentController.clear();
    _requestedByController.clear();
    _designationController.clear();
    setState(() {
      selectedLetterType = 'Transfer Letter';
      selectedDate = DateTime.now();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Form reset successfully'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  void _createLetter() {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Form data would be sent to backend API here
    // final formData = BankLetterFormData(...)

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Bank letter created successfully!'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );

    // Optionally navigate back or clear form
    _resetForm();
  }

  void _previewLetter() {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields to preview'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final formData = BankLetterFormData(
      letterType: selectedLetterType,
      bankName: _bankNameController.text.trim(),
      branchName: _branchNameController.text.trim(),
      bankAddress: _bankAddressController.text.trim(),
      accountNumber: _accountNumberController.text.trim(),
      accountHolderName: _accountHolderNameController.text.trim(),
      ifscCode: _ifscCodeController.text.trim(),
      subject: _subjectController.text.trim(),
      content: _contentController.text.trim(),
      requestedBy: _requestedByController.text.trim(),
      designation: _designationController.text.trim(),
      date: selectedDate,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BankLetterPreviewPage(formData: formData),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSmallScreen = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(isSmallScreen ? 12 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, isSmallScreen),
              const SizedBox(height: 24),
              _buildFormSection(context, isSmallScreen),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isSmallScreen) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.description_outlined,
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
                      'Create Bank Letter',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Fill in the details to generate a professional bank letter',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              if (!isSmallScreen) ...[
                const SizedBox(width: 16),
                SecondaryButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icons.arrow_back,
                  label: 'Back',
                ),
              ],
            ],
          ),
          if (isSmallScreen) ...[
            const SizedBox(height: 16),
            SecondaryButton(
              onPressed: () => Navigator.pop(context),
              icon: Icons.arrow_back,
              label: 'Back',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFormSection(BuildContext context, bool isSmallScreen) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline, width: 0.5),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Title
            Row(
              children: [
                Icon(Icons.edit_document, color: colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Letter Details',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Letter Type and Date
            isSmallScreen
                ? Column(
                    children: [
                      _buildDropdownField(
                        label: 'Letter Type',
                        value: selectedLetterType,
                        items: letterTypes,
                        isRequired: true,
                        onChanged: (value) {
                          setState(() {
                            selectedLetterType = value ?? letterTypes[0];
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildDateField(
                        label: 'Date',
                        date: selectedDate,
                        onTap: _selectDate,
                        isRequired: true,
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: _buildDropdownField(
                          label: 'Letter Type',
                          value: selectedLetterType,
                          items: letterTypes,
                          isRequired: true,
                          onChanged: (value) {
                            setState(() {
                              selectedLetterType = value ?? letterTypes[0];
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDateField(
                          label: 'Date',
                          date: selectedDate,
                          onTap: _selectDate,
                          isRequired: true,
                        ),
                      ),
                    ],
                  ),
            const SizedBox(height: 16),

            // Bank Details Section
            Text(
              'Bank Details',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),

            // Bank Name and Branch Name
            isSmallScreen
                ? Column(
                    children: [
                      _buildTextField(
                        label: 'Bank Name',
                        hint: 'Enter bank name',
                        controller: _bankNameController,
                        isRequired: true,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        label: 'Branch Name',
                        hint: 'Enter branch name',
                        controller: _branchNameController,
                        isRequired: true,
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          label: 'Bank Name',
                          hint: 'Enter bank name',
                          controller: _bankNameController,
                          isRequired: true,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          label: 'Branch Name',
                          hint: 'Enter branch name',
                          controller: _branchNameController,
                          isRequired: true,
                        ),
                      ),
                    ],
                  ),
            const SizedBox(height: 16),

            // Bank Address
            _buildTextField(
              label: 'Bank Address',
              hint: 'Enter complete bank address',
              controller: _bankAddressController,
              isRequired: true,
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // Account Details Section
            Text(
              'Account Details',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),

            // Account Holder Name
            _buildTextField(
              label: 'Account Holder Name',
              hint: 'Enter account holder name',
              controller: _accountHolderNameController,
              isRequired: true,
            ),
            const SizedBox(height: 16),

            // Account Number and IFSC Code
            isSmallScreen
                ? Column(
                    children: [
                      _buildTextField(
                        label: 'Account Number',
                        hint: 'Enter account number',
                        controller: _accountNumberController,
                        isRequired: true,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        label: 'IFSC Code',
                        hint: 'Enter IFSC code',
                        controller: _ifscCodeController,
                        isRequired: true,
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          label: 'Account Number',
                          hint: 'Enter account number',
                          controller: _accountNumberController,
                          isRequired: true,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          label: 'IFSC Code',
                          hint: 'Enter IFSC code',
                          controller: _ifscCodeController,
                          isRequired: true,
                        ),
                      ),
                    ],
                  ),
            const SizedBox(height: 24),

            // Letter Content Section
            Text(
              'Letter Content',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),

            // Subject
            _buildTextField(
              label: 'Subject',
              hint: 'Enter letter subject',
              controller: _subjectController,
              isRequired: true,
            ),
            const SizedBox(height: 16),

            // Content
            _buildTextField(
              label: 'Letter Content',
              hint: 'Enter the main content of the letter',
              controller: _contentController,
              isRequired: true,
              maxLines: 8,
            ),
            const SizedBox(height: 24),

            // Signature Section
            Text(
              'Signature Details',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),

            // Requested By and Designation
            isSmallScreen
                ? Column(
                    children: [
                      _buildTextField(
                        label: 'Requested By',
                        hint: 'Enter your name',
                        controller: _requestedByController,
                        isRequired: true,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        label: 'Designation',
                        hint: 'Enter your designation',
                        controller: _designationController,
                        isRequired: true,
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          label: 'Requested By',
                          hint: 'Enter your name',
                          controller: _requestedByController,
                          isRequired: true,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          label: 'Designation',
                          hint: 'Enter your designation',
                          controller: _designationController,
                          isRequired: true,
                        ),
                      ),
                    ],
                  ),
            const SizedBox(height: 32),

            // Action Buttons
            if (isSmallScreen) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PrimaryButton(
                    onPressed: _createLetter,
                    icon: Icons.check_circle_outline,
                    label: 'Create',
                  ),
                  const SizedBox(height: 12),
                  SecondaryButton(
                    onPressed: _previewLetter,
                    icon: Icons.visibility_outlined,
                    label: 'Preview',
                  ),
                  const SizedBox(height: 12),
                  SecondaryButton(
                    onPressed: _resetForm,
                    icon: Icons.refresh,
                    label: 'Reset',
                  ),
                ],
              ),
            ] else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SecondaryButton(
                    onPressed: _resetForm,
                    icon: Icons.refresh,
                    label: 'Reset',
                  ),
                  const SizedBox(width: 12),
                  SecondaryButton(
                    onPressed: _previewLetter,
                    icon: Icons.visibility_outlined,
                    label: 'Preview',
                  ),
                  const SizedBox(width: 12),
                  PrimaryButton(
                    onPressed: _createLetter,
                    icon: Icons.check_circle_outline,
                    label: 'Create',
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    bool isRequired = false,
    int maxLines = 1,
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
              const Text('*', style: TextStyle(color: Colors.red, fontSize: 16)),
            ],
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5)),
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
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: maxLines > 1 ? 16 : 14,
            ),
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
              const Text('*', style: TextStyle(color: Colors.red, fontSize: 16)),
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

  Widget _buildDateField({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
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
              const Text('*', style: TextStyle(color: Colors.red, fontSize: 16)),
            ],
          ],
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: colorScheme.outline),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${date.day}/${date.month}/${date.year}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Icon(Icons.calendar_today, size: 20, color: colorScheme.primary),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
