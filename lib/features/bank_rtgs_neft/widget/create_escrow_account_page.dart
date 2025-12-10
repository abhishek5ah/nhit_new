import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:ppv_components/common_widgets/button/primary_button.dart';
import 'package:ppv_components/common_widgets/button/secondary_button.dart';
import 'package:ppv_components/features/bank_rtgs_neft/controllers/escrow_account_controller.dart';
import 'package:ppv_components/features/bank_rtgs_neft/models/escrow_account_response.dart';
import 'package:ppv_components/features/bank_rtgs_neft/services/api_client.dart';

class CreateEscrowAccountPage extends StatefulWidget {
  final String? accountId; // For update mode
  
  const CreateEscrowAccountPage({super.key, this.accountId});

  @override
  State<CreateEscrowAccountPage> createState() => _CreateEscrowAccountPageState();
}

class _MaxLengthWarningFormatter extends TextInputFormatter {
  _MaxLengthWarningFormatter({
    required this.maxLength,
    required this.onLimitExceeded,
  });

  final int maxLength;
  final ValueChanged<bool> onLimitExceeded;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.length > maxLength) {
      onLimitExceeded(true);
      return oldValue;
    }

    onLimitExceeded(false);
    return newValue;
  }
}

class EnterKeyIntent extends Intent {
  const EnterKeyIntent();
}

class _CreateEscrowAccountPageState extends State<CreateEscrowAccountPage> {
  final _formKey = GlobalKey<FormState>();
  final _accountNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _branchNameController = TextEditingController();
  final _ifscCodeController = TextEditingController();
  final _initialBalanceController = TextEditingController();
  final _descriptionController = TextEditingController();

  final _accountNameFocus = FocusNode();
  final _accountNumberFocus = FocusNode();
  final _bankNameFocus = FocusNode();
  final _branchNameFocus = FocusNode();
  final _ifscCodeFocus = FocusNode();
  final _initialBalanceFocus = FocusNode();
  final _descriptionFocus = FocusNode();
  late final List<FocusNode> _focusOrder;

  String? selectedAccountType;
  List<String> signatories = [''];
  List<TextEditingController> signatoryControllers = [TextEditingController()];

  final List<String> accountTypes = [
    'Savings Account',
    'Current Account',
  ];

  double _initialBalance = 0.00;
  bool _isLoading = false;
  bool _isUpdateMode = false;
  EscrowAccountData? _existingAccount;
  bool _accountNumberMaxLengthWarning = false;

  final EscrowAccountController _controller = EscrowAccountController();
  static final RegExp _digitsOnlyRegex = RegExp(r'^[0-9]+$');
  static final RegExp _accountNumberRegex = RegExp(r'^[0-9]{9,18}$');

  @override
  void initState() {
    super.initState();
    _initialBalanceController.text = _initialBalance.toStringAsFixed(2);
    _focusOrder = [
      _accountNameFocus,
      _accountNumberFocus,
      _bankNameFocus,
      _branchNameFocus,
      _ifscCodeFocus,
      _initialBalanceFocus,
      _descriptionFocus,
    ];
    
    // Initialize API client
    ApiClient().initialize();
    
    // Check if in update mode
    if (widget.accountId != null) {
      _isUpdateMode = true;
      _loadExistingAccount();
    }
  }

