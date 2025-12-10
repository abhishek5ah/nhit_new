import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ppv_components/common_widgets/button/primary_button.dart';
import 'package:ppv_components/common_widgets/button/secondary_button.dart';
import 'package:ppv_components/core/utils/input_formatters.dart';
import 'package:ppv_components/features/user/providers/create_user_form_provider.dart';
import 'package:ppv_components/features/user/services/user_api_service.dart';
import 'package:ppv_components/features/user/data/models/user_api_models.dart';
import 'package:ppv_components/core/services/jwt_token_manager.dart';

class CreateUserScreen extends StatefulWidget {
  const CreateUserScreen({super.key});

  @override
  State<CreateUserScreen> createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends State<CreateUserScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _employeeIdController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _accountHolderController = TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _accountNumberController = TextEditingController();
  final TextEditingController _ifscController = TextEditingController();

  // Password visibility - Single variable for both fields
  bool _isPasswordVisible = false;
  bool _isFormInitializing = true;

  // Dropdown values
  String? _selectedDesignationId;
  String? _selectedDepartmentId;
  String? _selectedRoleId;
  String _selectedStatus = 'Active';

  // File upload
  File? _signatureFile;
  String? _signatureFileName;

  // Loading state
  bool _isSubmitting = false;

  final List<String> _statusOptions = ['Active', 'Inactive'];
  late final Map<String, TextEditingController> _controllerMap;

