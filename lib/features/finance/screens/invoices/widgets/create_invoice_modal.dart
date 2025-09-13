import 'package:flutter/material.dart';
import 'package:ppv_components/common_widgets/button/primary_button.dart';
import 'package:ppv_components/common_widgets/button/secondary_button.dart';

class CreateInvoiceModal extends StatefulWidget {
  final VoidCallback onClose;

  const CreateInvoiceModal({super.key, required this.onClose});

  @override
  State<CreateInvoiceModal> createState() => _CreateInvoiceModalState();
}

class _CreateInvoiceModalState extends State<CreateInvoiceModal> {
  final _formKey = GlobalKey<FormState>();

  final _customerController = TextEditingController();
  final _invoiceDateController = TextEditingController();
  final _dueDateController = TextEditingController();
  final _notesController = TextEditingController();

  List<ItemRowData> items = [ItemRowData()];

  @override
  void dispose() {
    _customerController.dispose();
    _invoiceDateController.dispose();
    _dueDateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void addItem() {
    setState(() {
      items.add(ItemRowData());
    });
  }

  Widget buildItemRow(int index) {
    final item = items[index];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: TextFormField(
              decoration: const InputDecoration(labelText: 'Item name'),
              onChanged: (val) => item.name = val,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: TextFormField(
              decoration: const InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.number,
              initialValue: item.quantity.toString(),
              onChanged: (val) => item.quantity = int.tryParse(val) ?? 1,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: TextFormField(
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              initialValue: item.price.toStringAsFixed(2),
              onChanged: (val) => item.price = double.tryParse(val) ?? 0,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(flex: 2, child: Text('\$${item.total.toStringAsFixed(2)}')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      backgroundColor: Colors.transparent, // Remove default dialog background
      insetPadding: const EdgeInsets.all(12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: constraints.maxHeight * 0.9,
              maxWidth: constraints.maxWidth > 600
                  ? 600
                  : constraints.maxWidth * 0.95,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.outline, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Create Invoice',
                          style: theme.textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _customerController,
                          decoration: const InputDecoration(
                            labelText: 'Customer',
                          ),
                          validator: (val) => val == null || val.isEmpty
                              ? 'Enter a customer'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _invoiceDateController,
                                readOnly: true,
                                decoration: const InputDecoration(
                                  labelText: 'Invoice Date',
                                ),
                                onTap: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2100),
                                  );
                                  if (date != null) {
                                    _invoiceDateController.text = date
                                        .toLocal()
                                        .toString()
                                        .split(' ')[0];
                                  }
                                },
                                validator: (val) => val == null || val.isEmpty
                                    ? 'Select invoice date'
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _dueDateController,
                                readOnly: true,
                                decoration: const InputDecoration(
                                  labelText: 'Due Date',
                                ),
                                onTap: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now().add(
                                      const Duration(days: 7),
                                    ),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2100),
                                  );
                                  if (date != null) {
                                    _dueDateController.text = date
                                        .toLocal()
                                        .toString()
                                        .split(' ')[0];
                                  }
                                },
                                validator: (val) => val == null || val.isEmpty
                                    ? 'Select due date'
                                    : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Items',
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: items.length,
                          itemBuilder: (_, index) => buildItemRow(index),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: PrimaryButton(
                            label: 'Add Item',
                            onPressed: addItem,
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _notesController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Notes',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total: \$${items.fold<double>(0, (sum, item) => sum + item.total).toStringAsFixed(2)}',
                              style: theme.textTheme.titleMedium,
                            ),
                            Row(
                              children: [
                                SecondaryButton(
                                  label: 'Cancel',
                                  onPressed: widget.onClose,
                                ),
                                const SizedBox(width: 12),
                                PrimaryButton(
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {}
                                  },
                                  label: 'Create Invoice',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ItemRowData {
  String name = '';
  int quantity = 1;
  double price = 0;

  double get total => quantity * price;
}
