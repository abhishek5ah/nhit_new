// account_table.dart (partial update)
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ppv_components/common_widgets/button/toggle_button.dart';
import 'package:ppv_components/common_widgets/custom_table.dart';
import 'package:ppv_components/core/utils/account_status_colors.dart';
import 'package:ppv_components/features/finance/data/mock_account_db.dart';
import 'package:ppv_components/features/finance/screens/accounts/account_grid.dart';

class AccountTableView extends StatefulWidget {
  const AccountTableView({super.key});

  @override
  State<AccountTableView> createState() => _AccountTableViewState();
}

class _AccountTableViewState extends State<AccountTableView> {
  int toggleIndex = 0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final columns = [
      DataColumn(
        label: Text('Code', style: TextStyle(color: colorScheme.onSurface)),
      ),
      DataColumn(
        label: Text('Name', style: TextStyle(color: colorScheme.onSurface)),
      ),
      DataColumn(
        label: Text('Type', style: TextStyle(color: colorScheme.onSurface)),
      ),
      DataColumn(
        label: Text('Balance', style: TextStyle(color: colorScheme.onSurface)),
      ),
      DataColumn(
        label: Text('Actions', style: TextStyle(color: colorScheme.onSurface)),
      ),
    ];

    final rows = mockAccounts.map((account) {
      return DataRow(
        cells: [
          DataCell(
            Text(account.code, style: TextStyle(color: colorScheme.onSurface)),
          ),
          DataCell(
            Text(account.name, style: TextStyle(color: colorScheme.onSurface)),
          ),
          DataCell(
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
              decoration: BoxDecoration(
                color: getAccountTypeColor(account.type),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                account.type,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          DataCell(
            Text(
              account.balance, // Now using the balance field from AccountModel
              style: TextStyle(color: colorScheme.onSurface),
            ),
          ),
          DataCell(
            OutlinedButton(
              onPressed: () {
                print('Navigating to account detail with id: ${account.code}');

                context.go('/finance/account/${account.code}');
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: colorScheme.outline.withAlpha(77),
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
                                'Chart of Accounts',
                                style: TextStyle(
                                  color: colorScheme.onSurface,
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Manage your financial accounts',
                                style: TextStyle(
                                  color: colorScheme.onSurface.withOpacity(0.65),
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ToggleBtn(
                          labels: const ['Table Form', 'Grid Form'],
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
                          : AccountGridView(),
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