import 'dart:math';

import 'package:flutter/material.dart';

class CreatePaymentScreen extends StatefulWidget {
  const CreatePaymentScreen({super.key});

  @override
  State<CreatePaymentScreen> createState() => _CreatePaymentScreenState();
}

class _CreatePaymentScreenState extends State<CreatePaymentScreen> {
  final TextEditingController _noteNoController = TextEditingController(
    text: 'W/25-26/PN/0001',
  );

  // Less and Add rows
  final List<Map<String, TextEditingController>> _lessRows = [];
  final List<Map<String, TextEditingController>> _addRows = [];

  // Bank Details
  final TextEditingController _accountHolderNameController =
  TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _accountNumberController =
  TextEditingController();
  final TextEditingController _ifscCodeController = TextEditingController();

  final TextEditingController _recommendationController = TextEditingController(
    text: 'Proposed to release the payment',
  );

  final TextEditingController _netPayableRoundController =
  TextEditingController(text: '0.00');

  double _grossAmount = 0.0; // Set this from invoice/bill data

  @override
  void initState() {
    super.initState();
    _addLessRow();
    _addAddRow();
  }

  @override
  void dispose() {
    _noteNoController.dispose();
    for (var row in _lessRows) {
      row['particular']?.dispose();
      row['amount']?.dispose();
    }
    for (var row in _addRows) {
      row['particular']?.dispose();
      row['amount']?.dispose();
    }
    _accountHolderNameController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _ifscCodeController.dispose();
    _recommendationController.dispose();
    _netPayableRoundController.dispose();
    super.dispose();
  }

  void _addLessRow() {
    setState(() {
      _lessRows.add({
        'particular': TextEditingController(),
        'amount': TextEditingController(text: '0.00'),
      });
    });
  }

