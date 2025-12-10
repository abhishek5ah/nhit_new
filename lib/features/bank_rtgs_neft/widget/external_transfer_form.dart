import 'package:flutter/material.dart';
import 'package:ppv_components/common_widgets/button/primary_button.dart';
import 'package:ppv_components/common_widgets/button/outlined_button.dart';
import 'package:ppv_components/common_widgets/custom_dropdown.dart';

class ExternalTransferPage extends StatefulWidget {
  const ExternalTransferPage({super.key});

  @override
  State<ExternalTransferPage> createState() => _ExternalTransferPageState();
}

class _ExternalTransferPageState extends State<ExternalTransferPage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Form controllers
  final TextEditingController transferAmountController = TextEditingController();
  final TextEditingController purposeController = TextEditingController();
  final TextEditingController remarksController = TextEditingController();

  String? selectedTransferMode;
  String? selectedSourceAccount;
  String? selectedVendor;

  // Sample static data - replace with your actual data source or load dynamically
  final List<String> availableAccounts = [
    'Main Account - ACC001',
    'Savings Account - ACC002',
    'Business Account - ACC003',
  ];

  final List<String> availableVendors = [
    'Vendor A - VEN001',
    'Vendor B - VEN002',
    'Vendor C - VEN003',
  ];

  List<Map<String, dynamic>> vendorRows = [];
  List<Map<String, dynamic>> sourceAccounts = [];

  @override
  void dispose() {
    transferAmountController.dispose();
    purposeController.dispose();
    remarksController.dispose();

    for (var vendor in vendorRows) {
      vendor['amount']?.dispose();
    }
    for (var account in sourceAccounts) {
      account['amount']?.dispose();
    }

    super.dispose();
  }

  void addVendorRow() {
    setState(() {
      vendorRows.add({
        'vendor': null,
        'amount': TextEditingController(text: '0.00'),
      });
    });
  }

  void removeVendorRow(int index) {
    setState(() {
      vendorRows[index]['amount']?.dispose();
      vendorRows.removeAt(index);
    });
  }

  void incrementAmount(TextEditingController controller, {double step = 0.01}) {
    final currentValue = double.tryParse(controller.text) ?? 0.0;
    final newValue = currentValue + step;
    controller.text = newValue.toStringAsFixed(2);
    setState(() {});
  }

  void decrementAmount(TextEditingController controller, {double step = 0.01}) {
    final currentValue = double.tryParse(controller.text) ?? 0.0;
    final newValue = (currentValue - step).clamp(0.0, double.infinity);
    controller.text = newValue.toStringAsFixed(2);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
              const Text('*', style: TextStyle(color: Colors.red, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 16),
          DropdownButton<String>(
            value: selectedTransferMode,
            items: ['One to One', 'One to Many', 'Many to Many']
                .map((mode) => DropdownMenuItem(value: mode, child: Text(mode)))
                .toList(),
            onChanged: (mode) => setState(() {
              selectedTransferMode = mode;
              vendorRows.clear();
              sourceAccounts.clear();
              selectedSourceAccount = null;
              selectedVendor = null;
            }),
            hint: const Text('Select Transfer Mode'),
          ),
          const SizedBox(height: 24),

          if (selectedTransferMode == 'One to One') ...[
            DropdownField(
              label: 'Source Account',
              value: selectedSourceAccount,
              items: availableAccounts,
              isRequired: true,
              onChanged: (val) => setState(() => selectedSourceAccount = val),
            ),
            const SizedBox(height: 16),
            DropdownField(
              label: 'Vendor',
              value: selectedVendor,
              items: availableVendors,
              isRequired: true,
              onChanged: (val) => setState(() => selectedVendor = val),
            ),
          ],

          if (selectedTransferMode == 'One to Many') ...[
            DropdownField(
              label: 'Source Account',
              value: selectedSourceAccount,
              items: availableAccounts,
              isRequired: true,
              onChanged: (val) => setState(() => selectedSourceAccount = val),
            ),
            const SizedBox(height: 16),
            Text('Vendors', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            ...List.generate(vendorRows.length, (index) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: CustomDropdown(
                      value: vendorRows[index]['vendor'],
                      items: availableVendors,
                      hint: 'Select vendor',
                      onChanged: (val) => setState(() => vendorRows[index]['vendor'] = val),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AmountStepperField(
                      controller: vendorRows[index]['amount'],
                      increment: () => incrementAmount(vendorRows[index]['amount']),
                      decrement: () => decrementAmount(vendorRows[index]['amount']),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: () => removeVendorRow(index),
                    icon: const Icon(Icons.delete_outline),
                    color: Colors.red,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.red.withOpacity(0.1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            )),
            OutlinedButton.icon(
              onPressed: addVendorRow,
              icon: const Icon(Icons.add),
              label: const Text('Add Vendor'),
            ),
          ],

          if (selectedTransferMode == 'Many to Many') ...[
            // Implement similar structure for Many to Many as per original code,
            // including sourceAccounts list management (left here for brevity)
          ],

          const SizedBox(height: 16),
          _buildAmountStepperField(
            controller: transferAmountController,
            label: 'Transfer Amount (₹)',
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Purpose',
            hint: 'Enter transfer purpose',
            controller: purposeController,
            isRequired: true,
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Remarks',
            hint: 'Enter additional remarks (optional)',
            controller: remarksController,
            maxLines: 3,
          ),
        ],
      ),
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
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        suffixIcon: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 24,
              width: 24,
              child: IconButton(
                padding: EdgeInsets.zero,
                iconSize: 20,
                icon: Icon(Icons.arrow_drop_up, color: effectiveAccentColor),
                onPressed: () => incrementAmount(controller, step: 0.01),
                tooltip: 'Increase',
              ),
            ),
            SizedBox(
              height: 24,
              width: 24,
              child: IconButton(
                padding: EdgeInsets.zero,
                iconSize: 20,
                icon: Icon(Icons.arrow_drop_down, color: effectiveAccentColor),
                onPressed: () => decrementAmount(controller, step: 0.01),
                tooltip: 'Decrease',
              ),
            ),
          ],
        ),
      ),
      onChanged: (_) => setState(() {}),
      validator: (value) {
        if (value == null || value.isEmpty || double.tryParse(value) == null) {
          return 'Invalid amount';
        }
        return null;
      },
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
            if (isRequired)
              const SizedBox(width: 4),
            if (isRequired)
              const Text('*', style: TextStyle(color: Colors.red, fontSize: 16)),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: colorScheme.primary, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: maxLines > 1 ? 16 : 14),
          ),
          validator: isRequired
              ? (value) {
            if (value == null || value.isEmpty) return 'This field is required';
            return null;
          }
              : null,
        ),
      ],
    );
  }

  Widget DropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required bool isRequired,
    required ValueChanged<String?> onChanged,
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
            if (isRequired)
              const SizedBox(width: 4),
            if (isRequired)
              const Text('*', style: TextStyle(color: Colors.red, fontSize: 16)),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
          items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
          onChanged: onChanged,
          validator: isRequired
              ? (value) {
            if (value == null || value.isEmpty) return 'Please select $label';
            return null;
          }
              : null,
        ),
      ],
    );
  }
}

class AmountStepperField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback increment;
  final VoidCallback decrement;

  const AmountStepperField({
    Key? key,
    required this.controller,
    required this.increment,
    required this.decrement,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        filled: true,
        fillColor: colorScheme.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        suffixIcon: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 24,
              width: 24,
              child: IconButton(
                padding: EdgeInsets.zero,
                iconSize: 20,
                icon: Icon(Icons.arrow_drop_up, color: colorScheme.primary),
                onPressed: increment,
                tooltip: 'Increase',
              ),
            ),
            SizedBox(
              height: 24,
              width: 24,
              child: IconButton(
                padding: EdgeInsets.zero,
                iconSize: 20,
                icon: Icon(Icons.arrow_drop_down, color: colorScheme.primary),
                onPressed: decrement,
                tooltip: 'Decrease',
              ),
            ),
          ],
        ),
      ),
      onChanged: (_) {},
      validator: (value) {
        if (value == null || value.isEmpty || double.tryParse(value) == null) return 'Invalid amount';
        return null;
      },
    );
  }
}
