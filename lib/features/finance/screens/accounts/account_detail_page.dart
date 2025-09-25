import 'package:flutter/material.dart';
import 'package:ppv_components/features/finance/data/mock_account_db.dart';
import 'package:ppv_components/features/finance/model/account_model.dart';

class AccountDetailPage extends StatelessWidget {
  final String accountId;

  const AccountDetailPage({super.key, required this.accountId});

  @override
  Widget build(BuildContext context) {
    final Account account = mockAccounts.firstWhere(
      (acc) => acc.code == accountId,
      orElse: () => Account(
        code: '',
        name: '',
        type: '',
        balance: '',
        totalBalance: '',
        spendBalance: '',
      ),
    );

    final transactions = mockAccounts;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Account Details'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 650) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAccountCard(account, colorScheme),
                  const SizedBox(height: 20),
                  _buildHistoryCard(transactions, colorScheme),
                ],
              ),
            );
          } else {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: _buildAccountCard(account, colorScheme),
                  ),
                  const SizedBox(width: 28),
                  Expanded(
                    flex: 1,
                    child: _buildHistoryCard(transactions, colorScheme),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildAccountCard(Account account, ColorScheme colorScheme) {
    TextStyle labelStyle = TextStyle(fontWeight: FontWeight.w700, fontSize: 16);
    TextStyle valueStyle = TextStyle(fontWeight: FontWeight.w500, fontSize: 16);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      color: colorScheme.surfaceContainer,
      child: Container(
        padding: const EdgeInsets.fromLTRB(28, 34, 28, 34),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Account Info',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 24,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 26),
            Row(
              children: [
                Text('Name:', style: labelStyle),
                const SizedBox(width: 16),
                Text(account.name, style: valueStyle),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text('Type:', style: labelStyle),
                const SizedBox(width: 16),
                Text(account.type, style: valueStyle),
              ],
            ),
            const Divider(height: 32, color: Colors.white24),
            Row(
              children: [
                Text('Balance:', style: labelStyle),
                const SizedBox(width: 16),
                Text(
                  account.balance.isEmpty ? '\$0.00' : account.balance,
                  style: valueStyle.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 19,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text('Spend Balance:', style: labelStyle),
                const SizedBox(width: 16),
                Text(
                  account.spendBalance.isEmpty
                      ? '\$0.00'
                      : account.spendBalance,
                  style: valueStyle,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text('Total Balance:', style: labelStyle),
                const SizedBox(width: 16),
                Text(
                  account.totalBalance.isEmpty
                      ? '\$0.00'
                      : account.totalBalance,
                  style: valueStyle,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard(
    List<Account> transactions,
    ColorScheme colorScheme,
  ) {
    TextStyle headerStyle = TextStyle(
      fontWeight: FontWeight.w800,
      fontSize: 24,
    );
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      color: colorScheme.surfaceContainer,
      child: Container(
        padding: const EdgeInsets.fromLTRB(28, 34, 28, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('View History', style: headerStyle),
            const SizedBox(height: 28),
            ...transactions.take(5).map((tx) {
              final isCredit = tx.type.toLowerCase() == 'asset';
              final amountColor = colorScheme.primary;
              final circleColor = colorScheme.tertiaryContainer;
              return Container(
                margin: const EdgeInsets.only(bottom: 18),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: circleColor,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          isCredit
                              ? Icons.arrow_downward_rounded
                              : Icons.arrow_upward_rounded,
                          color: amountColor,
                          size: 25,
                        ),
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tx.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 17,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Text(
                                isCredit ? 'Credit' : 'Debit',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                  color: amountColor,
                                ),
                              ),
                              Text(
                                ' ${tx.balance}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color: amountColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
