import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ppv_components/common_widgets/button/primary_button.dart';
import 'package:ppv_components/common_widgets/button/outlined_button.dart';
import 'package:ppv_components/common_widgets/button/secondary_button.dart';
import 'package:ppv_components/common_widgets/custom_dropdown.dart';
import '../models/transfer_models/transfer_enums.dart';
import '../models/transfer_models/transfer_request.dart';
import '../services/account_transfer_service.dart';
import '../services/escrow_account_service.dart';
import '../models/escrow_account_response.dart';
import '../../vendor/models/vendor_model.dart';
import '../../vendor/data/vendor_mockdb.dart';

class CreateTransferPage extends StatefulWidget {
  const CreateTransferPage({super.key});

  @override
  State<CreateTransferPage> createState() => _CreateTransferPageState();
}

class _CreateTransferPageState extends State<CreateTransferPage> {
  final _formKey = GlobalKey<FormState>();
  final AccountTransferService _transferService = AccountTransferService();
  final EscrowAccountService _escrowService = EscrowAccountService();
  bool _isSubmitting = false;

  TransferType selectedTransferType = TransferType.internal;
  TransferMode selectedTransferMode = TransferMode.oneToOne;

  TransferMode _getModeFromString(String mode) {
    switch (mode) {
      case 'ONE_TO_ONE':
        return TransferMode.oneToOne;
      case 'ONE_TO_MANY':
        return TransferMode.oneToMany;
      case 'MANY_TO_ONE':
        return TransferMode.manyToOne;
      case 'MANY_TO_MANY':
        return TransferMode.manyToMany;
      default:
        return TransferMode.oneToOne;
    }
  }
  String? hoveredTransferType;
  String? hoveredTransferMode;

  // Form controllers
  final _transferAmountController = TextEditingController();
  final _purposeController = TextEditingController();
  final _remarksController = TextEditingController();

  // Dropdown values for account/vendor fields
  String? selectedSourceAccount;
  String? selectedDestinationAccount;
  String? selectedVendor;
  
  // Data for dropdowns
  List<EscrowAccountData> availableAccounts = [];
  List<Vendor> availableVendors = [];
  bool _isLoadingAccounts = false;
  bool _isLoadingVendors = false;

  // Helper getters for dropdown items
  List<DropdownItem> get accountDropdownItems {
    return availableAccounts
        .map((account) => DropdownItem(
              label: account.accountName,
              value: account.accountId,
            ))
        .toList();
  }

  List<DropdownItem> get vendorDropdownItems {
    return availableVendors
        .map((vendor) => DropdownItem(
              label: vendor.name,
              value: vendor.code,
            ))
        .toList();
  }

  // Lists for multiple accounts/vendors
  final List<TransferSourceInput> sources = [];
  final List<TransferDestinationInput> destinations = [];
  List<Map<String, dynamic>> sourceAccounts = [];
  List<Map<String, dynamic>> destinationAccounts = [];

  // Dynamic lists for External Transfer vendors
  List<Map<String, dynamic>> vendorRows = [];

  @override
  void initState() {
    super.initState();
    _loadAccounts();
    _loadVendors();
  }

