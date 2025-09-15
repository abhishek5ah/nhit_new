import 'package:flutter/material.dart';
import 'package:ppv_components/features/finance/model/expense.dart';

class ExpenseSummaryCard extends StatelessWidget {
  final Expense expense;

  const ExpenseSummaryCard({super.key, required this.expense});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 1,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          border: Border.all(
            color: colorScheme.outline, // use theme outline for border
            width: 0.25,
          ),
          borderRadius: BorderRadius.circular(12), //  card radius
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Expense Summary',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            _row('Expense ID', expense.id),
            _row('Amount', '\$${expense.amount.toStringAsFixed(2)}'),
            _row('Status', expense.status),
            _row('Date', '${expense.date.toLocal()}'.split(' ')[0]),
          ],
        ),
      ),
    );
  }

  Widget _row(String title, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(title), Text(value)],
    ),
  );
}
