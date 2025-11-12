import 'package:flutter/material.dart';

class CreatePaymentScreen extends StatefulWidget {
  const CreatePaymentScreen({super.key});

  @override
  State<CreatePaymentScreen> createState() => _CreatePaymentScreenState();
}

class _CreatePaymentScreenState extends State<CreatePaymentScreen> {
  final TextEditingController _noteNoController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();

  // Less and Add rows
  final List<Map<String, TextEditingController>> _lessRows = [];
  final List<Map<String, TextEditingController>> _addRows = [];

  // Bank Details
  final TextEditingController _bankHolderController = TextEditingController();
  final TextEditingController _accountHolderController = TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _bankName2Controller = TextEditingController();
  final TextEditingController _bankAccountController = TextEditingController();
  final TextEditingController _accountNumberController = TextEditingController();
  final TextEditingController _ifscController = TextEditingController();
  final TextEditingController _ifsc2Controller = TextEditingController();

  final TextEditingController _recommendationController =
  TextEditingController(text: 'Proposed to release the payment');

  final TextEditingController _netPayableRoundController =
  TextEditingController(text: '0.00');

  @override
  void initState() {
    super.initState();
    _addLessRow();
    _addAddRow();
  }

  @override
  void dispose() {
    _noteNoController.dispose();
    _subjectController.dispose();
    for (var row in _lessRows) {
      row['particular']?.dispose();
      row['amount']?.dispose();
    }
    for (var row in _addRows) {
      row['particular']?.dispose();
      row['amount']?.dispose();
    }
    _bankHolderController.dispose();
    _accountHolderController.dispose();
    _bankNameController.dispose();
    _bankName2Controller.dispose();
    _bankAccountController.dispose();
    _accountNumberController.dispose();
    _ifscController.dispose();
    _ifsc2Controller.dispose();
    _recommendationController.dispose();
    _netPayableRoundController.dispose();
    super.dispose();
  }

  void _addLessRow() {
    setState(() {
      _lessRows.add({
        'particular': TextEditingController(),
        'amount': TextEditingController(),
      });
    });
  }

