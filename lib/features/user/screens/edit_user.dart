import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:ppv_components/features/user/model/user_model.dart';
import 'package:ppv_components/common_widgets/dropdown.dart';

class EditUserPage extends StatefulWidget {
  final User user;

  const EditUserPage({
    super.key,
    required this.user,
  });

  @override
  State<EditUserPage> createState() => _EditUserPageState();
}

class _EditUserPageState extends State<EditUserPage> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  late TextEditingController _nameController;
  late TextEditingController _employeeIdController;
  late TextEditingController _contactNumberController;
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  late TextEditingController _accountHolderController;
  late TextEditingController _bankNameController;
  late TextEditingController _bankAccountController;
  late TextEditingController _ifscController;

  bool _isPasswordVisible = false;

  String? _selectedDesignation;
  String? _selectedDepartment;
  String? _selectedRole;
  late String _selectedStatus;

  File? _signatureFile;
  String? _signatureFileName;

  final List<String> _designations = [
    'Software Developer',
    'Senior Developer',
    'Team Lead',
    'Project Manager',
    'Business Analyst',
    'Quality Assurance',
    'DevOps Engineer',
    'UI/UX Designer',
    'Product Manager',
    'Technical Architect',
  ];

  final List<String> _departments = [
    'Engineering',
    'Human Resources',
    'Finance',
    'Marketing',
    'Sales',
    'Operations',
    'Customer Support',
    'Research & Development',
    'Quality Assurance',
    'Administration',
  ];

  final List<String> _roles = [
    'User',
    'Admin',
    'Super Admin',
    'Manager',
  ];

  final List<String> _statusOptions = ['Active', 'Inactive'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _employeeIdController = TextEditingController(text: widget.user.employeeId ?? '');
    _contactNumberController = TextEditingController(text: widget.user.contactNumber ?? '');
    _usernameController = TextEditingController(text: widget.user.username);
    _emailController = TextEditingController(text: widget.user.email);
    _accountHolderController = TextEditingController(text: widget.user.accountHolder ?? '');
    _bankNameController = TextEditingController(text: widget.user.bankName ?? '');
    _bankAccountController = TextEditingController(text: widget.user.bankAccount ?? '');
    _ifscController = TextEditingController(text: widget.user.ifsc ?? '');

    _selectedStatus = widget.user.isActive ? 'Active' : 'Inactive';
    _selectedDesignation = widget.user.designation;
    _selectedDepartment = widget.user.department;
    _selectedRole = widget.user.roles.isNotEmpty ? widget.user.roles.first : null;
    _signatureFileName = widget.user.signatureUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _employeeIdController.dispose();
    _contactNumberController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _accountHolderController.dispose();
    _bankNameController.dispose();
    _bankAccountController.dispose();
    _ifscController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Contact number is required';
    }
    if (value.length != 10) {
      return 'Enter a valid 10-digit phone number';
    }
    return null;
  }

  String? _validateIFSC(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    final ifscRegex = RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$');
    if (!ifscRegex.hasMatch(value.toUpperCase())) {
      return 'Enter a valid IFSC code (11 characters)';
    }
    return null;
  }

  String? _validateAccountNumber(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    if (value.length < 9 || value.length > 18) {
      return 'Account number must be between 9-18 digits';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (_passwordController.text.isEmpty) {
      return null;
    }
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  Future<void> _pickSignatureFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['png', 'jpg', 'jpeg'],
        allowMultiple: false,
      );

      if (result != null) {
        File file = File(result.files.single.path!);
        int fileSizeInBytes = await file.length();
        double fileSizeInMB = fileSizeInBytes / (1024 * 1024);

        if (fileSizeInMB > 2) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('File size must be less than 2MB'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        setState(() {
          _signatureFile = file;
          _signatureFileName = result.files.single.name;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_selectedDesignation == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a designation'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_selectedDepartment == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a department'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_selectedRole == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please assign a role'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final updatedUser = widget.user.copyWith(
        name: _nameController.text,
        employeeId: _employeeIdController.text,
        contactNumber: _contactNumberController.text,
        username: _usernameController.text,
        email: _emailController.text,
        isActive: _selectedStatus == 'Active',
        designation: _selectedDesignation,
        department: _selectedDepartment,
        roles: [_selectedRole!],
        accountHolder: _accountHolderController.text,
        bankName: _bankNameController.text,
        bankAccount: _bankAccountController.text,
        ifsc: _ifscController.text,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, updatedUser);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.green[600],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.edit_outlined,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Edit User',
                            style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Update user details and information',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, size: 18),
                        label: const Text('Back to Users'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colorScheme.onSurface,
                          side: BorderSide(
                            color: colorScheme.outline.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Form
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Basic Information Section
                  _buildSectionCard(
                    icon: Icons.person_outline,
                    title: 'Basic Information',
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _nameController,
                              label: 'Name',
                              validator: (value) => _validateRequired(value, 'Name'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: _employeeIdController,
                              label: 'Employee Id',
                              validator: (value) => _validateRequired(value, 'Employee ID'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _contactNumberController,
                              label: 'Contact Number',
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(10),
                              ],
                              validator: _validatePhone,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: _usernameController,
                              label: 'Username',
                              validator: (value) => _validateRequired(value, 'Username'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdownField(
                              label: 'Active:',
                              value: _selectedStatus,
                              items: _statusOptions,
                              onChanged: (value) {
                                setState(() {
                                  _selectedStatus = value!;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: _emailController,
                              label: 'Email Address',
                              keyboardType: TextInputType.emailAddress,
                              validator: _validateEmail,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Security Information Section
                  _buildSectionCard(
                    icon: Icons.security_outlined,
                    title: 'Security Information',
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _passwordController,
                              label: 'Password',
                              obscureText: !_isPasswordVisible,
                              validator: _validatePassword,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: _confirmPasswordController,
                              label: 'Confirm Password',
                              obscureText: !_isPasswordVisible,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                              validator: _validateConfirmPassword,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Organizational Information Section
                  _buildSectionCard(
                    icon: Icons.business_outlined,
                    title: 'Organizational Information',
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdownField(
                              label: 'Designation',
                              value: _selectedDesignation,
                              items: _designations,
                              onChanged: (value) {
                                setState(() {
                                  _selectedDesignation = value;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDropdownField(
                              label: 'Department',
                              value: _selectedDepartment,
                              items: _departments,
                              onChanged: (value) {
                                setState(() {
                                  _selectedDepartment = value;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Roles & Permissions Section - FIXED
                  _buildSectionCard(
                    icon: Icons.verified_user_outlined,
                    title: 'Roles & Permissions',
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Roles',
                            style: textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: colorScheme.outline.withValues(alpha: 0.5),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Wrap(
                              spacing: 8,
                              children: [
                                if (_selectedRole != null)
                                  Chip(
                                    label: Text(_selectedRole!),
                                    deleteIcon: const Icon(Icons.close, size: 16),
                                    onDeleted: () {
                                      setState(() {
                                        _selectedRole = null;
                                      });
                                    },
                                    backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                                    side: BorderSide.none,
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Select role to add',
                                style: textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: colorScheme.outline),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: DropdownButton<String>(
                                  value: null,
                                  hint: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    child: Text(
                                      'Select role to add',
                                      style: TextStyle(
                                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                                      ),
                                    ),
                                  ),
                                  items: _roles
                                      .where((role) => role != _selectedRole)
                                      .map((String item) {
                                    return DropdownMenuItem<String>(
                                      value: item,
                                      child: Text(
                                        item,
                                        style: TextStyle(
                                          color: colorScheme.onSurface,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() {
                                        _selectedRole = value;
                                      });
                                    }
                                  },
                                  icon: Icon(
                                    Icons.arrow_drop_down,
                                    color: colorScheme.onSurface,
                                  ),
                                  isExpanded: true,
                                  underline: const SizedBox(),
                                  dropdownColor: colorScheme.surface,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Signature Section
                  _buildSectionCard(
                    icon: Icons.draw_outlined,
                    title: 'Signature',
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Add Your Signature',
                            style: textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: colorScheme.outline.withValues(alpha: 0.5),
                              ),
                            ),
                            child: Row(
                              children: [
                                ElevatedButton(
                                  onPressed: _pickSignatureFile,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: colorScheme.surfaceContainerHighest,
                                    foregroundColor: colorScheme.onSurface,
                                    elevation: 0,
                                  ),
                                  child: const Text('Choose file'),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _signatureFileName ?? 'No file chosen',
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (_signatureFile != null)
                                  IconButton(
                                    icon: const Icon(Icons.close, size: 20),
                                    onPressed: () {
                                      setState(() {
                                        _signatureFile = null;
                                        _signatureFileName = null;
                                      });
                                    },
                                    tooltip: 'Remove file',
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Banking Information Section
                  _buildSectionCard(
                    icon: Icons.account_balance_outlined,
                    title: 'Banking Information',
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _accountHolderController,
                              label: 'Name of Account holder:',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: _bankNameController,
                              label: 'Bank Name:',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _bankAccountController,
                              label: 'Bank Account:',
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(18),
                              ],
                              validator: _validateAccountNumber,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: _ifscController,
                              label: 'IFSC:',
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(11),
                                UpperCaseTextFormatter(),
                              ],
                              validator: _validateIFSC,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, size: 18),
                        label: const Text('Cancel'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          side: BorderSide(
                            color: colorScheme.outline.withValues(alpha: 0.5),
                          ),
                          foregroundColor: colorScheme.onSurface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: _submitForm,
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('Update User'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.5),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Column(children: children),
        ],
      ),
    );
  }

  Widget _buildTextField({
    TextEditingController? controller,
    required String label,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          validator: validator,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            filled: true,
            fillColor: colorScheme.surface,
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: colorScheme.outline.withValues(alpha: 0.5),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: colorScheme.outline.withValues(alpha: 0.5),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: colorScheme.primary),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
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

// Custom TextInputFormatter for uppercase
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
