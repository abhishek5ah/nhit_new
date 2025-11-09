import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:ppv_components/common_widgets/dropdown.dart';

import '../models/vendor_model.dart';

class EditVendorScreen extends StatefulWidget {
  final dynamic vendor;

  const EditVendorScreen({
    super.key,
    required this.vendor,
  });

  @override
  State<EditVendorScreen> createState() => _EditVendorScreenState();
}

class _EditVendorScreenState extends State<EditVendorScreen> {
  final _formKey = GlobalKey<FormState>();

  // Basic Information Controllers
  late TextEditingController _vendorNameController;
  late TextEditingController _vendorCodeController;
  late TextEditingController _vendorTypeController;
  late TextEditingController _fromAccountTypeController;
  late TextEditingController _projectController;
  late TextEditingController _activityTypeController;
  late TextEditingController _vendorNickNameController;
  late TextEditingController _shortNameController;

  // Contact Information Controllers
  late TextEditingController _vendorEmailController;
  late TextEditingController _vendorMobileController;

  // Tax Information Controllers
  late TextEditingController _gstinController;
  late TextEditingController _panController;
  late TextEditingController _section206ABController;
  late TextEditingController _incomeTaxTypeController;
  late TextEditingController _materialNatureController;

  // MSME Information Controllers
  late TextEditingController _msmeClassificationController;
  late TextEditingController _msmeRegNumberController;
  late TextEditingController _msmeStartDateController;
  late TextEditingController _msmeEndDateController;

  // Banking Information Controllers - for Primary Account
  late TextEditingController _bankAccountNameController;
  late TextEditingController _bankAccountNumberController;
  late TextEditingController _bankNameController;
  late TextEditingController _ifscCodeController;
  late TextEditingController _branchNameController;
  late TextEditingController _beneficiaryNameController;

  // Location Information Controllers
  late TextEditingController _countryController;
  late TextEditingController _stateController;
  late TextEditingController _cityController;
  late TextEditingController _addressController;