  @override
  void initState() {
    super.initState();
    _controllerMap = {
      'fullName': _fullNameController,
      'employeeId': _employeeIdController,
      'username': _usernameController,
      'email': _emailController,
      'contactNumber': _contactNumberController,
      'password': _passwordController,
      'accountHolder': _accountHolderController,
      'bankName': _bankNameController,
      'accountNumber': _accountNumberController,
      'ifsc': _ifscController,
    };
    _registerControllerListeners();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDropdowns();
      _initializeFormState();
    });
  }

  void _registerControllerListeners() {
    _controllerMap.forEach((key, controller) {
      controller.addListener(() {
        if (_isFormInitializing) return;
        final provider = context.read<CreateUserFormProvider>();
        provider.updateField(key, controller.text);
      });
    });
  }

  Future<void> _loadDropdowns() async {
    final service = context.read<UserApiService>();
    final orgId = await JwtTokenManager.getOrgId();
    if (orgId != null && orgId.isNotEmpty) {
      await service.loadDropdowns(orgId);
    }
  }

  Future<void> _initializeFormState() async {
    final formProvider = context.read<CreateUserFormProvider>();
    await formProvider.loadFormState();
    if (!mounted) return;
    setState(() {
      _fullNameController.text = formProvider.getField('fullName') ?? '';
      _employeeIdController.text = formProvider.getField('employeeId') ?? '';
      _usernameController.text = formProvider.getField('username') ?? '';
      _emailController.text = formProvider.getField('email') ?? '';
      _contactNumberController.text =
          formProvider.getField('contactNumber') ?? '';
      _passwordController.text = formProvider.getField('password') ?? '';
      _confirmPasswordController.text = '';
      _accountHolderController.text =
          formProvider.getField('accountHolder') ?? '';
      _bankNameController.text = formProvider.getField('bankName') ?? '';
      _accountNumberController.text =
          formProvider.getField('accountNumber') ?? '';
      _ifscController.text = formProvider.getField('ifsc') ?? '';
      _selectedStatus = formProvider.status;
      _selectedDesignationId = formProvider.designationId;
      _selectedDepartmentId = formProvider.departmentId;
      _selectedRoleId = formProvider.roleId;
      _isFormInitializing = false;
    });
  }

  void _onStatusChanged(String value) {
    setState(() {
      _selectedStatus = value;
    });
    if (_isFormInitializing) return;
    context.read<CreateUserFormProvider>().updateStatus(value);
  }

  void _onDesignationChanged(String? value) {
    setState(() {
      _selectedDesignationId = value;
    });
    if (_isFormInitializing) return;
    context.read<CreateUserFormProvider>().updateDesignation(value);
  }

  void _onDepartmentChanged(String? value) {
    setState(() {
      _selectedDepartmentId = value;
    });
    if (_isFormInitializing) return;
    context.read<CreateUserFormProvider>().updateDepartment(value);
  }

  void _onRoleChanged(String? value) {
    setState(() {
      _selectedRoleId = value;
    });
    if (_isFormInitializing) return;
    context.read<CreateUserFormProvider>().updateRole(value);
  }

  void _clearLocalFormData() {
    _isFormInitializing = true;
    for (final controller in _controllerMap.values) {
      controller.clear();
    }
    _confirmPasswordController.clear();
    setState(() {
      _selectedStatus = 'Active';
      _selectedDesignationId = null;
      _selectedDepartmentId = null;
      _selectedRoleId = null;
      _signatureFile = null;
      _signatureFileName = null;
    });
    _isFormInitializing = false;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _employeeIdController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _contactNumberController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _accountHolderController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _ifscController.dispose();
    super.dispose();
  }

  // Email validation
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

  // Phone validation
  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Contact number is required';
    }
    if (value.length != 10) {
      return 'Enter a valid 10-digit phone number';
    }
    return null;
  }

  // IFSC validation (11 characters)
  String? _validateIFSC(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }
    final ifscRegex = RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$');
    if (!ifscRegex.hasMatch(value.toUpperCase())) {
      return 'Enter a valid IFSC code (11 characters)';
    }
    return null;
  }

  // Account number validation
  String? _validateAccountNumber(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }
    if (value.length < 9 || value.length > 18) {
      return 'Account number must be between 9-18 digits';
    }
    return null;
  }

  // Password validation
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
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

  // Confirm password validation
  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  // Generic required field validation
  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  // File picker for signature
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

        // Check file size (max 2MB)
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

  // Submit form
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Check dropdown validations
      if (_selectedDesignationId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a designation'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_selectedDepartmentId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a department'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_selectedRoleId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please assign a role'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _isSubmitting = true;
      });

      try {
        final service = context.read<UserApiService>();
        final tenantId = await JwtTokenManager.getTenantId();
        final orgId = await JwtTokenManager.getOrgId();
        final createdBy = await JwtTokenManager.getUserId();

        if (tenantId == null || orgId == null || createdBy == null) {
          throw Exception('Missing authentication data');
        }

        // Create user request
        final request = CreateUserRequest(
          tenantId: tenantId,
          orgId: orgId,
          email: _emailController.text.trim(),
          name: _fullNameController.text.trim(),
          password: _passwordController.text,
          roleId: _selectedRoleId!,
          departmentId: _selectedDepartmentId,
          designationId: _selectedDesignationId,
          createdBy: createdBy,
          accountHolderName: _accountHolderController.text.trim().isNotEmpty
              ? _accountHolderController.text.trim()
              : null,
          bankName: _bankNameController.text.trim().isNotEmpty
              ? _bankNameController.text.trim()
              : null,
          bankAccountNumber: _accountNumberController.text.trim().isNotEmpty
              ? _accountNumberController.text.trim()
              : null,
          ifscCode: _ifscController.text.trim().isNotEmpty
              ? _ifscController.text.trim()
              : null,
        );

        // Create user
        final result = await service.createUser(request);

        if (!mounted) return;

        if (result.success && result.user != null) {
          // Upload signature if provided
          if (_signatureFile != null) {
            final bytes = await _signatureFile!.readAsBytes();
            final base64Image = base64Encode(bytes);

            final signatureRequest = UploadSignatureRequest(
              userId: result.user!.userId,
              filename: _signatureFileName ?? 'signature.png',
              signatureFile: base64Image,
            );

            await service.uploadSignature(signatureRequest);
          }

          await context.read<CreateUserFormProvider>().clearFormState();
          _clearLocalFormData();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User created successfully!'),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate back to users list
          context.go('/users');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message ?? 'Failed to create user'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error creating user: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
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
                          color: colorScheme.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.add_circle_outline,
                          color: colorScheme.onPrimary.withValues(alpha: 0.9),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Create User',
                            style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Fill in the details to create a new user account',
                            style: textTheme.bodyMedium?.copyWith(
                              color:
                              colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Form Content
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
                              controller: _fullNameController,
                              label: 'Full Name',
                              hintText: 'Enter full name',
                              isRequired: true,
                              validator: (value) =>
                                  _validateRequired(value, 'Full name'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: _employeeIdController,
                              label: 'Employee ID',
                              hintText: 'Enter employee ID',
                              isRequired: true,
                              validator: (value) =>
                                  _validateRequired(value, 'Employee ID'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _usernameController,
                              label: 'Username',
                              hintText: 'Enter username',
                              isRequired: true,
                              validator: (value) =>
                                  _validateRequired(value, 'Username'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: _emailController,
                              label: 'Email Address',
                              hintText: 'Enter email address',
                              isRequired: true,
                              validator: _validateEmail,
                              keyboardType: TextInputType.emailAddress,
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
                              hintText: 'Enter contact number',
                              isRequired: true,
                              validator: _validatePhone,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(10),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDropdown(
                              label: 'Status',
                              value: _selectedStatus,
                              items: _statusOptions,
                              isRequired: true,
                              onChanged: (value) =>
                                  _onStatusChanged(value!),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Organizational Information Section
                  Consumer<UserApiService>(
                    builder: (context, userService, _) {
                      return _buildSectionCard(
                        icon: Icons.business_outlined,
                        title: 'Organizational Information',
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildApiDropdown(
                                  label: 'Designation',
                                  value: _selectedDesignationId,
                                  items: userService.designations,
                                  hintText: 'Select Designation',
                                  isRequired: true,
                                  isLoading: userService.isDropdownsLoading,
                                  onChanged: _onDesignationChanged,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildApiDropdown(
                                  label: 'Department',
                                  value: _selectedDepartmentId,
                                  items: userService.departments,
                                  hintText: 'Select Department',
                                  isRequired: true,
                                  isLoading: userService.isDropdownsLoading,
                                  onChanged: _onDepartmentChanged,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
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
                              hintText: 'Enter password',
                              obscureText: !_isPasswordVisible,
                              isRequired: true,
                              validator: _validatePassword,
                              // No suffixIcon for password field
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: _confirmPasswordController,
                              label: 'Confirm Password',
                              hintText: 'Confirm password',
                              obscureText: !_isPasswordVisible,
                              isRequired: true,
                              validator: _validateConfirmPassword,
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
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Roles & Permissions Section
                  Consumer<UserApiService>(
                    builder: (context, userService, _) {
                      return _buildSectionCard(
                        icon: Icons.verified_user_outlined,
                        title: 'Roles & Permissions',
                        children: [
                          _buildApiDropdown(
                            label: 'Assign Roles',
                            value: _selectedRoleId,
                            items: userService.roles,
                            hintText: 'Select role',
                            isRequired: true,
                            isLoading: userService.isDropdownsLoading,
                            onChanged: _onRoleChanged,
                          ),
                        ],
                      );
                    },
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
                              label: 'Account Holder Name',
                              hintText: 'Enter account holder name',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: _bankNameController,
                              label: 'Bank Name',
                              hintText: 'Enter bank name',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _accountNumberController,
                              label: 'Bank Account Number',
                              hintText: 'Enter account number',
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
                              label: 'IFSC Code',
                              hintText: 'Enter IFSC code (11 characters)',
                              validator: _validateIFSC,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(11),
                                UpperCaseTextFormatter(),
                              ],
                            ),
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
                            'Upload Signature',
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
                                color:
                                colorScheme.outline.withValues(alpha: 0.5),
                              ),
                            ),
                            child: Row(
                              children: [
                                ElevatedButton(
                                  onPressed: _pickSignatureFile,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                    colorScheme.surfaceContainerHighest,
                                    foregroundColor: colorScheme.onSurface,
                                    elevation: 0,
                                  ),
                                  child: const Text('Choose File'),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _signatureFileName ?? 'No file chosen',
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onSurface
                                          .withValues(alpha: 0.6),
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
                          const SizedBox(height: 4),
                          Text(
                            'Upload signature image (PNG, JPG, JPEG - Max 2MB)',
                            style: textTheme.bodySmall?.copyWith(
                              color:
                              colorScheme.onSurface.withValues(alpha: 0.6),
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
                      SecondaryButton(
                        onPressed: () => context.go('/users'),
                        label: 'Cancel',
                      ),
                      const SizedBox(width: 12),
                      PrimaryButton(
                        onPressed: _isSubmitting ? null : _submitForm,
                        label: _isSubmitting ? 'Creating...' : 'Create User',
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
    String? hintText,
    bool obscureText = false,
    Widget? suffixIcon,
    bool isRequired = false,
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
        RichText(
          text: TextSpan(
            text: label,
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface,
            ),
            children: [
              if (isRequired)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.red, fontSize: 14),
                ),
            ],
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
            hintText: hintText,
            hintStyle: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.4),
            ),
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

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    String? hintText,
    bool isRequired = false,
    required Function(String?) onChanged,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface,
            ),
            children: [
              if (isRequired)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.red, fontSize: 14),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          hint: Text(
            hintText ?? 'Select $label',
            style: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: colorScheme.surface,
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
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: textTheme.bodyMedium),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildApiDropdown({
    required String label,
    required String? value,
    required List<DropdownItem> items,
    String? hintText,
    bool isRequired = false,
    bool isLoading = false,
    required Function(String?) onChanged,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface,
            ),
            children: [
              if (isRequired)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.red, fontSize: 14),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          hint: isLoading
              ? Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Loading...',
                      style: TextStyle(
                        color: colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                )
              : Text(
                  hintText ?? 'Select $label',
                  style: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
          decoration: InputDecoration(
            filled: true,
            fillColor: colorScheme.surface,
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
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          items: items.map((DropdownItem item) {
            return DropdownMenuItem<String>(
              value: item.id,
              child: Text(item.name, style: textTheme.bodyMedium),
            );
          }).toList(),
          onChanged: isLoading ? null : onChanged,
        ),
      ],
    );
  }
}
