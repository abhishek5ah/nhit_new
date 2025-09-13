import 'package:flutter/material.dart';
import 'package:ppv_components/features/finance/screens/invoices/widgets/invoice_footer.dart';
import 'package:ppv_components/features/finance/model/invoice_view_model.dart';

class InvoiceDetailsCard extends StatefulWidget {
  final Invoice invoice;

  const InvoiceDetailsCard({super.key, required this.invoice});

  @override
  State<InvoiceDetailsCard> createState() => _InvoiceDetailsCardState();
}

class _InvoiceDetailsCardState extends State<InvoiceDetailsCard> {
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final invoice = widget.invoice;

    return Card(
      margin: const EdgeInsets.only(left: 8, right: 8, bottom: 6),
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return ConstrainedBox(
            constraints: BoxConstraints(maxHeight: constraints.maxHeight),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Invoice Details",
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "Paid",
                            style: TextStyle(
                              color: Colors.green[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 26),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _PartyInfo(
                            title: "From",
                            party: invoice.sender,
                          ),
                        ),
                        const SizedBox(width: 38),
                        Expanded(
                          child: _PartyInfo(
                            title: "To",
                            party: invoice.recipient,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        _MetaDataLine(
                          label: "Invoice Number",
                          value: invoice.number,
                        ),
                        const SizedBox(width: 34),
                        _MetaDataLine(
                          label: "Invoice Date",
                          value: _formatDate(invoice.date),
                        ),
                        const SizedBox(width: 34),
                        _MetaDataLine(
                          label: "Due Date",
                          value: _formatDate(invoice.dueDate),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        _TabButton(
                          label: "Items",
                          selected: selectedTab == 0,
                          onTap: () => setState(() => selectedTab = 0),
                        ),
                        const SizedBox(width: 10),
                        _TabButton(
                          label: "GST Details",
                          selected: selectedTab == 1,
                          onTap: () => setState(() => selectedTab = 1),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    selectedTab == 0
                        ? _InvoiceItemsTable(
                            items: invoice.items,
                            totals: invoice.totals,
                          )
                        : _InvoiceGSTTable(totals: invoice.totals),
                    const SizedBox(height: 18),
                    const Divider(),
                    const SizedBox(height: 10),
                    const InvoiceFooter(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime d) =>
      "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
}

class _PartyInfo extends StatelessWidget {
  final String title;
  final Party party;

  const _PartyInfo({required this.title, required this.party, Key? key})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(
          party.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(party.address),
        Text(
          "GSTIN: ${party.gstin}",
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        Text(
          party.email,
          style: const TextStyle(
            color: Colors.blue,
            decoration: TextDecoration.underline,
          ),
        ),
        Text(party.phone),
      ],
    );
  }
}

class _MetaDataLine extends StatelessWidget {
  final String label;
  final String value;

  const _MetaDataLine({required this.label, required this.value, Key? key})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(value),
      ],
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.grey.shade200 : Colors.transparent,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: selected ? Colors.grey : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: selected ? Colors.black : Colors.grey,
          ),
        ),
      ),
    );
  }
}

class _InvoiceItemsTable extends StatelessWidget {
  final List<InvoiceItem> items;
  final InvoiceTotals totals;

  const _InvoiceItemsTable({
    required this.items,
    required this.totals,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 6.0),
          child: Text("Items", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        DataTable(
          columns: const [
            DataColumn(label: Text('Item')),
            DataColumn(label: Text('HSN/SAC')),
            DataColumn(label: Text('Quantity')),
            DataColumn(label: Text('Price')),
            DataColumn(label: Text('GST')),
            DataColumn(label: Text('Total')),
          ],
          rows: [
            ...items.map(
              (item) => DataRow(
                cells: [
                  DataCell(Text(item.name)),
                  DataCell(Text(item.hsn)),
                  DataCell(Text(item.quantity.toString())),
                  DataCell(Text(item.price.toStringAsFixed(2))),
                  DataCell(Text('${item.gst}%')),
                  DataCell(Text(item.total.toStringAsFixed(2))),
                ],
              ),
            ),
            DataRow(
              cells: [
                const DataCell(Text('')),
                const DataCell(Text('')),
                const DataCell(Text('')),
                const DataCell(Text('')),
                const DataCell(
                  Text(
                    'Subtotal',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                DataCell(
                  Text(
                    totals.subtotal.toStringAsFixed(2),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            DataRow(
              cells: [
                const DataCell(Text('')),
                const DataCell(Text('')),
                const DataCell(Text('')),
                const DataCell(Text('')),
                DataCell(
                  Text(
                    'CGST (${totals.cgstPercent}%)',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                DataCell(Text(totals.cgst.toStringAsFixed(2))),
              ],
            ),
            DataRow(
              cells: [
                const DataCell(Text('')),
                const DataCell(Text('')),
                const DataCell(Text('')),
                const DataCell(Text('')),
                DataCell(
                  Text(
                    'SGST (${totals.sgstPercent}%)',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                DataCell(Text(totals.sgst.toStringAsFixed(2))),
              ],
            ),
            DataRow(
              cells: [
                const DataCell(Text('')),
                const DataCell(Text('')),
                const DataCell(Text('')),
                const DataCell(Text('')),
                const DataCell(
                  Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                DataCell(
                  Text(
                    totals.total.toStringAsFixed(2),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _InvoiceGSTTable extends StatelessWidget {
  final InvoiceTotals totals;

  const _InvoiceGSTTable({required this.totals});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "GST Details",
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Text(
          'CGST (${totals.cgstPercent}%) : ₹${totals.cgst.toStringAsFixed(2)}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        Text(
          'SGST (${totals.sgstPercent}%) : ₹${totals.sgst.toStringAsFixed(2)}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Text(
          'Total : ₹${totals.total.toStringAsFixed(2)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
