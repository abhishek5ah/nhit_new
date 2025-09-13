import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ppv_components/common_widgets/button/toggle_button.dart';
import 'package:ppv_components/common_widgets/custom_table.dart';
import 'package:ppv_components/core/utils/status_utils.dart';
import 'package:ppv_components/features/finance/data/mock_invoice_db.dart';
import 'package:ppv_components/features/finance/screens/invoices/invoice_grid.dart';

class InvoiceTableView extends StatefulWidget {
  const InvoiceTableView({super.key});

  @override
  State<InvoiceTableView> createState() => _InvoiceTableViewState();
}

class _InvoiceTableViewState extends State<InvoiceTableView> {
  int tabIndex = 0;
  int toggleIndex = 0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final columns = [
      DataColumn(
        label: Text(
          'Invoice #',
          style: TextStyle(color: colorScheme.onSurface),
        ),
      ),
      DataColumn(
        label: Text('Customer', style: TextStyle(color: colorScheme.onSurface)),
      ),
      DataColumn(
        label: Text('Date', style: TextStyle(color: colorScheme.onSurface)),
      ),
      DataColumn(
        label: Text('DueDate', style: TextStyle(color: colorScheme.onSurface)),
      ),
      DataColumn(
        label: Text('Amount', style: TextStyle(color: colorScheme.onSurface)),
      ),
      DataColumn(
        label: Text('Status', style: TextStyle(color: colorScheme.onSurface)),
      ),
      DataColumn(
        label: Text('Actions', style: TextStyle(color: colorScheme.onSurface)),
      ),
    ];

    // Table rows from mock DB
    final rows = mockInvoices.map((invoice) {
      return DataRow(
        cells: [
          DataCell(
            Text(invoice.id, style: TextStyle(color: colorScheme.onSurface)),
          ),
          DataCell(
            Text(
              invoice.customer,
              style: TextStyle(color: colorScheme.onSurface),
            ),
          ),
          DataCell(
            Text(invoice.date, style: TextStyle(color: colorScheme.onSurface)),
          ),
          DataCell(
            Text(
              invoice.dueDate,
              style: TextStyle(color: colorScheme.onSurface),
            ),
          ),
          DataCell(
            Text(
              invoice.amount,
              style: TextStyle(color: colorScheme.onSurface),
            ),
          ),
          DataCell(
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: getStatusColor(invoice.status),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                invoice.status,
                style: TextStyle(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          DataCell(
            OutlinedButton(
              onPressed: () {
                context.go('/finance/invoices/${invoice.id}');
              },

              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: colorScheme.outline.withValues(alpha: 0.3),
                  width: 1.2,
                ),
                foregroundColor: colorScheme.onSurface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 8,
                ),
              ),
              child: Text(
                'View',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ),
        ],
      );
    }).toList();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(22),
                ),
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Invoices',
                                style: TextStyle(
                                  color: colorScheme.onSurface,
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Manage and track your customer invoices',
                                style: TextStyle(
                                  color: colorScheme.onSurface.withValues(
                                    alpha: 0.65,
                                  ),
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ToggleBtn(
                          labels: ['Table Form', 'Grid Form'],
                          selectedIndex: toggleIndex,
                          onChanged: (i) {
                            setState(() => toggleIndex = i);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: toggleIndex == 0
                          ? CustomTable(columns: columns, rows: rows)
                          : InvoiceGridView(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