  Future<void> _loadExistingAccount() async {
    if (widget.accountId == null) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final account = await _controller.getEscrowAccount(widget.accountId!);
      if (account != null && mounted) {
        _existingAccount = account;
        _populateFormWithExistingData(account);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading account: ${_controller.getErrorMessage(e)}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _populateFormWithExistingData(EscrowAccountData account) {
    _accountNameController.text = account.accountName;
    _accountNumberController.text = account.accountNumber;
    _bankNameController.text = account.bankName;
    _branchNameController.text = account.branchName;
    _ifscCodeController.text = account.ifscCode;
    _descriptionController.text = account.description;
    
    // Set account type
    selectedAccountType = _mapAccountTypeFromApi(account.accountType);
    
    // Set balance (keep as read-only in update mode)
    _initialBalance = account.balance;
    _initialBalanceController.text = _initialBalance.toStringAsFixed(2);
    
    // Set signatories
    signatories.clear();
    signatoryControllers.forEach((controller) => controller.dispose());
    signatoryControllers.clear();
    
    for (int i = 0; i < account.authorizedSignatories.length; i++) {
      signatories.add(account.authorizedSignatories[i]);
      final controller = TextEditingController(text: account.authorizedSignatories[i]);
      signatoryControllers.add(controller);
    }
    
    // Ensure at least one signatory field
    if (signatories.isEmpty) {
      signatories.add('');
      signatoryControllers.add(TextEditingController());
    }
    
    setState(() {});
  }

  String _mapAccountTypeFromApi(String apiType) {
    switch (apiType.toUpperCase()) {
      case 'SAVINGS':
        return 'Savings Account';
      case 'CURRENT':
        return 'Current Account';
      default:
        return 'Savings Account'; // Default to Savings Account as per backend enum
    }
  }

  String _mapAccountTypeToApi(String uiType) {
    switch (uiType) {
      case 'Savings Account':
        return 'SAVINGS';
      case 'Current Account':
        return 'CURRENT';
      default:
        return 'SAVINGS'; // Default to SAVINGS as per backend enum
    }
  }

  @override
  void dispose() {
    _accountNameController.dispose();
    _accountNumberController.dispose();
    _bankNameController.dispose();
    _branchNameController.dispose();
    _ifscCodeController.dispose();
    _initialBalanceController.dispose();
    _descriptionController.dispose();
    for (final controller in signatoryControllers) {
      controller.dispose();
    }
    for (final focusNode in _focusOrder) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _addSignatory() {
    setState(() {
      signatories.add('');
      signatoryControllers.add(TextEditingController());
    });
  }

  void _removeSignatory(int index) {
    if (signatories.length > 1) {
      setState(() {
        signatories.removeAt(index);
        signatoryControllers[index].dispose();
        signatoryControllers.removeAt(index);
      });
    }
  }

  Future<void> _createAccount() async {
    final scope = FocusScope.of(context);
    scope.unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Collect signatory names from controllers
      final signatoryNames = signatoryControllers
          .map((controller) => controller.text.trim())
          .where((name) => name.isNotEmpty)
          .toList();

      bool success;
      String successMessage;
      
      if (_isUpdateMode && widget.accountId != null) {
        // Update existing account
        success = await _controller.updateEscrowAccount(
          accountId: widget.accountId!,
          accountName: _accountNameController.text.trim(),
          accountNumber: _accountNumberController.text.trim(),
          bankName: _bankNameController.text.trim(),
          branchName: _branchNameController.text.trim(),
          ifscCode: _ifscCodeController.text.trim(),
          accountType: _mapAccountTypeToApi(selectedAccountType ?? 'Savings Account'),
          description: _descriptionController.text.trim(),
          authorizedSignatories: signatoryNames,
          status: _existingAccount?.status ?? 'active',
        );
        successMessage = 'Escrow account updated successfully';
      } else {
        // Create new account
        success = await _controller.createEscrowAccount(
          accountName: _accountNameController.text.trim(),
          accountNumber: _accountNumberController.text.trim(),
          bankName: _bankNameController.text.trim(),
          branchName: _branchNameController.text.trim(),
          ifscCode: _ifscCodeController.text.trim(),
          accountType: _mapAccountTypeToApi(selectedAccountType ?? 'Savings Account'),
          balance: _initialBalance,
          description: _descriptionController.text.trim(),
          authorizedSignatories: signatoryNames,
        );
        successMessage = 'Escrow account created successfully';
      }

      if (success) {
        // Show success snackbar
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(successMessage),
              backgroundColor: Theme.of(context).colorScheme.primary,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
            ),
          );
        }

        if (!_isUpdateMode) {
          // Reset form to blank only for create mode
          _resetForm();
        }

        // Navigate back to list
        if (mounted) {
          GoRouter.of(context).go('/escrow-accounts');
        }
      } else {
        // Show error snackbar
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isUpdateMode 
                  ? 'Failed to update escrow account. Please try again.' 
                  : 'Failed to create escrow account. Please try again.'),
              backgroundColor: Theme.of(context).colorScheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      // Show error snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${_controller.getErrorMessage(e)}'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _resetForm() {
    _accountNameController.clear();
    _accountNumberController.clear();
    _bankNameController.clear();
    _branchNameController.clear();
    _ifscCodeController.clear();
    _descriptionController.clear();
    for (final controller in signatoryControllers) {
      controller.dispose();
    }
    signatoryControllers.clear();
    signatoryControllers.add(TextEditingController());

    setState(() {
      selectedAccountType = null;
      signatories = [''];
      _initialBalance = 0.00;
      _initialBalanceController.text = _initialBalance.toStringAsFixed(2);
    });
    _formKey.currentState?.reset();
  }

  void _handleEnterNavigation() {
    final currentNode = _focusOrder.firstWhere(
      (node) => node.hasFocus,
      orElse: () => _accountNameFocus,
    );

    final currentIndex = _focusOrder.indexOf(currentNode);
    final isLastField = currentIndex == _focusOrder.length - 1;

    if (isLastField) {
      _createAccount();
      return;
    }

    final nextNode = _focusOrder[currentIndex + 1];
    FocusScope.of(context).requestFocus(nextNode);
  }

