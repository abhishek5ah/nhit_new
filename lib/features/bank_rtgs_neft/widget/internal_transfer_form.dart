import 'package:flutter/material.dart';
import 'package:ppv_components/common_widgets/button/primary_button.dart';
import 'package:ppv_components/common_widgets/button/outlined_button.dart';
import 'package:ppv_components/common_widgets/custom_dropdown.dart';

class CreateInternalTransferForm extends StatefulWidget {
  final VoidCallback onCancel;
  final List<String> sourceAccounts;
  final List<String> destinationAccounts;
  final List<Map<String, dynamic>> transferModes;

  const CreateInternalTransferForm({
    super.key,
    required this.onCancel,
    required this.sourceAccounts,
    required this.destinationAccounts,
    required this.transferModes,
  });

  @override
  State<CreateInternalTransferForm> createState() => _CreateInternalTransferFormState();
}

class _CreateInternalTransferFormState extends State<CreateInternalTransferForm> {
  final _formKey = GlobalKey<FormState>();
  String? selectedTransferMode;
  String? hoveredTransferMode;

  // Form controllers
  final _transferAmountController = TextEditingController();
  final _purposeController = TextEditingController();
  final _remarksController = TextEditingController();

  // Dropdown values
  String? selectedSourceAccount;
  String? selectedDestinationAccount;

  // Dynamic lists for multiple accounts
  List<Map<String, dynamic>> sourceAccounts = [];
  List<Map<String, dynamic>> destinationAccounts = [];

  void _addSourceAccount() {
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

  void _addDestinationAccount() {
    setState(() {
      destinationAccounts.add({
        'account': null,
        'amount': TextEditingController(text: '0.00'),
      });
    });
  }

  void _removeDestinationAccount(int index) {
    setState(() {
      destinationAccounts[index]['amount'].dispose();
      destinationAccounts.removeAt(index);
    });
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

  @override
  void dispose() {
    _transferAmountController.dispose();
    _purposeController.dispose();
    _remarksController.dispose();
    for (var account in sourceAccounts) {
      account['amount']?.dispose();
    }
    for (var account in destinationAccounts) {
      account['amount']?.dispose();
    }
    super.dispose();
  }

  void _createTransfer() {
    if (selectedTransferMode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a transfer mode'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Creating Internal Transfer - $selectedTransferMode...'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final isSmallScreen = MediaQuery.of(context).size.width < 900;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Transfer Mode Label
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
                  children: widget.transferModes.map((mode) {
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
                  children: widget.transferModes.map((mode) {
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

          if (selectedTransferMode != null) ...[
            const SizedBox(height: 24),
            _buildDynamicFormFields(context, isSmallScreen),
          ],

          const SizedBox(height: 32),

          // Action Buttons
          if (isSmallScreen) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PrimaryButton(
                  onPressed: _createTransfer,
                  icon: Icons.check_circle_outline,
                  label: 'Create Transfer',
                ),
              ],
            ),
          ] else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                PrimaryButton(
                  onPressed: _createTransfer,
                  icon: Icons.check_circle_outline,
                  label: 'Create Transfer',
                ),
              ],
            ),
          ],
        ],
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
    final isSelected = selectedTransferMode == mode;
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
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedTransferMode = mode;
            sourceAccounts.clear();
            destinationAccounts.clear();
            selectedSourceAccount = null;
            selectedDestinationAccount = null;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutCubic,
          transform: Matrix4.identity()
            ..translate(0.0, isHovered ? -8.0 : 0.0)
            ..scale(isHovered ? 1.02 : 1.0),
          height: 182,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
              colors: [
                color.withValues(alpha: 0.15),
                colorScheme.surface,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
                : null,
            color: !isSelected ? colorScheme.surface : null,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected || isHovered ? color : colorScheme.outline,
              width: isSelected ? 2.5 : (isHovered ? 2 : 1),
            ),
            boxShadow: isHovered || isSelected
                ? [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: isSelected ? 20 : 12,
                spreadRadius: isSelected ? 2 : 0,
                offset: Offset(0, isHovered ? 8 : 4),
              ),
            ]
                : [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: isSelected ? 0.2 : 0.1),
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
                mode,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? color : colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                  fontSize: 12,
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

  Widget _buildDynamicFormFields(BuildContext context, bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // One to One Mode
        if (selectedTransferMode == 'One to One') ...[
          _buildDropdownField(
            label: 'Source Account',
            value: selectedSourceAccount,
            items: widget.sourceAccounts,
            isRequired: true,
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
            items: widget.destinationAccounts,
            isRequired: true,
            onChanged: (value) {
              setState(() {
                selectedDestinationAccount = value;
              });
            },
          ),
        ],

        // One to Many Mode
        if (selectedTransferMode == 'One to Many') ...[
          _buildDropdownField(
            label: 'Source Account',
            value: selectedSourceAccount,
            items: widget.sourceAccounts,
            isRequired: true,
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
                            items: widget.destinationAccounts,
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
            onPressed: _addDestinationAccount,
            icon: Icons.add,
            label: 'Add Destination Account',
          ),
        ],

        // Many to Many Mode
        if (selectedTransferMode == 'Many to Many') ...[
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
                            items: widget.sourceAccounts,
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
            onPressed: _addSourceAccount,
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
                            items: widget.destinationAccounts,
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
            onPressed: _addDestinationAccount,
            icon: Icons.add,
            label: 'Add Destination Account',
          ),
        ],

        // Common fields
        const SizedBox(height: 16),
        _buildAmountStepperField(
          controller: _transferAmountController,
          label: 'Transfer Amount (₹)',
        ),
        const SizedBox(height: 16),
        isSmallScreen
            ? Column(
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
        )
            : Row(
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
        ),
      ],
    );
  }

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
      onChanged: (_) => setState(() {}),
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
          decoration: InputDecoration(
            hintText: hint,
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