  void _removeLessRow(int index) {
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
        'amount': TextEditingController(),
      });
    });
  }

  void _removeAddRow(int index) {
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final grossAmount = 0.0; // To be set/calculated
    final lessTotal = _getTotal(_lessRows);
    final addTotal = _getTotal(_addRows);
    final netPayable = grossAmount - lessTotal + addTotal;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header inside dynamic-themed container
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(36, 16, 0, 16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorScheme.outline,
                  width: 0.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.receipt_long,
                        color: colorScheme.onPrimary, size: 26),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Create Payment Note',
                          style: textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Create and manage payment requests, including less/add particulars, bank details, and supporting docs.',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withAlpha(204),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Note No. & Subject
            Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              decoration: BoxDecoration(
                border: Border.all(
                  color: colorScheme.outline.withOpacity(0.25),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Create Payment Note',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      SizedBox(
                        width: 220,
                        child: TextFormField(
                          controller: _noteNoController,
                          decoration: InputDecoration(
                            labelText: 'Note No',
                            fillColor: colorScheme.surface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: TextFormField(
                          controller: _subjectController,
                          decoration: InputDecoration(
                            labelText: 'Subject',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildLessOrAddSection(
                context,
                textTheme,
                colorScheme,
                true,
                _lessRows,
                _addLessRow,
                _removeLessRow,
                _getTotal(_lessRows)),
            const SizedBox(height: 18),
            _buildLessOrAddSection(
                context,
                textTheme,
                colorScheme,
                false,
                _addRows,
                _addAddRow,
                _removeAddRow,
                _getTotal(_addRows)),
            const SizedBox(height: 24),

            // Net Payable Stats Section INSIDE CONTAINER
            Container(
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withOpacity(0.13),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colorScheme.primary),
              ),
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(18)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.table_chart_rounded,
                            size: 18, color: colorScheme.onPrimary),
                        const SizedBox(width: 8),
                        Text(
                          'Net Payable Amount Calculation',
                          style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onPrimary,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildStatCard(
                          'Gross Amount',
                          '₹${grossAmount.toStringAsFixed(2)}',
                          colorScheme,
                          colorScheme.primary),
                      _buildStatCard(
                          'Less Amount',
                          '-₹${lessTotal.toStringAsFixed(2)}',
                          colorScheme,
                          colorScheme.error),
                      _buildStatCard(
                          'Add Amount',
                          '+₹${addTotal.toStringAsFixed(2)}',
                          colorScheme,
                          colorScheme.secondary),
                      _buildStatCard(
                          'Net Payable',
                          '₹${netPayable.toStringAsFixed(2)}',
                          colorScheme,
                          colorScheme.tertiary),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Net Payable Amount (Round Off)
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    readOnly: true,
                    initialValue: 'Net Payable Amount (Round Off)',
                    style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.7)),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: colorScheme.surfaceContainer,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    controller: _netPayableRoundController,
                    keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _buildBankDetailsSection(context, colorScheme, textTheme),
            const SizedBox(height: 22),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Recommendation of Payment',
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _recommendationController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Spacer(),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 36, vertical: 14),
                  ),
                  onPressed: () {},
                  child: const Text('Submit'),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Attached Supporting Docs',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border:
                Border.all(color: colorScheme.outline.withOpacity(0.25)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('S. NO.')),
                  DataColumn(label: Text('FILE NAME')),
                  DataColumn(label: Text('FILE')),
                  DataColumn(label: Text('UPLOAD DATE')),
                  DataColumn(label: Text('UPLOADED BY')),
                  DataColumn(label: Text('ACTION')),
                ],
                rows: const [],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLessOrAddSection(
      BuildContext context,
      TextTheme textTheme,
      ColorScheme colorScheme,
      bool isLess,
      List<Map<String, TextEditingController>> rows,
      VoidCallback onAdd,
      Function(int) onRemove,
      double total) {
    final color = isLess ? colorScheme.error : colorScheme.secondary;
    final label = isLess
        ? 'Less: Particulars & Payable Amount'
        : 'Add: Particulars & Payable Amount';

    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(18)),
                child: Row(
                  children: [
                    Icon(isLess ? Icons.remove : Icons.add,
                        size: 16, color: colorScheme.onPrimary),
                    const SizedBox(width: 4),
                    Text(
                      label,
                      style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onPrimary, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: color,
                ),
                icon: const Icon(Icons.add),
                label: const Text('Add Row'),
                onPressed: onAdd,
              ),
            ],
          ),
          ...rows.asMap().entries.map((entry) {
            final index = entry.key;
            final row = entry.value;
            return Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: row['particular'],
                      decoration: const InputDecoration(
                        labelText: 'Particular',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 140,
                    child: TextFormField(
                      controller: row['amount'],
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Amount (₹)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete_outline, color: colorScheme.error),
                    tooltip: 'Remove',
                    onPressed: () => onRemove(index),
                  ),
                ],
              ),
            );
          }).toList(),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Text(
                isLess
                    ? 'Total Less Amount: ₹${total.toStringAsFixed(2)}'
                    : 'Total Add Amount: ₹${total.toStringAsFixed(2)}',
                style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold, color: color),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, ColorScheme colorScheme, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.11),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: colorScheme.onSurface.withOpacity(0.7),
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBankDetailsSection(BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Bank Details:', style: textTheme.titleMedium?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        )),
        const SizedBox(height: 8),
        // First Row
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _bankHolderController,
                decoration: const InputDecoration(
                  labelText: 'Name of Account holder',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: _accountHolderController,
                decoration: const InputDecoration(
                  labelText: 'Account Holder Name',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Second Row
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _bankNameController,
                decoration: const InputDecoration(
                  labelText: 'Bank Name',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: _bankName2Controller,
                decoration: const InputDecoration(
                  labelText: 'Bank Name',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Third Row
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _bankAccountController,
                decoration: const InputDecoration(
                  labelText: 'Bank Account',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: _accountNumberController,
                decoration: const InputDecoration(
                  labelText: 'Account Number',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Fourth Row
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _ifscController,
                decoration: const InputDecoration(
                  labelText: 'IFSC',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: _ifsc2Controller,
                decoration: const InputDecoration(
                  labelText: 'IFSC Code',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