  String? _validateAccountNumber(String? value) {
    final trimmed = value?.trim() ?? '';

    if (trimmed.isEmpty) {
      return 'Account Number is required.';
    }
    if (!_digitsOnlyRegex.hasMatch(trimmed)) {
      return 'Only numeric digits are allowed in Account Number.';
    }
    if (trimmed.length < 9) {
      return 'Account Number must contain at least 9 digits.';
    }
    if (trimmed.length > 18) {
      return 'Maximum 18 digits are allowed for the Account Number.';
    }
    if (!_accountNumberRegex.hasMatch(trimmed)) {
      return 'Invalid Account Number format.';
    }

    return null;
  }

  void _handleAccountNumberMaxLengthWarning(bool exceeded) {
    if (_accountNumberMaxLengthWarning != exceeded) {
      setState(() {
        _accountNumberMaxLengthWarning = exceeded;
      });
    }
  }

  void _onBalanceTextChanged(String text) {
    final parsed = double.tryParse(text.replaceAll(',', ''));
    if (parsed != null) {
      setState(() {
        _initialBalance = parsed;
      });
    } else if (text.isEmpty) {
      setState(() {
        _initialBalance = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Shortcuts(
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.enter): const EnterKeyIntent(),
        LogicalKeySet(LogicalKeyboardKey.numpadEnter): const EnterKeyIntent(),
      },
      child: Actions(
        actions: {
          EnterKeyIntent: CallbackAction<EnterKeyIntent>(
            onInvoke: (_) {
              _handleEnterNavigation();
              return null;
            },
          ),
        },
        child: Scaffold(
          backgroundColor: colorScheme.surface,
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 16),
                  _buildFormSection(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withAlpha(128),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colorScheme.primary.withAlpha(38),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.add_circle_outline,
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
                  _isUpdateMode ? 'Update Escrow Account' : 'Create Escrow Account',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isUpdateMode 
                      ? 'Update the details of your escrow account'
                      : 'Add a new escrow account to your inventory',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withAlpha(153),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          SecondaryButton(
            label: 'Back to Accounts',
            icon: Icons.arrow_back,
            onPressed: () => GoRouter.of(context).go('/escrow-accounts'),
          ),
        ],
      ),
    );
  }

  Widget _buildFormSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.outline.withAlpha(128),
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
                      'Account Details',
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
                      child: _buildTextField(
                        controller: _accountNameController,
                        label: 'Account Name',
                        hint: 'Enter account name',
                        isRequired: true,
                        focusNode: _accountNameFocus,
                        textInputAction: TextInputAction.next,
                        onEditingComplete: _handleEnterNavigation,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter account name';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTextField(
                            controller: _accountNumberController,
                            label: 'Account Number',
                            hint: 'Enter account number',
                            isRequired: true,
                            maxLength: 18,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              _MaxLengthWarningFormatter(
                                maxLength: 18,
                                onLimitExceeded: _handleAccountNumberMaxLengthWarning,
                              ),
                            ],
                            focusNode: _accountNumberFocus,
                            textInputAction: TextInputAction.next,
                            onEditingComplete: _handleEnterNavigation,
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            validator: _validateAccountNumber,
                          ),
                          if (_accountNumberMaxLengthWarning)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                'Account Number cannot exceed 18 digits. Maximum 18 digits are allowed.',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.error,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
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
                        controller: _bankNameController,
                        label: 'Bank Name',
                        hint: 'Enter bank name',
                        isRequired: true,
                        focusNode: _bankNameFocus,
                        textInputAction: TextInputAction.next,
                        onEditingComplete: _handleEnterNavigation,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter bank name';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _branchNameController,
                        label: 'Branch Name',
                        hint: 'Enter branch name',
                        isRequired: true,
                        focusNode: _branchNameFocus,
                        textInputAction: TextInputAction.next,
                        onEditingComplete: _handleEnterNavigation,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter branch name';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _ifscCodeController,
                        label: 'IFSC Code',
                        hint: 'ENTER IFSC CODE',
                        isRequired: true,
                        textCapitalization: TextCapitalization.characters,
                        maxLength: 11,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
                          LengthLimitingTextInputFormatter(11),
                        ],
                        focusNode: _ifscCodeFocus,
                        textInputAction: TextInputAction.next,
                        onEditingComplete: _handleEnterNavigation,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter IFSC code';
                          }
                          if (value.length != 11) {
                            return 'IFSC code must be 11 characters';
                          }
                          final ifscRegex = RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$');
                          if (!ifscRegex.hasMatch(value)) {
                            return 'Invalid IFSC code format';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDropdown(
                        label: 'Account Type',
                        hint: 'Select account type',
                        value: selectedAccountType,
                        items: accountTypes,
                        isRequired: true,
                        onChanged: (value) {
                          setState(() {
                            selectedAccountType = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildInitialBalanceField(),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _descriptionController,
                        label: 'Description',
                        hint: 'Enter description (optional)',
                        maxLines: 1,
                        focusNode: _descriptionFocus,
                        textInputAction: TextInputAction.done,
                        onEditingComplete: _handleEnterNavigation,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.outline.withAlpha(128),
                width: 0.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.people,
                      color: colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Authorized Signatories',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ...List.generate(signatories.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: signatoryControllers[index],
                            decoration: InputDecoration(
                              hintText: 'Enter signatory name',
                              hintStyle: TextStyle(
                                color: colorScheme.onSurface.withAlpha(128),
                              ),
                              filled: true,
                              fillColor: colorScheme.surface,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: colorScheme.outline.withAlpha(128)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: colorScheme.outline.withAlpha(128)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                            validator: (value) {
                              if (index == 0 && (value == null || value.trim().isEmpty)) {
                                return 'At least one signatory is required';
                              }
                              return null;
                            },
                          ),
                        ),
                        if (signatories.length > 1) ...[
                          const SizedBox(width: 12),
                          IconButton(
                            onPressed: () => _removeSignatory(index),
                            icon: const Icon(Icons.delete_outline),
                            color: Colors.red,
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.red.withAlpha(25),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }),
                SecondaryButton(
                  onPressed: _addSignatory,
                  icon: Icons.add,
                  label: 'Add Signatory',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SecondaryButton(
                onPressed: () => Navigator.pop(context),
                label: 'Cancel',
              ),
              const SizedBox(width: 12),
              PrimaryButton(
                onPressed: _isLoading ? null : _createAccount,
                icon: _isLoading ? null : Icons.check,
                label: _isLoading 
                    ? (_isUpdateMode ? 'Updating...' : 'Creating...') 
                    : (_isUpdateMode ? 'Update Account' : 'Create Account'),
                isLoading: _isLoading,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInitialBalanceField() {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Initial Balance',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _initialBalanceController,
          enabled: !_isUpdateMode, // Disable in update mode
          readOnly: _isUpdateMode, // Make read-only in update mode
          focusNode: _initialBalanceFocus,
          textInputAction: TextInputAction.next,
          onEditingComplete: _handleEnterNavigation,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
          ],
          decoration: InputDecoration(
            hintText: "0.00",
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            filled: true,
            fillColor: _isUpdateMode 
                ? colorScheme.onSurface.withAlpha(25) // Grayed out in update mode
                : colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: colorScheme.outline.withAlpha(128)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: colorScheme.outline.withAlpha(128)),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: colorScheme.outline.withAlpha(64)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
          ),
          validator: (value) {
            if (!_isUpdateMode && (value == null || value.isEmpty)) {
              return 'Please enter initial balance';
            }
            if (!_isUpdateMode) {
              final parsed = double.tryParse(value!);
              if (parsed == null) return 'Invalid amount';
            }
            return null;
          },
          onChanged: _isUpdateMode ? null : _onBalanceTextChanged,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool isRequired = false,
    int maxLines = 1,
    int? maxLength,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    FocusNode? focusNode,
    TextInputAction? textInputAction,
    AutovalidateMode? autovalidateMode,
    VoidCallback? onEditingComplete,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          maxLength: maxLength,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          inputFormatters: inputFormatters,
          validator: validator,
          focusNode: focusNode,
          textInputAction: textInputAction,
          autovalidateMode: autovalidateMode,
          onEditingComplete: onEditingComplete,
          decoration: InputDecoration(
            hintText: hint,
            counterText: maxLength != null ? '' : null,
            hintStyle: TextStyle(
              color: colorScheme.onSurface.withAlpha(128),
            ),
            filled: true,
            fillColor: colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: colorScheme.outline.withAlpha(128)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: colorScheme.outline.withAlpha(128)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String hint,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
    bool isRequired = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          hint: Text(
            hint,
            style: TextStyle(
              color: colorScheme.onSurface.withAlpha(128),
            ),
          ),
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
          validator: isRequired
              ? (value) {
            if (value == null || value.isEmpty) {
              return 'Please select $label';
            }
            return null;
          }
              : null,
          decoration: InputDecoration(
            filled: true,
            fillColor: colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: colorScheme.outline.withAlpha(128)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: colorScheme.outline.withAlpha(128)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }
}
