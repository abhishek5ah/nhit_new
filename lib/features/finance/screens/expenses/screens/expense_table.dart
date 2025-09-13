import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ppv_components/common_widgets/button/primary_button.dart';
import 'package:ppv_components/common_widgets/button/toggle_button.dart';
import 'package:ppv_components/common_widgets/custom_table.dart';
import 'package:ppv_components/core/utils/status_utils.dart';
import 'package:ppv_components/features/finance/data/mock_expense_db.dart';
import 'package:ppv_components/features/finance/screens/expenses/screens/expense_grid.dart';
import 'package:ppv_components/features/finance/screens/expenses/widgets/add_expense_form.dart';

class ExpenseTableView extends StatefulWidget {
  const ExpenseTableView({super.key});

  @override
  State<ExpenseTableView> createState() => _ExpenseTableViewState();
}

class _ExpenseTableViewState extends State<ExpenseTableView> {
  int toggleIndex = 0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final columns = [
      DataColumn(
        label: Text(
          'Expense #',
          style: TextStyle(color: colorScheme.onSurface),
        ),
      ),
      DataColumn(
        label: Text('Vendor', style: TextStyle(color: colorScheme.onSurface)),
      ),
      DataColumn(
        label: Text('Date', style: TextStyle(color: colorScheme.onSurface)),
      ),
      DataColumn(
        label: Text('Category', style: TextStyle(color: colorScheme.onSurface)),
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

    final rows = mockExpenses.map((expense) {
      return DataRow(
        cells: [
          DataCell(
            Text(expense.id, style: TextStyle(color: colorScheme.onSurface)),
          ),
          DataCell(
            Text(
              expense.vendor,
              style: TextStyle(color: colorScheme.onSurface),
            ),
          ),
          DataCell(
            Text(expense.date, style: TextStyle(color: colorScheme.onSurface)),
          ),
          DataCell(
            Text(
              expense.category,
              style: TextStyle(color: colorScheme.onSurface),
            ),
          ),
          DataCell(
            Text(
              expense.amount,
              style: TextStyle(color: colorScheme.onSurface),
            ),
          ),
          DataCell(
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: getStatusColor(expense.status),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                expense.status,
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
                  context.go('/finance/expense/${expense.id}');

                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: colorScheme.outline.withAlpha(77),
                    width: 1.8,
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
                    // Header with title and toggle btn
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Expenses',
                                style: TextStyle(
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 26,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Manage and track your expenses',
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
                          labels: const ['Table Form', 'Grid Form'],
                          selectedIndex: toggleIndex,
                          onChanged: (i) {
                            setState(() {
                              toggleIndex = i;
                            });
                          },
                        ),
                        const SizedBox(width: 12),
                        PrimaryButton(
                          label: 'Manage Expenses',
                          icon: Icons.add,
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AddExpenseDialog(),
                            );
                          },
                          backgroundColor: colorScheme.primary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    //  Table or Grid based on toggle index
                    Expanded(
                      child: toggleIndex == 0
                          ? CustomTable(columns: columns, rows: rows)
                          : ExpenseGrid(), // expense grid widget
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