  void _removeLessRow(int index) {
    // Check if only one row remains
    if (_lessRows.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'At least one row is required in Less: Deductions',
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _lessRows[index]['particular']?.dispose();
      _lessRows[index]['amount']?.dispose();
      _lessRows.removeAt(index);
    });
  }

  void _addAddRow() {
    setState(() {
      _addRows.add({
        'particular': TextEditingController(),
        'amount': TextEditingController(text: '0.00'),
      });
    });
  }

  void _removeAddRow(int index) {
    // Check if only one row remains
    if (_addRows.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('At least one row is required in Add: Additions'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _addRows[index]['particular']?.dispose();
      _addRows[index]['amount']?.dispose();
      _addRows.removeAt(index);
    });
  }

  double _getTotal(List<Map<String, TextEditingController>> rows) {
    double total = 0.0;
    for (final row in rows) {
      final text = row['amount']?.text ?? '';
      final amount = double.tryParse(text) ?? 0;
      total += amount;
    }
    return total;
  }

  void _incrementAmount(TextEditingController controller, {double step = 1.0}) {
    final currentValue = double.tryParse(controller.text) ?? 0.0;
    final newValue = currentValue + step;
    controller.text = newValue.toStringAsFixed(2);
    setState(() {});
  }

  void _decrementAmount(TextEditingController controller, {double step = 1.0}) {
    final currentValue = double.tryParse(controller.text) ?? 0.0;
    final newValue = (currentValue - step).clamp(0.0, double.infinity);
    controller.text = newValue.toStringAsFixed(2);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final lessTotal = _getTotal(_lessRows);
    final addTotal = _getTotal(_addRows);
    final netPayable = _grossAmount - lessTotal + addTotal;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.outlineVariant, width: 1),
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
                      Icons.receipt_long,
                      color: colorScheme.onPrimary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Create Payment Note',
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Create and manage payment requests, including less/add particulars, bank details, and supporting docs.',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Main Form Container - Everything wrapped in a box
            Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                border: Border.all(color: colorScheme.outlineVariant, width: 1),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Note Number Section (Single Field)
                  Text(
                    'Create Payment Note',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _noteNoController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Note Number',
                      filled: true,
                      fillColor: colorScheme.surfaceContainer,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Less: Deductions Section (Using theme colors)
                  _buildLessSection(context, textTheme, colorScheme),
                  const SizedBox(height: 16),

                  // Add: Additions Section (Using theme colors)
                  _buildAddSection(context, textTheme, colorScheme),
                  const SizedBox(height: 24),

                  // Formula text
                  Center(
                    child: Text(
                      'Formula: Net Payable = Gross - Deductions + Additions',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Net Payable Calculation Card
                  Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colorScheme.outline,
                        width: 1,
                      ),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.calculate_outlined,
                              size: 20,
                              color: colorScheme.onSurface,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Net Payable Calculation',
                              style: textTheme.titleMedium?.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _buildStatCard(
                              'Gross (Invoice)',
                              '₹${_grossAmount.toStringAsFixed(2)}',
                              colorScheme,
                            ),
                            _buildStatCard(
                              'Less (Deductions)',
                              '-₹${lessTotal.toStringAsFixed(2)}',
                              colorScheme,
                            ),
                            _buildStatCard(
                              'Add (Additions)',
                              '+₹${addTotal.toStringAsFixed(2)}',
                              colorScheme,
                            ),
                            _buildStatCard(
                              'Net Payable',
                              '₹${netPayable.toStringAsFixed(2)}',
                              colorScheme,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Net Payable Amount (Round Off)
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          readOnly: true,
                          initialValue: 'Net Payable Amount (Round Off)',
                          style: textTheme.bodyMedium,
                          decoration: InputDecoration(
                            filled: false,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          controller: _netPayableRoundController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 16,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Bank Details Section
                  _buildBankDetailsSection(context, colorScheme, textTheme),
                  const SizedBox(height: 24),

                  // Recommendation of Payment
                  Text(
                    'Recommendation of Payment',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _recommendationController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Submit Button
                  Align(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 48,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        // Handle submit
                      },
                      child: Text(
                        'Submit',
                        style: textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Attached Supporting Docs (Outside the main box)
            Text(
              'Attached Supporting Docs',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: colorScheme.outlineVariant),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(
                  colorScheme.surfaceContainerHighest,
                ),
                columns: [
                  DataColumn(
                    label: Text(
                      'S NO.',
                      style: textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'FILE NAME',
                      style: textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'FILE',
                      style: textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'UPLOAD DATE',
                      style: textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'UPLOADED BY',
                      style: textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'ACTION',
                      style: textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
                rows: const [],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLessSection(
      BuildContext context,
      TextTheme textTheme,
      ColorScheme colorScheme,
      ) {
    final lessTotal = _getTotal(_lessRows);
    final bgColor = colorScheme.surface;
    final headerColor = colorScheme.onPrimary;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.outline,
          width: 1,
        ),      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: headerColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: colorScheme.onPrimary,
                    width: 0.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.remove_circle_outline,
                      size: 18,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Less: Deductions',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.primary,
                  backgroundColor: colorScheme.onPrimary,
                  side: BorderSide(color: headerColor),
                ),
                icon: const Icon(Icons.add_circle_outline, size: 18),
                label: const Text('Add Row'),
                onPressed: _addLessRow,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Rows
          ..._lessRows.asMap().entries.map((entry) {
            final index = entry.key;
            final row = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: row['particular'],
                      decoration: InputDecoration(
                        labelText: 'Particular',
                        filled: true,
                        fillColor: colorScheme.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      controller: row['amount'],
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Amount (₹)',
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
                                  color: headerColor,
                                ),
                                onPressed: () => _incrementAmount(
                                  row['amount']!,
                                  step: 0.01,
                                ),
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
                                  color: headerColor,
                                ),
                                onPressed: () => _decrementAmount(
                                  row['amount']!,
                                  step: 0.01,
                                ),
                                tooltip: 'Decrease',
                              ),
                            ),
                          ],
                        ),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete_outline, color: colorScheme.error),
                    tooltip: 'Remove',
                    onPressed: () => _removeLessRow(index),
                  ),
                ],
              ),
            );
          }).toList(),

          // Tip text
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Tip: Use this section for TDS, penalties, or any amount to subtract.',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.secondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Total
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Total Deductions: ₹${lessTotal.toStringAsFixed(2)}',
              style: textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddSection(
      BuildContext context,
      TextTheme textTheme,
      ColorScheme colorScheme,
      ) {
    final addTotal = _getTotal(_addRows);
    final bgColor = colorScheme.surface;
    final headerColor = colorScheme.onPrimary;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.outline,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: headerColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: colorScheme.onPrimary,
                    width: 0.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add_circle_outline,
                      size: 18,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Add: Additions',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.primary,
                  backgroundColor: colorScheme.onPrimary,
                  // side: BorderSide(color: headerColor),
                ),
                icon: const Icon(Icons.add_circle_outline, size: 18),
                label: const Text('Add Row'),
                onPressed: _addAddRow,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Rows
          ..._addRows.asMap().entries.map((entry) {
            final index = entry.key;
            final row = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: row['particular'],
                      decoration: InputDecoration(
                        labelText: 'Particular',
                        filled: true,
                        fillColor: colorScheme.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      controller: row['amount'],
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Amount (₹)',
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
                                  color: headerColor,
                                ),
                                onPressed: () => _incrementAmount(
                                  row['amount']!,
                                  step: 0.01,
                                ),
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
                                  color: headerColor,
                                ),
                                onPressed: () => _decrementAmount(
                                  row['amount']!,
                                  step: 0.01,
                                ),
                                tooltip: 'Decrease',
                              ),
                            ),
                          ],
                        ),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete_outline, color: colorScheme.error),
                    tooltip: 'Remove',
                    onPressed: () => _removeAddRow(index),
                  ),
                ],
              ),
            );
          }).toList(),

          // Tip text
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Tip: Use this for rounding additions, refunds, or extra approved amounts.',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.secondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Total
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Total Additions: ₹${addTotal.toStringAsFixed(2)}',
              style: textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String label,
      String value,
      ColorScheme colorScheme, {
        bool highlighted = false,
      }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: highlighted
              ? Border.all(color: colorScheme.onPrimary, width: 0.5)
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.9),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBankDetailsSection(
      BuildContext context,
      ColorScheme colorScheme,
      TextTheme textTheme,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bank Details:',
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _accountHolderNameController,
                decoration: InputDecoration(
                  labelText: 'Account Holder Name',
                  filled: true,
                  fillColor: colorScheme.surfaceContainer,

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _bankNameController,
                decoration: InputDecoration(
                  labelText: 'Bank Name',
                  filled: true,
                  fillColor: colorScheme.surfaceContainer,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _accountNumberController,
                decoration: InputDecoration(
                  labelText: 'Account Number',
                  filled: true,
                  fillColor: colorScheme.surfaceContainer,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _ifscCodeController,
                decoration: InputDecoration(
                  labelText: 'IFSC Code',
                  filled: true,
                  fillColor: colorScheme.surfaceContainer,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