  Future<void> _loadAccounts() async {
    setState(() {
      _isLoadingAccounts = true;
    });
    
    try {
      final accounts = await _escrowService.listEscrowAccounts(pageSize: 100);
      setState(() {
        availableAccounts = accounts;
        _isLoadingAccounts = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingAccounts = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load accounts: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadVendors() async {
    setState(() {
      _isLoadingVendors = true;
    });
    
    try {
      // For now, use mock data. Replace with API call when vendor service is available
      await Future.delayed(Duration(milliseconds: 500)); // Simulate API call
      setState(() {
        availableVendors = vendorData.where((v) => v.status == 'Approved').toList();
        _isLoadingVendors = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingVendors = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load vendors: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _addRawSourceEntry() {
    setState(() {
      sourceAccounts.add({
        'account': null,
        'amount': TextEditingController(text: '0.00'),
      });
    });
  }

  void _removeSourceAccount(int index) {
    setState(() {
      sourceAccounts[index]['amount'].dispose();
      sourceAccounts.removeAt(index);
    });
  }

  void _addRawDestinationEntry({bool isVendor = false}) {
    if (isVendor) {
      setState(() {
        vendorRows.add({
          'vendor': null,
          'amount': TextEditingController(text: '0.00'),
        });
      });
    } else {
      setState(() {
        destinationAccounts.add({
          'account': null,
          'amount': TextEditingController(text: '0.00'),
        });
      });
    }
  }

  void _removeDestinationAccount(int index) {
    setState(() {
      destinationAccounts[index]['amount'].dispose();
      destinationAccounts.removeAt(index);
    });
  }

  void _addVendorRow() => _addRawDestinationEntry(isVendor: true);

  void _removeVendorRow(int index) {
    setState(() {
      vendorRows[index]['amount'].dispose();
      vendorRows.removeAt(index);
    });
  }

  void _addSourceAccountRow() => _addRawSourceEntry();

  void _addDestinationAccountRow() => _addRawDestinationEntry();

  @override
  void dispose() {
    // Dispose single controllers
    _transferAmountController.dispose();
    _purposeController.dispose();
    _remarksController.dispose();
    
    // Dispose dynamic list controllers
    for (final row in sourceAccounts) {
      row['amount'].dispose();
    }
    for (final row in destinationAccounts) {
      row['amount'].dispose();
    }
    for (final row in vendorRows) {
      row['amount'].dispose();
    }
    
    super.dispose();
  }

  void _incrementAmount(TextEditingController controller, {double step = 0.01}) {
    final currentValue = double.tryParse(controller.text) ?? 0.0;
    final newValue = currentValue + step;
    controller.text = newValue.toStringAsFixed(2);
    setState(() {});
  }

  void _decrementAmount(TextEditingController controller, {double step = 0.01}) {
    final currentValue = double.tryParse(controller.text) ?? 0.0;
    final newValue = (currentValue - step).clamp(0.0, double.infinity);
    controller.text = newValue.toStringAsFixed(2);
    setState(() {});
  }

  
  final List<Map<String, dynamic>> transferTypes = [
    {
      'type': 'Internal Transfer',
      'icon': Icons.swap_horiz,
      'color': Colors.cyan,
      'description': 'Transfer between your escrow accounts',
    },
    {
      'type': 'External Transfer',
      'icon': Icons.send,
      'color': Colors.green,
      'description': 'Transfer to vendor accounts',
    },
  ];

  final List<Map<String, dynamic>> transferModes = [
    {
      'mode': 'One to One',
      'icon': Icons.arrow_forward,
      'color': Colors.blue,
      'description': 'Single account to single account',
    },
    {
      'mode': 'One to Many',
      'icon': Icons.account_tree,
      'color': Colors.orange,
      'description': 'Single account to multiple accounts',
    },
    {
      'mode': 'Many to Many',
      'icon': Icons.hub,
      'color': Colors.purple,
      'description': 'Multiple accounts to multiple accounts',
    },
  ];

  void _onTransferTypeChanged(String? value) {
    if (value == null) return;

    final type = value == 'INTERNAL' ? TransferType.internal : TransferType.external;

    setState(() {
      selectedTransferType = type;
      // Clear destinations when type changes
      destinations.clear();
      selectedDestinationAccount = null;
      selectedVendor = null;
    });
  }


  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate() || _isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      double? _parseAmount(String? text) {
        if (text == null) return null;
        final value = double.tryParse(text);
        if (value == null || value <= 0) return null;
        return value;
      }

      final currentSources = <TransferSourceInput>[];
      final currentDestinations = <TransferDestinationInput>[];

      if (selectedTransferType == TransferType.internal) {
        if (selectedTransferMode == TransferMode.oneToOne) {
          final amount = _parseAmount(_transferAmountController.text);
          if (selectedSourceAccount != null &&
              selectedDestinationAccount != null &&
              amount != null) {
            currentSources.add(TransferSourceInput(
              sourceAccountId: selectedSourceAccount!,
              amount: amount,
            ));
            currentDestinations.add(TransferDestinationInput(
              destinationAccountId: selectedDestinationAccount,
              amount: amount,
            ));
          }
        } else if (selectedTransferMode == TransferMode.oneToMany) {
          if (selectedSourceAccount != null && destinationAccounts.isNotEmpty) {
            double total = 0;
            for (final row in destinationAccounts) {
              final accountId = row['account'] as String?;
              final controller = row['amount'] as TextEditingController?;
              final amount = _parseAmount(controller?.text);
              if (accountId != null && amount != null) {
                total += amount;
                currentDestinations.add(TransferDestinationInput(
                  destinationAccountId: accountId,
                  amount: amount,
                ));
              }
            }
            if (total > 0) {
              currentSources.add(TransferSourceInput(
                sourceAccountId: selectedSourceAccount!,
                amount: total,
              ));
            }
          }
        } else if (selectedTransferMode == TransferMode.manyToMany) {
          for (final row in sourceAccounts) {
            final accountId = row['account'] as String?;
            final controller = row['amount'] as TextEditingController?;
            final amount = _parseAmount(controller?.text);
            if (accountId != null && amount != null) {
              currentSources.add(TransferSourceInput(
                sourceAccountId: accountId,
                amount: amount,
              ));
            }
          }
          for (final row in destinationAccounts) {
            final accountId = row['account'] as String?;
            final controller = row['amount'] as TextEditingController?;
            final amount = _parseAmount(controller?.text);
            if (accountId != null && amount != null) {
              currentDestinations.add(TransferDestinationInput(
                destinationAccountId: accountId,
                amount: amount,
              ));
            }
          }
        }
      } else if (selectedTransferType == TransferType.external) {
        if (selectedTransferMode == TransferMode.oneToOne) {
          final amount = _parseAmount(_transferAmountController.text);
          if (selectedSourceAccount != null && selectedVendor != null && amount != null) {
            currentSources.add(TransferSourceInput(
              sourceAccountId: selectedSourceAccount!,
              amount: amount,
            ));
            currentDestinations.add(TransferDestinationInput(
              destinationVendorId: selectedVendor,
              amount: amount,
            ));
          }
        } else if (selectedTransferMode == TransferMode.oneToMany) {
          if (selectedSourceAccount != null && vendorRows.isNotEmpty) {
            double total = 0;
            for (final row in vendorRows) {
              final vendorId = row['vendor'] as String?;
              final controller = row['amount'] as TextEditingController?;
              final amount = _parseAmount(controller?.text);
              if (vendorId != null && amount != null) {
                total += amount;
                currentDestinations.add(TransferDestinationInput(
                  destinationVendorId: vendorId,
                  amount: amount,
                ));
              }
            }
            if (total > 0) {
              currentSources.add(TransferSourceInput(
                sourceAccountId: selectedSourceAccount!,
                amount: total,
              ));
            }
          }
        } else if (selectedTransferMode == TransferMode.manyToMany) {
          for (final row in sourceAccounts) {
            final accountId = row['account'] as String?;
            final controller = row['amount'] as TextEditingController?;
            final amount = _parseAmount(controller?.text);
            if (accountId != null && amount != null) {
              currentSources.add(TransferSourceInput(
                sourceAccountId: accountId,
                amount: amount,
              ));
            }
          }
          for (final row in vendorRows) {
            final vendorId = row['vendor'] as String?;
            final controller = row['amount'] as TextEditingController?;
            final amount = _parseAmount(controller?.text);
            if (vendorId != null && amount != null) {
              currentDestinations.add(TransferDestinationInput(
                destinationVendorId: vendorId,
                amount: amount,
              ));
            }
          }
        }
      }

      if (currentSources.isEmpty || currentDestinations.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please add at least one source and one destination with valid amounts.'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isSubmitting = false;
        });
        return;
      }

      final request = CreateAccountTransferRequest(
        transferType: selectedTransferType,
        transferMode: selectedTransferMode,
        purpose: _purposeController.text,
        remarks: _remarksController.text,
        requestedById: '123e4567-e89b-12d3-a456-426614174000',
        sources: currentSources,
        destinations: currentDestinations,
      );

      final transfer = await _transferService.createTransfer(request);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Transfer created successfully: ${transfer.transferReference}'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to escrow accounts page with refresh flag
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/escrow-accounts',
        (route) => route.settings.name == '/',
        arguments: {'refresh': true},
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  _buildHeader(context, constraints),
                  const SizedBox(height: 24),

                  // Form Section
                  _buildFormSection(context, constraints),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, BoxConstraints constraints) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final isSmallScreen = constraints.maxWidth < 900;

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.swap_horiz,
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
                      'Create Transfer',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Transfer funds between accounts or to vendors',
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
                  onPressed: () => context.go('/escrow/account-transfers'),
                  icon: Icons.arrow_back,
                  label: 'Back to Transfers',
                ),
              ],
            ],
          ),
          if (isSmallScreen) ...[
            const SizedBox(height: 16),
            OutlineButton(
              onPressed: () => context.go('/escrow/account-transfers'),
              icon: Icons.arrow_back,
              label: 'Back to Transfers',
            ),
          ],
        ],
      ),
    );
  }

  // Stepper field widget for decimal amounts (matching payment screen style)
  Widget _buildAmountStepperField({
    required TextEditingController controller,
    String? label,
    Color? accentColor,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveAccentColor = accentColor ?? colorScheme.primary;

    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label ?? 'Amount (₹)',
        filled: true,
        fillColor: colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        suffixIcon: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 24,
              width: 24,
              child: IconButton(
                padding: EdgeInsets.zero,
                iconSize: 20,
                icon: Icon(
                  Icons.arrow_drop_up,
                  color: effectiveAccentColor,
                ),
                onPressed: () => _incrementAmount(controller, step: 0.01),
                tooltip: 'Increase',
              ),
            ),
            SizedBox(
              height: 24,
              width: 24,
              child: IconButton(
                padding: EdgeInsets.zero,
                iconSize: 20,
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: effectiveAccentColor,
                ),
                onPressed: () => _decrementAmount(controller, step: 0.01),
                tooltip: 'Decrease',
              ),
            ),
          ],
        ),
      ),
      onChanged: (value) {
        setState(() {
          // Add your logic here
        });
      },
    );
  }

  Widget _buildFormSection(BuildContext context, BoxConstraints constraints) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final isSmallScreen = constraints.maxWidth < 900;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline,
          width: 0.5,
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Title
            Row(
              children: [
                Icon(
                  Icons.add_circle_outline,
                  color: colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Transfer Details',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Transfer Type Label
            Row(
              children: [
                Text(
                  'Transfer Type',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '*',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Transfer Type Cards - Responsive layout
            LayoutBuilder(
              builder: (context, constraints) {
                final cardWidth = 340.0;
                final spacing = 16.0;
                final availableWidth = constraints.maxWidth;
                final cardsPerRow = (availableWidth / (cardWidth + spacing)).floor();

                if (cardsPerRow >= 2) {
                  return Wrap(
                    spacing: spacing,
                    runSpacing: 16,
                    children: transferTypes.map((type) {
                      return SizedBox(
                        width: cardWidth,
                        child: _buildTransferTypeCard(
                          context,
                          type: type['type'],
                          icon: type['icon'],
                          color: type['color'],
                          description: type['description'],
                        ),
                      );
                    }).toList(),
                  );
                } else {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: transferTypes.map((type) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildTransferTypeCard(
                          context,
                          type: type['type'],
                          icon: type['icon'],
                          color: type['color'],
                          description: type['description'],
                        ),
                      );
                    }).toList(),
                  );
                }
              },
            ),

            // Transfer Mode Section
            if (selectedTransferType != null) ...[
              const SizedBox(height: 24),
              Row(
                children: [
                  Text(
                    'Transfer Mode',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '*',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Transfer Mode Cards
              LayoutBuilder(
                builder: (context, constraints) {
                  final cardWidth = 340.0;
                  final spacing = 16.0;
                  final availableWidth = constraints.maxWidth;
                  final cardsPerRow = (availableWidth / (cardWidth + spacing)).floor();

                  if (cardsPerRow >= 3) {
                    return Wrap(
                      spacing: spacing,
                      runSpacing: 16,
                      children: transferModes.map((mode) {
                        return SizedBox(
                          width: cardWidth,
                          child: _buildTransferModeCard(
                            context,
                            mode: mode['mode'],
                            icon: mode['icon'],
                            color: mode['color'],
                            description: mode['description'],
                          ),
                        );
                      }).toList(),
                    );
                  } else if (cardsPerRow == 2) {
                    return Wrap(
                      spacing: spacing,
                      runSpacing: 16,
                      children: transferModes.map((mode) {
                        return SizedBox(
                          width: cardWidth,
                          child: _buildTransferModeCard(
                            context,
                            mode: mode['mode'],
                            icon: mode['icon'],
                            color: mode['color'],
                            description: mode['description'],
                          ),
                        );
                      }).toList(),
                    );
                  } else {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: transferModes.map((mode) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildTransferModeCard(
                            context,
                            mode: mode['mode'],
                            icon: mode['icon'],
                            color: mode['color'],
                            description: mode['description'],
                          ),
                        );
                      }).toList(),
                    );
                  }
                },
              ),
            ],

            // Dynamic Form Fields
            if (selectedTransferMode != null) ...[
              const SizedBox(height: 24),
              _buildDynamicFormFields(context, isSmallScreen),
            ],

            const SizedBox(height: 32),

            // Action Buttons
            isSmallScreen
                ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SecondaryButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icons.cancel_outlined,
                  label: 'Cancel',
                ),
                const SizedBox(height: 12),
                PrimaryButton(
                  onPressed: _handleSubmit,
                  icon: Icons.check_circle_outline,
                  label: 'Create Transfer',
                ),
              ],
            )
                : Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SecondaryButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icons.cancel_outlined,
                  label: 'Cancel',
                ),
                const SizedBox(width: 12),
                PrimaryButton(
                  onPressed: _handleSubmit,
                  icon: Icons.check_circle_outline,
                  label: 'Create Transfer',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicFormFields(BuildContext context, bool isSmallScreen) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // One to One Mode - Internal Transfer
        if (selectedTransferMode == TransferMode.oneToOne && selectedTransferType == TransferType.internal) ...[
          _buildDropdownField(
            label: 'Source Account',
            value: selectedSourceAccount,
            itemsWithLabels: accountDropdownItems,
            isRequired: true,
            isLoading: _isLoadingAccounts,
            onChanged: (value) {
              setState(() {
                selectedSourceAccount = value;
              });
            },
          ),
          const SizedBox(height: 16),
          _buildDropdownField(
            label: 'Destination Account',
            value: selectedDestinationAccount,
            itemsWithLabels: accountDropdownItems,
            isRequired: true,
            isLoading: _isLoadingAccounts,
            onChanged: (value) {
              setState(() {
                selectedDestinationAccount = value;
              });
            },
          ),
        ],

        // One to Many Mode - Internal Transfer
        if (selectedTransferMode == TransferMode.oneToMany && selectedTransferType == TransferType.internal) ...[
          _buildDropdownField(
            label: 'Source Account',
            value: selectedSourceAccount,
            itemsWithLabels: accountDropdownItems,
            isRequired: true,
            isLoading: _isLoadingAccounts,
            onChanged: (value) {
              setState(() {
                selectedSourceAccount = value;
              });
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                'Destination Accounts',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              Text('*', style: TextStyle(color: Colors.red, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          if (destinationAccounts.isNotEmpty)
            ...List.generate(destinationAccounts.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (index == 0)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                'Destination Account',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          CustomDropdown(
                            value: destinationAccounts[index]['account'],
                            itemsWithLabels: accountDropdownItems,
                            hint: 'Select account',
                            onChanged: (value) {
                              setState(() {
                                destinationAccounts[index]['account'] = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (index == 0)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                'Amount',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          _buildAmountStepperField(
                            controller: destinationAccounts[index]['amount'],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      children: [
                        if (index == 0) const SizedBox(height: 32),
                        IconButton(
                          onPressed: () => _removeDestinationAccount(index),
                          icon: const Icon(Icons.delete_outline),
                          color: Colors.red,
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.red.withValues(alpha: 0.1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          const SizedBox(height: 8),
          OutlineButton(
            onPressed: _addDestinationAccountRow,
            icon: Icons.add,
            label: 'Add Destination Account',
          ),
        ],

        // Many to Many Mode - Internal Transfer
        if (selectedTransferMode == TransferMode.manyToMany && selectedTransferType == TransferType.internal) ...[
          Row(
            children: [
              Text(
                'Source Accounts',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              Text('*', style: TextStyle(color: Colors.red, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          if (sourceAccounts.isNotEmpty)
            ...List.generate(sourceAccounts.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (index == 0)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                'Source Account',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          CustomDropdown(
                            value: sourceAccounts[index]['account'],
                            itemsWithLabels: accountDropdownItems,
                            hint: 'Select account',
                            onChanged: (value) {
                              setState(() {
                                sourceAccounts[index]['account'] = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (index == 0)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                'Amount',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          _buildAmountStepperField(
                            controller: sourceAccounts[index]['amount'],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      children: [
                        if (index == 0) const SizedBox(height: 32),
                        IconButton(
                          onPressed: () => _removeSourceAccount(index),
                          icon: const Icon(Icons.delete_outline),
                          color: Colors.red,
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.red.withOpacity(0.1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          const SizedBox(height: 8),
          OutlineButton(
            onPressed: _addSourceAccountRow,
            icon: Icons.add,
            label: 'Add Source Account',
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                'Destination Accounts',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              Text('*', style: TextStyle(color: Colors.red, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          if (destinationAccounts.isNotEmpty)
            ...List.generate(destinationAccounts.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (index == 0)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                'Destination Account',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          CustomDropdown(
                            value: destinationAccounts[index]['account'],
                            itemsWithLabels: accountDropdownItems,
                            hint: 'Select account',
                            onChanged: (value) {
                              setState(() {
                                destinationAccounts[index]['account'] = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (index == 0)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                'Amount',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          _buildAmountStepperField(
                            controller: destinationAccounts[index]['amount'],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      children: [
                        if (index == 0) const SizedBox(height: 32),
                        IconButton(
                          onPressed: () => _removeDestinationAccount(index),
                          icon: const Icon(Icons.delete_outline),
                          color: Colors.red,
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.red.withOpacity(0.1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          const SizedBox(height: 8),
          OutlineButton(
            onPressed: _addDestinationAccountRow,
            icon: Icons.add,
            label: 'Add Destination Account',
          ),
        ],

        // One to One Mode - External Transfer
        if (selectedTransferMode == TransferMode.oneToOne && selectedTransferType == TransferType.external) ...[
          _buildDropdownField(
            label: 'Source Account',
            value: selectedSourceAccount,
            itemsWithLabels: accountDropdownItems,
            isRequired: true,
            isLoading: _isLoadingAccounts,
            onChanged: (value) {
              setState(() {
                selectedSourceAccount = value;
              });
            },
          ),
          const SizedBox(height: 16),
          _buildDropdownField(
            label: 'Vendor',
            value: selectedVendor,
            itemsWithLabels: vendorDropdownItems,
            isRequired: true,
            isLoading: _isLoadingVendors,
            onChanged: (value) {
              setState(() {
                selectedVendor = value;
              });
            },
          ),
        ],

        // One to Many Mode - External Transfer
        if (selectedTransferMode == TransferMode.oneToMany && selectedTransferType == TransferType.external) ...[
          _buildDropdownField(
            label: 'Source Account',
            value: selectedSourceAccount,
            itemsWithLabels: accountDropdownItems,
            isRequired: true,
            isLoading: _isLoadingAccounts,
            onChanged: (value) {
              setState(() {
                selectedSourceAccount = value;
              });
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                'Vendors',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              Text('*', style: TextStyle(color: Colors.red, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          if (vendorRows.isNotEmpty)
            ...List.generate(vendorRows.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (index == 0)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                'Vendor',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          CustomDropdown(
                            value: vendorRows[index]['vendor'],
                            itemsWithLabels: vendorDropdownItems,
                            hint: 'Select vendor',
                            onChanged: (value) {
                              setState(() {
                                vendorRows[index]['vendor'] = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (index == 0)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                'Amount',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          _buildAmountStepperField(
                            controller: vendorRows[index]['amount'],
                            accentColor: Colors.green,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      children: [
                        if (index == 0) const SizedBox(height: 32),
                        IconButton(
                          onPressed: () => _removeVendorRow(index),
                          icon: const Icon(Icons.delete_outline),
                          color: Colors.red,
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.red.withOpacity(0.1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          const SizedBox(height: 8),
          OutlineButton(
            onPressed: _addVendorRow,
            icon: Icons.add,
            label: 'Add Vendor',
          ),
        ],

        // Many to Many Mode - External Transfer
        if (selectedTransferMode == TransferMode.manyToMany && selectedTransferType == TransferType.external) ...[
          Row(
            children: [
              Text(
                'Source Accounts',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              Text('*', style: TextStyle(color: Colors.red, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          if (sourceAccounts.isNotEmpty)
            ...List.generate(sourceAccounts.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (index == 0)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                'Source Account',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          CustomDropdown(
                            value: sourceAccounts[index]['account'],
                            itemsWithLabels: accountDropdownItems,
                            hint: 'Select account',
                            onChanged: (value) {
                              setState(() {
                                sourceAccounts[index]['account'] = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (index == 0)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                'Amount',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          _buildAmountStepperField(
                            controller: sourceAccounts[index]['amount'],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      children: [
                        if (index == 0) const SizedBox(height: 32),
                        IconButton(
                          onPressed: () => _removeSourceAccount(index),
                          icon: const Icon(Icons.delete_outline),
                          color: Colors.red,
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.red.withOpacity(0.1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          const SizedBox(height: 8),
          OutlineButton(
            onPressed: _addSourceAccountRow,
            icon: Icons.add,
            label: 'Add Source Account',
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                'Vendors',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              Text('*', style: TextStyle(color: Colors.red, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          if (vendorRows.isNotEmpty)
            ...List.generate(vendorRows.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (index == 0)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                'Vendor',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          CustomDropdown(
                            value: vendorRows[index]['vendor'],
                            itemsWithLabels: vendorDropdownItems,
                            hint: 'Select vendor',
                            onChanged: (value) {
                              setState(() {
                                vendorRows[index]['vendor'] = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (index == 0)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                'Amount',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          _buildAmountStepperField(
                            controller: vendorRows[index]['amount'],
                            accentColor: Colors.green,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      children: [
                        if (index == 0) const SizedBox(height: 32),
                        IconButton(
                          onPressed: () => _removeVendorRow(index),
                          icon: const Icon(Icons.delete_outline),
                          color: Colors.red,
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.red.withOpacity(0.1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          const SizedBox(height: 8),
          OutlineButton(
            onPressed: _addVendorRow,
            icon: Icons.add,
            label: 'Add Vendor',
          ),
        ],

        // Common fields for all modes
        const SizedBox(height: 16),
        _buildAmountStepperField(
          controller: _transferAmountController,
          label: 'Transfer Amount (₹)',
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final displayAsColumn = constraints.maxWidth < 700;
            if (displayAsColumn) {
              return Column(
                children: [
                  _buildTextField(
                    label: 'Purpose',
                    hint: 'Enter transfer purpose',
                    controller: _purposeController,
                    isRequired: true,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Remarks',
                    hint: 'Enter additional remarks (optional)',
                    controller: _remarksController,
                    maxLines: 3,
                  ),
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildTextField(
                    label: 'Purpose',
                    hint: 'Enter transfer purpose',
                    controller: _purposeController,
                    isRequired: true,
                    maxLines: 3,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    label: 'Remarks',
                    hint: 'Enter additional remarks (optional)',
                    controller: _remarksController,
                    maxLines: 3,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    List<DropdownItem>? itemsWithLabels,
    required ValueChanged<String?> onChanged,
    bool isRequired = false,
    bool isLoading = false,
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
            if (isLoading) ...[
              const SizedBox(width: 8),
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        CustomDropdown(
          value: value,
          itemsWithLabels: itemsWithLabels,
          hint: 'Select $label',
          enabled: !isLoading,
          onChanged: isLoading ? null : onChanged,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    bool isRequired = false,
    int maxLines = 1,
    String? prefixText,
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
          maxLines: maxLines,
          keyboardType: prefixText != null ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            hintText: hint,
            prefixText: prefixText,
            hintStyle: TextStyle(
              color: colorScheme.onSurface.withOpacity(0.5),
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

  
  Widget _buildTransferTypeCard(
      BuildContext context, {
        required String type,
        required IconData icon,
        required Color color,
        required String description,
      }) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final transferType = type == 'Internal Transfer' ? TransferType.internal : TransferType.external;
    final isSelected = selectedTransferType == transferType;
    final isHovered = hoveredTransferType == type;

    return MouseRegion(
      onEnter: (_) {
        setState(() {
          hoveredTransferType = type;
        });
      },
      onExit: (_) {
        setState(() {
          hoveredTransferType = null;
        });
      },
      child: InkWell(
        onTap: () {
          setState(() {
            selectedTransferType = transferType;
            selectedTransferMode = TransferMode.oneToOne;
            // Clear all dynamic lists
            sourceAccounts.clear();
            destinationAccounts.clear();
            vendorRows.clear();
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 208,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected || isHovered ? colorScheme.primary : colorScheme.outline,
              width: isSelected || isHovered ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                type,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransferModeCard(
      BuildContext context, {
        required String mode,
        required IconData icon,
        required Color color,
        required String description,
      }) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final modeValue = mode.replaceAll(' to ', '_TO_').toUpperCase();
    final transferMode = _getModeFromString(modeValue);
    final isSelected = selectedTransferMode == transferMode;
    final isHovered = hoveredTransferMode == mode;

    return MouseRegion(
      onEnter: (_) {
        setState(() {
          hoveredTransferMode = mode;
        });
      },
      onExit: (_) {
        setState(() {
          hoveredTransferMode = null;
        });
      },
      child: InkWell(
        onTap: () {
          setState(() {
            selectedTransferMode = transferMode;
            sourceAccounts.clear();
            destinationAccounts.clear();
            vendorRows.clear();
            selectedSourceAccount = null;
            selectedDestinationAccount = null;
            selectedVendor = null;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 182,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected || isHovered ? colorScheme.primary : colorScheme.outline,
              width: isSelected || isHovered ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: color,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                mode,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
