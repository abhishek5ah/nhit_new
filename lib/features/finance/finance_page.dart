import 'package:flutter/material.dart';
import 'package:ppv_components/common_widgets/button/primary_button.dart';
import 'package:ppv_components/common_widgets/button/secondary_button.dart';
import 'package:ppv_components/common_widgets/tabs.dart';
import 'package:ppv_components/features/finance/finance_header.dart';
import 'package:ppv_components/features/finance/screens/accounts/account_table.dart';
import 'package:ppv_components/features/finance/screens/expenses/screens/expense_table.dart';
import 'package:ppv_components/features/finance/screens/invoices/widgets/create_invoice_modal.dart';
import 'package:ppv_components/features/finance/screens/invoices/widgets/invoice_header_widget.dart';
import 'package:ppv_components/features/finance/screens/report/finance_report.dart';
import 'package:ppv_components/features/finance/screens/invoices/invoice_table.dart';

class FinanceMainPage extends StatefulWidget {
  const FinanceMainPage({super.key});

  @override
  State<FinanceMainPage> createState() => _FinanceMainPageState();
}

class _FinanceMainPageState extends State<FinanceMainPage> {
  int tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER SECTION ---
            Padding(
              padding: const EdgeInsets.only(left: 12.0, bottom: 12.0, right: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FinanceHeader(tabIndex: tabIndex),
                  const SizedBox(height: 12),
                ],
              ),
            ),
            // --- TABS AND BUTTONS ---
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 12.0),
                      child: Expanded(
                        child: TabsBar(
                          tabs: const [
                            'Invoices',
                            'Expenses',
                            'Accounts',
                            'Reports',
                          ],
                          selectedIndex: tabIndex,
                          onChanged: (idx) => setState(() => tabIndex = idx),
                        ),
                      ),
                    ),
                    const Spacer(),
                    SecondaryButton(
                      label: 'Export',
                      icon: Icons.arrow_downward,
                      onPressed: () {},
                      backgroundColor: colorScheme.surfaceContainer,
                    ),
                    const SizedBox(width: 14),
                    PrimaryButton(
                      label: 'New Invoice',
                      icon: Icons.add,
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => CreateInvoiceModal(
                            onClose: () => Navigator.of(context).pop(),
                          ),
                        );
                      },
                      backgroundColor: colorScheme.primary,
                    ),
                  ],
                ),
              ),
            Expanded(child: _buildTabView(tabIndex)),
          ],
        ),
      ),
    );
  }

  Widget _buildTabView(int index) {
    switch (index) {
      case 0:
        return const InvoiceTableView();
      case 1:
        return const ExpenseTableView();
      case 2:
        return const AccountTableView();
      case 3:
        return const FinanceReportsDashboard();
      default:
        return const SizedBox.shrink();
    }
  }
}
