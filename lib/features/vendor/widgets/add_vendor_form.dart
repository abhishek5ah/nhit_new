import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ppv_components/common_widgets/button/primary_button.dart';
import 'package:ppv_components/common_widgets/button/secondary_button.dart';
import 'package:ppv_components/common_widgets/dropdown.dart';
import 'package:ppv_components/features/vendor/models/vendor_model.dart';
import 'package:ppv_components/features/vendor/data/models/vendor_api_models.dart';
import 'package:ppv_components/features/vendor/services/vendor_api_service.dart';
import 'package:ppv_components/features/vendor/providers/create_vendor_form_provider.dart';

class CreateVendorScreen extends StatefulWidget {
  const CreateVendorScreen({super.key});

  @override
  State<CreateVendorScreen> createState() => _CreateVendorScreenState();
}

class _CreateVendorScreenState extends State<CreateVendorScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _vendorNameController;
  late TextEditingController _vendorCodeController;
  late TextEditingController _vendorEmailController;
  late TextEditingController _vendorMobileController;
  late TextEditingController _countryNameController;
  late TextEditingController _stateNameController;
  late TextEditingController _pinCodeController;
  late TextEditingController _panController;
  late TextEditingController _gstinController;
  late TextEditingController _section206ABController;
  late TextEditingController _remarksAddressController;
  late TextEditingController _accountNameController;
  late TextEditingController _shortNameController;
  late TextEditingController _parentController;
  late TextEditingController _cityNameController;
  late TextEditingController _msmeRegNumberController;
  late TextEditingController _materialNatureController;
  late TextEditingController _gstDefaultedController;
  late TextEditingController _commonBankDetailsController;
  late TextEditingController _incomeTaxTypeController;
  late final Map<String, TextEditingController> _textControllers;
  bool _isInitializing = true;

  // Bank Accounts
  List<BankAccount> bankAccounts = [];
  List<Map<String, TextEditingController>> bankControllers = [];

  // Dropdown values
  String? _fromAccountType;
  String? _project;
  String _status = 'Active';
  String? _msmeClassification;
  String? _activityType;
  List<String> _projectOptions = [];
  bool _isProjectLoading = false;
  String? _projectError;

  // Date values
  DateTime? _msmeStartDate;
  DateTime? _msmeEndDate;

  // Vendor code generation
  bool _isCodeGenerating = false;
  String? _codeError;
  String? _lastCodePrefix;

  // File
  File? _attachedFile;
  String? _attachedFileName;

  @override
  void initState() {
    super.initState();
    _vendorNameController = TextEditingController();
    _vendorCodeController = TextEditingController();
    _vendorEmailController = TextEditingController();
    _vendorMobileController = TextEditingController();
    _countryNameController = TextEditingController();
    _stateNameController = TextEditingController();
    _pinCodeController = TextEditingController();
    _panController = TextEditingController();
    _gstinController = TextEditingController();
    _section206ABController = TextEditingController();
    _remarksAddressController = TextEditingController();
    _accountNameController = TextEditingController();
    _shortNameController = TextEditingController();
    _parentController = TextEditingController();
    _cityNameController = TextEditingController();
    _msmeRegNumberController = TextEditingController();
    _materialNatureController = TextEditingController();
    _gstDefaultedController = TextEditingController();
    _commonBankDetailsController = TextEditingController();
    _incomeTaxTypeController = TextEditingController();

    _textControllers = {
      'vendorName': _vendorNameController,
      'vendorCode': _vendorCodeController,
      'vendorEmail': _vendorEmailController,
      'vendorMobile': _vendorMobileController,
      'countryName': _countryNameController,
      'stateName': _stateNameController,
      'pinCode': _pinCodeController,
      'pan': _panController,
      'gstin': _gstinController,
      'section206AB': _section206ABController,
      'remarksAddress': _remarksAddressController,
      'accountName': _accountNameController,
      'shortName': _shortNameController,
      'parent': _parentController,
      'cityName': _cityNameController,
      'msmeRegNumber': _msmeRegNumberController,
      'materialNature': _materialNatureController,
      'gstDefaulted': _gstDefaultedController,
      'commonBankDetails': _commonBankDetailsController,
      'incomeTaxType': _incomeTaxTypeController,
    };
    _registerTextFieldListeners();

    // Initialize first bank account
    _addBankAccount();
    _vendorNameController.addListener(_onVendorNameChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _restorePersistedForm();
    });
  }

  void _addBankAccount({Map<String, dynamic>? initialData}) {
    final newControllers = {
      'accountNumber': TextEditingController(text: initialData?['accountNumber'] ?? ''),
      'ifscCode': TextEditingController(text: initialData?['ifscCode'] ?? ''),
      'bankName': TextEditingController(text: initialData?['bankName'] ?? ''),
      'branchName': TextEditingController(text: initialData?['branchName'] ?? ''),
      'beneficiaryName': TextEditingController(text: initialData?['beneficiaryName'] ?? ''),
      'accountName': TextEditingController(text: initialData?['accountName'] ?? ''),
    };

    newControllers.values.forEach(
      (controller) => controller.addListener(_onBankAccountsChanged),
    );

    final isPrimary = initialData?['isPrimary'] ?? bankAccounts.isEmpty;

    setState(() {
      bankControllers.add(newControllers);
      bankAccounts.add(
        BankAccount(
          accountNumber: initialData?['accountNumber'] ?? '',
          ifscCode: initialData?['ifscCode'] ?? '',
          bankName: initialData?['bankName'] ?? '',
          branchName: initialData?['branchName'],
          beneficiaryName: initialData?['beneficiaryName'] ?? '',
          accountName: initialData?['accountName'],
          isPrimary: isPrimary,
        ),
      );

      if (!bankAccounts.any((acc) => acc.isPrimary)) {
        bankAccounts.first.isPrimary = true;
      }
    });

    _persistBankAccounts();
  }

  void _removeBankAccount(int index) {
    if (bankAccounts.length > 1) {
      // Dispose controllers
      for (var controller in bankControllers[index].values) {
        controller.removeListener(_onBankAccountsChanged);
        controller.dispose();
      }

      setState(() {
        bankAccounts.removeAt(index);
        bankControllers.removeAt(index);

        // If removed account was primary, set first as primary
        if (bankAccounts.isNotEmpty) {
          bool hasPrimary = bankAccounts.any((acc) => acc.isPrimary);
          if (!hasPrimary) {
            bankAccounts[0].isPrimary = true;
          }
        }
      });

      _persistBankAccounts();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('At least one bank account is required'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _setPrimaryAccount(int index) {
    setState(() {
      for (int i = 0; i < bankAccounts.length; i++) {
        bankAccounts[i].isPrimary = i == index;
      }
    });
    _persistBankAccounts();
  }

  @override
  void dispose() {
    _vendorNameController.dispose();
    _vendorCodeController.dispose();
    _vendorEmailController.dispose();
    _vendorMobileController.dispose();
    _countryNameController.dispose();
    _stateNameController.dispose();
    _pinCodeController.dispose();
    _panController.dispose();
    _gstinController.dispose();
    _section206ABController.dispose();
    _remarksAddressController.dispose();
    _accountNameController.dispose();
    _shortNameController.dispose();
    _parentController.dispose();
    _cityNameController.dispose();
    _msmeRegNumberController.dispose();
    _materialNatureController.dispose();
    _gstDefaultedController.dispose();
    _commonBankDetailsController.dispose();
    _incomeTaxTypeController.dispose();
    _vendorNameController.removeListener(_onVendorNameChanged);

    for (var controllerMap in bankControllers) {
      for (var controller in controllerMap.values) {
        controller.dispose();
      }
    }

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

  void _registerTextFieldListeners() {
    _textControllers.forEach((key, controller) {
      controller.addListener(() {
        if (_isInitializing) return;
        context.read<CreateVendorFormProvider>().updateField(key, controller.text);
      });
    });
  }

  Future<void> _restorePersistedForm() async {
    final formProvider = context.read<CreateVendorFormProvider>();
    await formProvider.loadFormState();

    final savedBankAccounts = formProvider.bankAccounts;

    setState(() {
      _isInitializing = true;
      _textControllers.forEach((key, controller) {
        controller.text = formProvider.getTextField(key);
      });
      _status = formProvider.status;
      _fromAccountType = formProvider.fromAccountType;
      _project = formProvider.project;
      _msmeClassification = formProvider.msmeClassification;
      _activityType = formProvider.activityType;
      _msmeStartDate = formProvider.getDate('msmeStartDate');
      _msmeEndDate = formProvider.getDate('msmeEndDate');
    });

    _restoreBankAccounts(savedBankAccounts);

    await _loadProjects();

    final savedCode = formProvider.vendorCode;
    if (savedCode != null && savedCode.isNotEmpty) {
      _vendorCodeController.text = savedCode;
    } else if (_vendorCodeController.text.isEmpty) {
      await _generateVendorCode();
    }

    setState(() {
      _isInitializing = false;
    });
  }

  void _restoreBankAccounts(List<Map<String, dynamic>> savedAccounts) {
    for (final controllerMap in bankControllers) {
      for (final controller in controllerMap.values) {
        controller.removeListener(_onBankAccountsChanged);
        controller.dispose();
      }
    }
    bankControllers.clear();
    bankAccounts.clear();

    if (savedAccounts.isEmpty) {
      _addBankAccount();
      return;
    }

    for (final account in savedAccounts) {
      _addBankAccount(initialData: account);
    }
  }

  void _persistBankAccounts() {
    if (_isInitializing) return;
    final provider = context.read<CreateVendorFormProvider>();
    final accounts = <Map<String, dynamic>>[];

    for (int i = 0; i < bankControllers.length; i++) {
      final controllers = bankControllers[i];
      accounts.add({
        'accountNumber': controllers['accountNumber']!.text,
        'ifscCode': controllers['ifscCode']!.text,
        'bankName': controllers['bankName']!.text,
        'branchName': controllers['branchName']!.text,
        'beneficiaryName': controllers['beneficiaryName']!.text,
        'accountName': controllers['accountName']!.text,
        'isPrimary': bankAccounts[i].isPrimary,
      });
    }

    provider.updateBankAccounts(accounts);
  }

  void _onBankAccountsChanged() {
    _persistBankAccounts();
  }

  void _updateStatus(String value) {
    setState(() {
      _status = value;
    });
    if (_isInitializing) return;
    context.read<CreateVendorFormProvider>().updateStatus(value);
  }

  void _updateDropdown(String key, String? value, void Function(String?) setter) {
    setState(() {
      setter(value);
    });
    if (_isInitializing) return;
    context.read<CreateVendorFormProvider>().updateDropdown(key, value);
  }

  void _updateDateField(bool isStartDate, DateTime? value) {
    if (isStartDate) {
      setState(() {
        _msmeStartDate = value;
      });
    } else {
      setState(() {
        _msmeEndDate = value;
      });
    }
    if (_isInitializing) return;
    context
        .read<CreateVendorFormProvider>()
        .updateDate(isStartDate ? 'msmeStartDate' : 'msmeEndDate', value);
  }

  void _resetForm() {
    _isInitializing = true;
    for (final controller in _textControllers.values) {
      controller.clear();
    }
    _vendorNameController.clear();
    _vendorCodeController.clear();
    _vendorEmailController.clear();
    _vendorMobileController.clear();
    _attachedFile = null;
    _attachedFileName = null;
    _projectError = null;
    setState(() {
      _fromAccountType = null;
      _project = null;
      _status = 'Active';
      _msmeClassification = null;
      _activityType = null;
      _msmeStartDate = null;
      _msmeEndDate = null;
    });
    _restoreBankAccounts([]);
    _isInitializing = false;
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        allowMultiple: false,
      );

      if (result != null) {
        setState(() {
          _attachedFile = File(result.files.single.path!);
          _attachedFileName = result.files.single.name;
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

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _msmeStartDate = picked;
        } else {
          _msmeEndDate = picked;
        }
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Validate dropdowns
      if (_fromAccountType == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select From Account Type'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_project == null || _project!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select Project'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Validate bank accounts
      for (int i = 0; i < bankAccounts.length; i++) {
        final controllers = bankControllers[i];
        if (controllers['accountNumber']!.text.isEmpty ||
            controllers['ifscCode']!.text.isEmpty ||
            controllers['bankName']!.text.isEmpty ||
            controllers['beneficiaryName']!.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Please fill all required fields in Bank Account ${i + 1}',
              ),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      try {
        // Create VendorApiModel from form data
        final vendorModel = VendorApiModel(
          vendorCode: _vendorCodeController.text,
          name: _vendorNameController.text,
          contactPerson: _vendorNameController.text, // Using vendor name as contact person
          email: _vendorEmailController.text,
          phone: _vendorMobileController.text,
          address: VendorAddress(
            street: _remarksAddressController.text,
            city: _cityNameController.text,
            state: _stateNameController.text,
            postalCode: _pinCodeController.text,
            country: _countryNameController.text,
          ),
          gstNumber: _gstinController.text,
          panNumber: _panController.text,
          msmeRegistered: _msmeRegNumberController.text.isNotEmpty,
          msmeNumber: _msmeRegNumberController.text.isNotEmpty 
              ? _msmeRegNumberController.text 
              : null,
          vendorType: 'SUPPLIER', // Default vendor type
          paymentTerms: _project ?? '', // Using project as payment terms
          creditLimit: 0.0,
          status: _status == 'Active' ? 'ACTIVE' : 'INACTIVE',
          accounts: bankControllers.map((controllers) {
            return VendorBankAccount(
              accountHolderName: controllers['beneficiaryName']!.text,
              bankName: controllers['bankName']!.text,
              branchName: controllers['branchName']!.text,
              accountNumber: controllers['accountNumber']!.text,
              ifscCode: controllers['ifscCode']!.text,
              accountType: 'CURRENT', // Default account type
              isPrimary: bankAccounts[bankControllers.indexOf(controllers)].isPrimary,
              isActive: true,
            );
          }).toList(),
        );

        // Call the API service
        final vendorService = context.read<VendorApiService>();
        final result = await vendorService.createVendor(vendorModel);

        // Close loading dialog
        if (mounted) {
          Navigator.of(context).pop();
        }

        if (result.success) {
          // Clear form state
          await context.read<CreateVendorFormProvider>().clearFormState();
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result.message ?? 'Vendor created successfully!'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );

            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                _handleNavigation();
              }
            });
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result.message ?? 'Failed to create vendor'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
      } catch (e) {
        // Close loading dialog
        if (mounted) {
          Navigator.of(context).pop();
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error creating vendor: $e'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  void _handleCancel() {
    _handleNavigation();
  }

  void _handleNavigation() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      context.go('/vendors');
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
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.store_outlined,
                      color: colorScheme.onPrimary.withValues(alpha: 0.9),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Create Vendor',
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Add a new vendor to the system',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Basic Information Section
                  _buildSectionCard(
                    icon: Icons.info_outline,
                    title: 'Account Information',
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('From Account Type', true),
                                const SizedBox(height: 8),
                                CustomDropdown(
                                  value: _fromAccountType,
                                  items: ['Internal', 'External'],
                                  hint: 'Select From Account Type',
                                  onChanged: (value) =>
                                      setState(() => _fromAccountType = value),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildProjectSelector(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Status', true),
                          const SizedBox(height: 8),
                          CustomDropdown(
                            value: _status,
                            items: ['Active', 'Inactive'],
                            hint: 'Select Status',
                            onChanged: (value) =>
                                setState(() => _status = value!),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Vendor Information
                  _buildSectionCard(
                    icon: Icons.business_outlined,
                    title: 'Vendor Information',
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _vendorNameController,
                              label: 'Vendor Name',
                              hintText: 'Vendor name',
                              isRequired: true,
                              validator: (value) =>
                                  _validateRequired(value, 'Vendor name'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildVendorCodeField(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _vendorEmailController,
                              label: 'Vendor Email',
                              hintText: 'Vendor email',
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
                              hintText: 'Mobile number',
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

                  // Address Information
                  _buildSectionCard(
                    icon: Icons.location_on_outlined,
                    title: 'Address Information',
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _countryNameController,
                              label: 'Country Name',
                              hintText: 'Country name',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: _stateNameController,
                              label: 'State Name',
                              hintText: 'State name',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _cityNameController,
                              label: 'City Name',
                              hintText: 'City name',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: _pinCodeController,
                              label: 'PIN Code',
                              hintText: 'PIN code',
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(6),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Bank Details Section with Multiple Accounts
                  _buildBankDetailsSection(),

                  const SizedBox(height: 24),

                  // Tax Information
                  _buildSectionCard(
                    icon: Icons.receipt_long_outlined,
                    title: 'Tax Information',
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _panController,
                              label: 'PAN',
                              hintText: 'PAN',
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(10),
                                UpperCaseTextFormatter(),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: _gstinController,
                              label: 'GSTIN',
                              hintText: 'GSTIN',
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(15),
                                UpperCaseTextFormatter(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // MSME Information
                  _buildSectionCard(
                    icon: Icons.business_center_outlined,
                    title: 'MSME Information',
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('MSME Classification', false),
                                const SizedBox(height: 8),
                                CustomDropdown(
                                  value: _msmeClassification,
                                  items: ['Micro', 'Small', 'Medium'],
                                  hint: 'Select Classification',
                                  onChanged: (value) => setState(
                                    () => _msmeClassification = value,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Activity Type', false),
                                const SizedBox(height: 8),
                                CustomDropdown(
                                  value: _activityType,
                                  items: ['N/A'],
                                  hint: 'Select Activity Type',
                                  onChanged: (value) =>
                                      setState(() => _activityType = value),
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
                            child: _buildDateField(
                              label: 'MSME Start Date',
                              selectedDate: _msmeStartDate,
                              onTap: () => _selectDate(context, true),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDateField(
                              label: 'MSME End Date',
                              selectedDate: _msmeEndDate,
                              onTap: () => _selectDate(context, false),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _msmeRegNumberController,
                              label: 'MSME Registration Number',
                              hintText: 'MSME registration number',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller:
                                  _msmeRegNumberController, // Note: Use different controller if needed
                              label: 'MSME',
                              hintText: 'MSME',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Additional Information
                  _buildSectionCard(
                    icon: Icons.more_horiz_outlined,
                    title: 'Additional Information',
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _section206ABController,
                              label: 'Section 206AB Verified',
                              hintText: 'Enter section 206AB status',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: _remarksAddressController,
                              label: 'Remarks Address',
                              hintText: 'Enter remarks address',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _shortNameController,
                              label: 'Short Name',
                              hintText: 'Enter short name',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: _parentController,
                              label: 'Parent',
                              hintText: 'Enter parent',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _materialNatureController,
                              label: 'Material Nature',
                              hintText: 'Enter material nature',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: _gstDefaultedController,
                              label: 'GST Defaulted',
                              hintText: 'Enter GST defaulted status',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _commonBankDetailsController,
                              label: 'Common Bank Details',
                              hintText: 'Enter common bank details',
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
                        ],
                      ),
                    ],
                  ),


                  const SizedBox(height: 24),
                  _buildSectionCard(
                    icon: Icons.more_horiz_outlined,
                    title: 'Documents',
                    children: [
                      const SizedBox(height: 16),
                      _buildFileUpload(),
                    ],
                  ),


                  const SizedBox(height: 32),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Secondary Button (Cancel)
                      SecondaryButton(
                        label: 'Cancel',
                        onPressed: _handleCancel,
                        isDisabled: false,
                      ),
                      const SizedBox(width: 12),

                      // Primary Button (Create Vendor)
                      PrimaryButton(
                        label: 'Create Vendor',
                        onPressed: _submitForm,
                        backgroundColor: colorScheme.primary,
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

  Widget _buildProjectSelector() {
    if (_isProjectLoading) {
      return SizedBox(
        height: 56,
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      );
    }

    if (_projectError != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _projectError!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => _loadProjects(forceRefresh: true),
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Retry'),
          ),
        ],
      );
    }

    if (_projectOptions.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'No projects available. Please create a project first.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => _loadProjects(forceRefresh: true),
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Reload'),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: CustomDropdown(
            value: _project,
            items: _projectOptions,
            hint: 'Select Project',
            onChanged: (value) => setState(() => _project = value),
          ),
        ),
        IconButton(
          tooltip: 'Refresh projects',
          icon: const Icon(Icons.refresh),
          onPressed: () => _loadProjects(forceRefresh: true),
        ),
      ],
    );
  }

  Widget _buildVendorCodeField() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Vendor Code', true),
        const SizedBox(height: 8),
        TextFormField(
          controller: _vendorCodeController,
          readOnly: true,
          validator: (value) => _validateRequired(value, 'Vendor code'),
          decoration: InputDecoration(
            hintText: 'Vendor Code (Auto-generated)',
            suffixIcon: _isCodeGenerating
                ? Padding(
                    padding: const EdgeInsets.all(12),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorScheme.primary,
                      ),
                    ),
                  )
                : IconButton(
                    tooltip: 'Regenerate vendor code',
                    icon: const Icon(Icons.refresh),
                    onPressed: () => _generateVendorCode(),
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
          ),
        ),
        if (_codeError != null) ...[
          const SizedBox(height: 6),
          Text(
            _codeError!,
            style: TextStyle(color: colorScheme.error, fontSize: 12),
          ),
        ],
      ],
    );
  }

  void _initializeForm() {
    _loadProjects();
    _generateVendorCode();
  }

  Future<void> _loadProjects({bool forceRefresh = false}) async {
    setState(() {
      _isProjectLoading = true;
      _projectError = null;
    });

    final service = context.read<VendorApiService>();
    final result =
        await service.loadProjectDropdowns(forceRefresh: forceRefresh);

    if (!mounted) return;

    setState(() {
      _isProjectLoading = false;
      if (result.success) {
        _projectOptions = result.projects;
        if (_projectOptions.isNotEmpty &&
            (_project == null || !_projectOptions.contains(_project))) {
          _project = _projectOptions.first;
        }
      } else {
        _projectError = result.message ?? 'Failed to load projects';
      }
    });
  }

  Future<void> _generateVendorCode({String? prefix}) async {
    final vendorName = _vendorNameController.text.trim();
    if (vendorName.isEmpty) {
      setState(() {
        _codeError = 'Enter vendor name before generating code';
      });
      return;
    }

    final derivedPrefix = prefix ?? _derivePrefixFromName() ?? 'V';
    setState(() {
      _isCodeGenerating = true;
      _codeError = null;
      _lastCodePrefix = derivedPrefix;
    });

    final service = context.read<VendorApiService>();
    final result = await service.generateVendorCode(
      prefix: derivedPrefix,
      vendorName: vendorName,
    );

    if (!mounted) return;

    setState(() {
      _isCodeGenerating = false;
      if (result.success && result.code != null) {
        _vendorCodeController.text = result.code!;
      } else {
        _codeError = result.message ?? 'Failed to generate vendor code';
      }
    });
  }

  void _onVendorNameChanged() {
    final prefix = _derivePrefixFromName();
    if (prefix == null || prefix == _lastCodePrefix) return;
    _generateVendorCode(prefix: prefix);
  }

  String? _derivePrefixFromName() {
    final value = _vendorNameController.text.trim();
    if (value.isEmpty) return null;
    return value.substring(0, 1).toUpperCase();
  }

  Widget _buildBankDetailsSection() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Info Banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFE3F2FD),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF90CAF9), width: 1),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: const Color(0xFF1976D2),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'You can add multiple bank accounts for this vendor. The first account will be marked as primary by default. IFSC codes will auto-populate bank details.',
                  style: textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF1565C0),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Bank Accounts List
        ...List.generate(bankAccounts.length, (index) {
          final account = bankAccounts[index];
          final controllers = bankControllers[index];
          final isPrimary = account.isPrimary;

          return Column(
            children: [
              _buildBankAccountCard(
                index: index,
                isPrimary: isPrimary,
                controllers: controllers,
                onSetPrimary: () => _setPrimaryAccount(index),
                onRemove: () => _removeBankAccount(index),
                canRemove: bankAccounts.length > 1,
              ),
              if (index < bankAccounts.length - 1) const SizedBox(height: 16),
            ],
          );
        }),
        const SizedBox(height: 16),
        // Add Another Bank Account Button
        Center(
          child: OutlinedButton.icon(
            onPressed: _addBankAccount,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add Another Bank Account'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
              side: BorderSide(color: Theme.of(context).colorScheme.primary),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBankAccountCard({
    required int index,
    required bool isPrimary,
    required Map<String, TextEditingController> controllers,
    required VoidCallback onSetPrimary,
    required VoidCallback onRemove,
    required bool canRemove,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    isPrimary
                        ? 'Primary Bank Account'
                        : 'Additional Bank Account #${index}',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              if (isPrimary)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1976D2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Primary',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              else
                OutlinedButton(
                  onPressed: onRemove,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                  ),
                  child: const Text('Remove'),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: controllers['accountNumber']!,
                  label: 'Account Number',
                  hintText: 'Enter account number',
                  isRequired: true,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: controllers['ifscCode']!,
                  label: 'IFSC Code',
                  hintText: 'IFSC code',
                  isRequired: true,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(11),
                    UpperCaseTextFormatter(),
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
                  controller: controllers['bankName']!,
                  label: 'Bank Name',
                  hintText: 'Bank name',
                  isRequired: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: controllers['branchName']!,
                  label: 'Branch Name',
                  hintText: 'Branch name',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: controllers['beneficiaryName']!,
                  label: 'Beneficiary Name',
                  hintText: 'Beneficiary name',
                  isRequired: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: controllers['accountName']!,
                  label: 'Account Name (Optional)',
                  hintText: 'Account Name(Optional)',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (!isPrimary)
            Row(
              children: [
                Checkbox(value: isPrimary, onChanged: (_) => onSetPrimary()),
                const SizedBox(width: 8),
                Text(
                  'Set as Primary Account',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF2196F3).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF2196F3), width: 1),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Color(0xFF2196F3),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Primary Account - This will be the default account for payments',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF1565C0),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
        ],
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
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(24),
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

  Widget _buildDateField({
    required String label,
    required DateTime? selectedDate,
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
                  selectedDate != null
                      ? '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'
                      : ' dd-mm-yyyy',
                  style: textTheme.bodyMedium?.copyWith(
                    color: selectedDate != null
                        ? colorScheme.onSurface
                        : colorScheme.onSurface.withValues(alpha: 0.4),
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

  Widget _buildFileUpload() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upload Documents',
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
                onPressed: _pickFile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  foregroundColor: colorScheme.onSurface,
                  elevation: 0,
                ),
                child: const Text('Choose File'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _attachedFileName ?? 'No file chosen',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (_attachedFile != null)
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () {
                    setState(() {
                      _attachedFile = null;
                      _attachedFileName = null;
                    });
                  },
                  tooltip: 'Remove file',
                ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Supported formats: PDF, JPG, JPEG, PNG',
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.6),
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