  // Dropdown values
  String? _status;
  bool _isGstDefaulted = false;
  bool _isMsme = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _populateData();
  }

  void _initializeControllers() {
    _vendorNameController = TextEditingController();
    _vendorCodeController = TextEditingController();
    _vendorTypeController = TextEditingController();
    _fromAccountTypeController = TextEditingController();
    _projectController = TextEditingController();
    _activityTypeController = TextEditingController();
    _vendorNickNameController = TextEditingController();
    _shortNameController = TextEditingController();
    _vendorEmailController = TextEditingController();
    _vendorMobileController = TextEditingController();
    _gstinController = TextEditingController();
    _panController = TextEditingController();
    _section206ABController = TextEditingController();
    _incomeTaxTypeController = TextEditingController();
    _materialNatureController = TextEditingController();
    _msmeClassificationController = TextEditingController();
    _msmeRegNumberController = TextEditingController();
    _msmeStartDateController = TextEditingController();
    _msmeEndDateController = TextEditingController();
    _bankAccountNameController = TextEditingController();
    _bankAccountNumberController = TextEditingController();
    _bankNameController = TextEditingController();
    _ifscCodeController = TextEditingController();
    _branchNameController = TextEditingController();
    _beneficiaryNameController = TextEditingController();
    _countryController = TextEditingController();
    _stateController = TextEditingController();
    _cityController = TextEditingController();
    _addressController = TextEditingController();
  }

  void _populateData() {
    _vendorNameController.text = widget.vendor.name ?? '';
    _vendorCodeController.text = widget.vendor.code ?? '';
    _vendorTypeController.text = widget.vendor.vendorType ?? '';
    _fromAccountTypeController.text = widget.vendor.fromAccountType ?? '';
    _projectController.text = widget.vendor.project ?? '';
    _activityTypeController.text = widget.vendor.activityType ?? '';
    _vendorNickNameController.text = widget.vendor.vendorNickName ?? '';
    _shortNameController.text = widget.vendor.shortName ?? '';
    _vendorEmailController.text = widget.vendor.email ?? '';
    _vendorMobileController.text = widget.vendor.mobile ?? '';
    _status = widget.vendor.status ?? 'Active';

    // Tax Info
    _gstinController.text = widget.vendor.taxInfo.gstin ?? '';
    _panController.text = widget.vendor.taxInfo.pan ?? '';
    _isGstDefaulted = widget.vendor.taxInfo.isGstDefaulted;
    _section206ABController.text = widget.vendor.taxInfo.section206abVerified ?? '';
    _incomeTaxTypeController.text = widget.vendor.taxInfo.incomeTaxType ?? '';
    _materialNatureController.text = widget.vendor.taxInfo.materialNature ?? '';

    // MSME Info
    if (widget.vendor.msmeInfo != null) {
      _msmeClassificationController.text = widget.vendor.msmeInfo!.classification ?? '';
      _isMsme = widget.vendor.msmeInfo!.isMsme;
      _msmeRegNumberController.text = widget.vendor.msmeInfo!.registrationNumber ?? '';
      _msmeStartDateController.text = widget.vendor.msmeInfo!.startDate ?? '';
      _msmeEndDateController.text = widget.vendor.msmeInfo!.endDate ?? '';
    }

    // Primary Bank Account - Safe handling
    if (widget.vendor.bankAccounts.isNotEmpty) {
      // Find primary account or use first account
      BankAccount? primaryAccount;

      try {
        primaryAccount = widget.vendor.bankAccounts.firstWhere(
              (BankAccount acc) => acc.isPrimary,
          orElse: () => widget.vendor.bankAccounts.first,
        );
      } catch (e) {
        // Fallback to first account if anything goes wrong
        primaryAccount = widget.vendor.bankAccounts.first;
      }

      if (primaryAccount != null) {
        _bankAccountNameController.text = primaryAccount.accountName ?? '';
        _bankAccountNumberController.text = primaryAccount.accountNumber ?? '';
        _bankNameController.text = primaryAccount.bankName ?? '';
        _ifscCodeController.text = primaryAccount.ifscCode ?? '';
        _branchNameController.text = primaryAccount.branchName ?? '';
        _beneficiaryNameController.text = primaryAccount.beneficiaryName ?? '';
      }
    }

    // Location Info
    _countryController.text = widget.vendor.locationInfo.country ?? '';
    _stateController.text = widget.vendor.locationInfo.state ?? '';
    _cityController.text = widget.vendor.locationInfo.city ?? '';
    _addressController.text = widget.vendor.locationInfo.address ?? '';
  }

  @override
  void dispose() {
    _vendorNameController.dispose();
    _vendorCodeController.dispose();
    _vendorTypeController.dispose();
    _fromAccountTypeController.dispose();
    _projectController.dispose();
    _activityTypeController.dispose();
    _vendorNickNameController.dispose();
    _shortNameController.dispose();
    _vendorEmailController.dispose();
    _vendorMobileController.dispose();
    _gstinController.dispose();
    _panController.dispose();
    _section206ABController.dispose();
    _incomeTaxTypeController.dispose();
    _materialNatureController.dispose();
    _msmeClassificationController.dispose();
    _msmeRegNumberController.dispose();
    _msmeStartDateController.dispose();
    _msmeEndDateController.dispose();
    _bankAccountNameController.dispose();
    _bankAccountNumberController.dispose();
    _bankNameController.dispose();
    _ifscCodeController.dispose();
    _branchNameController.dispose();
    _beneficiaryNameController.dispose();
    _countryController.dispose();
    _stateController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
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

  String? _validateMobile(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mobile number is required';
    }
    if (value.length != 10) {
      return 'Enter a valid 10-digit mobile number';
    }
    return null;
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      controller.text = '${picked.day}/${picked.month}/${picked.year}';
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_status == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select Status'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vendor updated successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _handleNavigation();
        }
      });
    }
  }

  void _handleCancel() {
    _handleNavigation();
  }

  void _handleNavigation() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      context.go('/vendor');
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header with Border
            Padding(
              padding: const EdgeInsets.all(24),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.5),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.orange[600],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.edit_outlined,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Edit Vendor',
                              style: textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: colorScheme.onSurface,
                                fontSize: 22,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Update vendor information and banking details',
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurface.withValues(alpha: 0.6),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    OutlinedButton.icon(
                      onPressed: _handleCancel,
                      icon: const Icon(Icons.arrow_back, size: 18),
                      label: const Text('Back'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        side: BorderSide(
                          color: colorScheme.outline.withValues(alpha: 0.5),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Vendor Name and Code Section with Border
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.5),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vendor Details',
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _vendorNameController,
                            label: 'Vendor Name',
                            hintText: 'Enter vendor name',
                            isRequired: true,
                            validator: (value) =>
                                _validateRequired(value, 'Vendor name'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            controller: _vendorCodeController,
                            label: 'Vendor Code',
                            hintText: 'Enter vendor code',
                            isRequired: true,
                            validator: (value) =>
                                _validateRequired(value, 'Vendor code'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Status', true),
                              const SizedBox(height: 8),
                              CustomDropdown(
                                value: _status,
                                items: ['Active', 'Inactive'],
                                hint: 'Select Status',
                                onChanged: (value) =>
                                    setState(() => _status = value),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Main Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Basic Information
                        _buildSectionCard(
                          context: context,
                          icon: Icons.info_outline,
                          title: 'Basic Information',
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    controller: _vendorTypeController,
                                    label: 'Vendor Type',
                                    hintText: 'Enter vendor type',
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildTextField(
                                    controller: _fromAccountTypeController,
                                    label: 'From Account Type',
                                    hintText: 'Enter account type',
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildTextField(
                                    controller: _projectController,
                                    label: 'Project',
                                    hintText: 'Enter project',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    controller: _activityTypeController,
                                    label: 'Activity Type',
                                    hintText: 'Enter activity type',
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildTextField(
                                    controller: _vendorNickNameController,
                                    label: 'Vendor Nick Name',
                                    hintText: 'Enter nick name',
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildTextField(
                                    controller: _shortNameController,
                                    label: 'Short Name',
                                    hintText: 'Enter short name',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Contact Information
                        _buildSectionCard(
                          context: context,
                          icon: Icons.phone_outlined,
                          title: 'Contact Information',
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    controller: _vendorEmailController,
                                    label: 'Vendor Email',
                                    hintText: 'Enter vendor email',
                                    isRequired: true,
                                    validator: _validateEmail,
                                    keyboardType: TextInputType.emailAddress,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildTextField(
                                    controller: _vendorMobileController,
                                    label: 'Vendor Mobile',
                                    hintText: 'Enter mobile number',
                                    isRequired: true,
                                    validator: _validateMobile,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(10),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Tax & Compliance Information
                        _buildSectionCard(
                          context: context,
                          icon: Icons.receipt_long_outlined,
                          title: 'Tax & Compliance Information',
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    controller: _gstinController,
                                    label: 'GSTIN',
                                    hintText: 'Enter GSTIN',
                                    inputFormatters: [
                                      UpperCaseTextFormatter(),
                                      LengthLimitingTextInputFormatter(15),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildTextField(
                                    controller: _panController,
                                    label: 'PAN',
                                    hintText: 'Enter PAN',
                                    inputFormatters: [
                                      UpperCaseTextFormatter(),
                                      LengthLimitingTextInputFormatter(10),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'GST Defaulted',
                                        style:
                                        Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Checkbox(
                                        value: _isGstDefaulted,
                                        onChanged: (value) {
                                          setState(() {
                                            _isGstDefaulted =
                                                value ?? false;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    controller: _section206ABController,
                                    label: 'Section 206AB Verified',
                                    hintText: 'Enter verification status',
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildTextField(
                                    controller: _incomeTaxTypeController,
                                    label: 'Income Tax Type',
                                    hintText: 'Enter income tax type',
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildTextField(
                                    controller: _materialNatureController,
                                    label: 'Material Nature',
                                    hintText: 'Enter material nature',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // MSME Information
                        _buildSectionCard(
                          context: context,
                          icon: Icons.business_center_outlined,
                          title: 'MSME Information',
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    controller: _msmeClassificationController,
                                    label: 'MSME Classification',
                                    hintText: 'Enter classification',
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Is MSME',
                                        style:
                                        Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Checkbox(
                                        value: _isMsme,
                                        onChanged: (value) {
                                          setState(() {
                                            _isMsme = value ?? false;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildTextField(
                                    controller: _msmeRegNumberController,
                                    label: 'Registration Number',
                                    hintText: 'Enter reg number',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildDateTextField(
                                    controller: _msmeStartDateController,
                                    label: 'MSME Start Date',
                                    hintText: 'Select date',
                                    onTap: () =>
                                        _selectDate(context, _msmeStartDateController),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildDateTextField(
                                    controller: _msmeEndDateController,
                                    label: 'MSME End Date',
                                    hintText: 'Select date',
                                    onTap: () =>
                                        _selectDate(context, _msmeEndDateController),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Banking Information (Primary Account)
                        _buildSectionCard(
                          context: context,
                          icon: Icons.account_balance_outlined,
                          title: 'Banking Information (Primary Account)',
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    controller: _bankAccountNameController,
                                    label: 'Account Name',
                                    hintText: 'Enter account name',
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildTextField(
                                    controller: _bankAccountNumberController,
                                    label: 'Account Number',
                                    hintText: 'Enter account number',
                                    isRequired: true,
                                    validator: (value) =>
                                        _validateRequired(value, 'Account number'),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    controller: _bankNameController,
                                    label: 'Bank Name',
                                    hintText: 'Enter bank name',
                                    isRequired: true,
                                    validator: (value) =>
                                        _validateRequired(value, 'Bank name'),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildTextField(
                                    controller: _ifscCodeController,
                                    label: 'IFSC Code',
                                    hintText: 'Enter IFSC code',
                                    isRequired: true,
                                    validator: (value) =>
                                        _validateRequired(value, 'IFSC code'),
                                    inputFormatters: [
                                      UpperCaseTextFormatter(),
                                      LengthLimitingTextInputFormatter(11),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    controller: _branchNameController,
                                    label: 'Branch Name',
                                    hintText: 'Enter branch name',
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildTextField(
                                    controller: _beneficiaryNameController,
                                    label: 'Beneficiary Name',
                                    hintText: 'Enter beneficiary name',
                                    isRequired: true,
                                    validator: (value) =>
                                        _validateRequired(value, 'Beneficiary name'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Location Information
                        _buildSectionCard(
                          context: context,
                          icon: Icons.location_on_outlined,
                          title: 'Location Information',
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    controller: _countryController,
                                    label: 'Country',
                                    hintText: 'Enter country',
                                    isRequired: true,
                                    validator: (value) =>
                                        _validateRequired(value, 'Country'),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildTextField(
                                    controller: _stateController,
                                    label: 'State',
                                    hintText: 'Enter state',
                                    isRequired: true,
                                    validator: (value) =>
                                        _validateRequired(value, 'State'),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildTextField(
                                    controller: _cityController,
                                    label: 'City',
                                    hintText: 'Enter city',
                                    isRequired: true,
                                    validator: (value) =>
                                        _validateRequired(value, 'City'),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _addressController,
                              label: 'Address',
                              hintText: 'Enter complete address',
                              isRequired: true,
                              validator: (value) =>
                                  _validateRequired(value, 'Address'),
                              maxLines: 3,
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Action Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton(
                              onPressed: _handleCancel,
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                                side: BorderSide(
                                  color: colorScheme.outline
                                      .withValues(alpha: 0.5),
                                ),
                                foregroundColor: colorScheme.onSurface,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                'Cancel',
                                style: textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: _submitForm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange[600],
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
                              child: Text(
                                'Update Vendor',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String label, bool isRequired) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return RichText(
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
    );
  }

  Widget _buildSectionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.5),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: colorScheme.primary),
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
          const SizedBox(height: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    TextEditingController? controller,
    required String label,
    String? hintText,
    bool isRequired = false,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
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
          validator: validator,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.4),
            ),
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

  Widget _buildDateTextField({
    TextEditingController? controller,
    required String label,
    String? hintText,
    required VoidCallback onTap,
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
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  controller?.text.isNotEmpty ?? false
                      ? controller!.text
                      : hintText ?? 'Select date',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  size: 18,
                  color: colorScheme.primary,
                ),
              ],
            ),
          ),
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
