import 'package:flutter/material.dart';
import 'package:ppv_components/common_widgets/tabs.dart';
import 'package:ppv_components/features/finance/screens/expenses/widgets/accounting_card.dart';
import 'package:ppv_components/features/finance/screens/expenses/widgets/attachments_card.dart';
import 'package:ppv_components/features/finance/screens/expenses/widgets/history_card.dart';
import '../controllers/expenses_controller.dart';
import '../widgets/expense_information_card.dart';
import '../widgets/expense_summary_card.dart';
import '../widgets/vendor_information_card.dart';
import '../widgets/attachments_section.dart';
import '../widgets/action_card.dart';

class ExpenseViewPageLayout extends StatefulWidget {
  final String expenseId;

  const ExpenseViewPageLayout({super.key, required this.expenseId});

  @override
  State<ExpenseViewPageLayout> createState() => _ExpenseViewPageLayoutState();
}

class _ExpenseViewPageLayoutState extends State<ExpenseViewPageLayout> {
  int tabIndex = 0;
  final controller = ExpensesController();

  @override
  Widget build(BuildContext context) {
    final expense = controller.getExpenseById(widget.expenseId);

    if (expense == null) {
      return Center(child: Text('Expense not found'));
    }

    Widget getTabContent() {
      switch (tabIndex) {
        case 0:
          return AttachmentsCard(attachments: expense.attachments);
        case 1:
          return HistorySection(history: expense.history);
        case 2:
          return AccountingCard(detail: expense.accountingDetail);
        default:
          return AttachmentsSection(attachments: expense.attachments);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Expense #${expense.id}'),
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.edit)),
          IconButton(onPressed: () {}, icon: Icon(Icons.delete)),
          IconButton(onPressed: () {}, icon: Icon(Icons.download)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: ListView(
                children: [
                  ExpenseInformationCard(expense: expense),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 2.0,
                      top: 16,
                      bottom: 16,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: TabsBar(
                        tabs: const ['Attachments', 'History', 'Accounting'],
                        selectedIndex: tabIndex,
                        onChanged: (idx) => setState(() => tabIndex = idx),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  getTabContent(),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  ExpenseSummaryCard(expense: expense),
                  const SizedBox(height: 16),
                  VendorInformationCard(vendorName: expense.vendor),
                  const SizedBox(height: 16),
                  ActionCard(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
