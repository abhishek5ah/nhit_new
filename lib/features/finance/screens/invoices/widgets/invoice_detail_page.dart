import 'package:flutter/material.dart';
import 'package:ppv_components/features/finance/screens/invoices/widgets/invoice_footer.dart';
import 'package:ppv_components/features/finance/model/invoice_view_model.dart';
import 'package:ppv_components/common_widgets/custom_table.dart';

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
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(left: 8, right: 8, bottom: 6),
      color: colorScheme.surfaceContainer,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    "Invoice Details",
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "Paid",
                    style: TextStyle(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 26),

            /// From/To Party
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

            /// Meta Data
            Row(
              children: [
                _MetaDataLine(label: "Invoice Number", value: invoice.number),
                const SizedBox(width: 34),
                _MetaDataLine(
                    label: "Invoice Date", value: _formatDate(invoice.date)),
                const SizedBox(width: 34),
                _MetaDataLine(
                    label: "Due Date", value: _formatDate(invoice.dueDate)),
              ],
            ),
            const SizedBox(height: 18),

            /// Tabs
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

            /// Tab Content
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
    );
  }

  String _formatDate(DateTime d) =>
      "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
}

/// Party Info
class _PartyInfo extends StatelessWidget {
  final String title;
  final Party party;

  const _PartyInfo({required this.title, required this.party, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(
          party.name,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(party.address),
        Text("GSTIN: ${party.gstin}",
            style: const TextStyle(fontWeight: FontWeight.w500)),
        Text(
          party.email,
          style: TextStyle(
            color: colorScheme.primary,
            decoration: TextDecoration.underline,
          ),
        ),
        Text(party.phone),
      ],
    );
  }
}

/// MetaData Line
class _MetaDataLine extends StatelessWidget {
  final String label;
  final String value;

  const _MetaDataLine({required this.label, required this.value, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text("$label: ",
            style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(value),
      ],
    );
  }
}

/// Tab Button
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
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? colorScheme.surfaceVariant : Colors.transparent,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: selected ? colorScheme.outline : colorScheme.outlineVariant,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: selected ? colorScheme.onSurface : colorScheme.outline,
          ),
        ),
      ),
    );
  }
}

/// Invoice Items Table using CustomTable
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
    return CustomTable(
      minTableWidth: 900,
      columns: const [
        DataColumn(label: Text("Item")),
        DataColumn(label: Text("HSN/SAC")),
        DataColumn(label: Text("Quantity")),
        DataColumn(label: Text("Price")),
        DataColumn(label: Text("GST")),
        DataColumn(label: Text("Total")),
      ],
      rows: [
        ...items.map(
              (item) => DataRow(cells: [
            DataCell(Text(item.name)),
            DataCell(Text(item.hsn)),
            DataCell(Text(item.quantity.toString())),
            DataCell(Text(item.price.toStringAsFixed(2))),
            DataCell(Text("${item.gst}%")),
            DataCell(Text(item.total.toStringAsFixed(2))),
          ]),
        ),
        DataRow(cells: [
          const DataCell(Text("")),
          const DataCell(Text("")),
          const DataCell(Text("")),
          const DataCell(Text("")),
          const DataCell(Text("Subtotal", style: TextStyle(fontWeight: FontWeight.bold))),
          DataCell(Text(totals.subtotal.toStringAsFixed(2),
              style: const TextStyle(fontWeight: FontWeight.bold))),
        ]),
        DataRow(cells: [
          const DataCell(Text("")),
          const DataCell(Text("")),
          const DataCell(Text("")),
          const DataCell(Text("")),
          DataCell(Text("CGST (${totals.cgstPercent}%)",
              style: const TextStyle(fontWeight: FontWeight.bold))),
          DataCell(Text(totals.cgst.toStringAsFixed(2))),
        ]),
        DataRow(cells: [
          const DataCell(Text("")),
          const DataCell(Text("")),
          const DataCell(Text("")),
          const DataCell(Text("")),
          DataCell(Text("SGST (${totals.sgstPercent}%)",
              style: const TextStyle(fontWeight: FontWeight.bold))),
          DataCell(Text(totals.sgst.toStringAsFixed(2))),
        ]),
        DataRow(cells: [
          const DataCell(Text("")),
          const DataCell(Text("")),
          const DataCell(Text("")),
          const DataCell(Text("")),
          const DataCell(Text("Total", style: TextStyle(fontWeight: FontWeight.bold))),
          DataCell(Text(totals.total.toStringAsFixed(2),
              style: const TextStyle(fontWeight: FontWeight.bold))),
        ]),
      ],
    );
  }
}
/// GST Table using CustomTable
class _InvoiceGSTTable extends StatelessWidget {
  final InvoiceTotals totals;

  const _InvoiceGSTTable({required this.totals, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomTable(
      minTableWidth: 700,
      columns: const [
        DataColumn(label: Text("HSN/SAC")),
        DataColumn(label: Text("Taxable Amount")),
        DataColumn(label: Text("CGST")),
        DataColumn(label: Text("SGST")),
        DataColumn(label: Text("Total Tax")),
      ],
      rows: [
        DataRow(cells: [
          const DataCell(Text("-")), // if you don't store HSN/SAC per total
          DataCell(Text("₹${totals.subtotal.toStringAsFixed(2)}")),
          DataCell(Text("₹${totals.cgst.toStringAsFixed(2)} "
              "(${totals.cgstPercent}%)")),
          DataCell(Text("₹${totals.sgst.toStringAsFixed(2)} "
              "(${totals.sgstPercent}%)")),
          DataCell(Text(
            "₹${(totals.cgst + totals.sgst).toStringAsFixed(2)}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          )),
        ]),
        DataRow(cells: [
          const DataCell(Text("Total", style: TextStyle(fontWeight: FontWeight.bold))),
          DataCell(Text("₹${totals.subtotal.toStringAsFixed(2)}",
              style: const TextStyle(fontWeight: FontWeight.bold))),
          DataCell(Text("₹${totals.cgst.toStringAsFixed(2)}",
              style: const TextStyle(fontWeight: FontWeight.bold))),
          DataCell(Text("₹${totals.sgst.toStringAsFixed(2)}",
              style: const TextStyle(fontWeight: FontWeight.bold))),
          DataCell(Text("₹${totals.total.toStringAsFixed(2)}",
              style: const TextStyle(fontWeight: FontWeight.bold))),
        ]),
      ],
    );
  }
}
