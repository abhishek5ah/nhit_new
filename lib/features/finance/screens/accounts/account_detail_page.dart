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

    final colorScheme = Theme.of(context).colorScheme;
    final remaining = _calculateRemainingBalance(account.totalBalance, account.spendBalance);

    return Scaffold(
      appBar: AppBar(title: const Text('Account Detail'), elevation: 1),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Flex(
              direction: isWide ? Axis.horizontal : Axis.vertical,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  flex: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: colorScheme.outline,
                        width: 0.25,
                      ),
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Account Info',
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _infoRow('Name:', account.name, colorScheme),
                        _infoRow('Balance:', account.balance, colorScheme),
                        _infoRow('Type:', account.type, colorScheme),
                        _infoRow('Total Balance:', account.totalBalance, colorScheme),
                        _infoRow('Spend Balance:', account.spendBalance, colorScheme),
                        _infoRow('Remaining Balance:', remaining, colorScheme),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: isWide ? 32 : 0, height: isWide ? 0 : 32),
                Flexible(
                  flex: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: colorScheme.outline,
                        width: 0.25,
                      ),
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'View History',
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 300,
                          child: Scrollbar(
                            thumbVisibility: true,
                            child: ListView(
                              children: const [
                                ListTile(
                                  title: Text('Transaction on 2025-09-01'),
                                  subtitle: Text('Debit \$1,000'),
                                ),
                                ListTile(
                                  title: Text('Transaction on 2025-08-15'),
                                  subtitle: Text('Credit \$500'),
                                ),
                                ListTile(
                                  title: Text('Transaction on 2025-07-30'),
                                  subtitle: Text('Debit \$1,500'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _calculateRemainingBalance(String total, String spend) {
    double parseAmount(String amount) {
      // Remove all non-numeric except decimal points and minus sign
      final cleaned = amount.replaceAll(RegExp(r'[^\d\.\-]'), '');
      return double.tryParse(cleaned) ?? 0.0;
    }

    final totalVal = parseAmount(total);
    final spendVal = parseAmount(spend);

    final remainingVal = totalVal - spendVal;

    // Format as currency with two decimals
    return '\$${remainingVal.toStringAsFixed(2)}';
  }

  Widget _infoRow(String label, String value, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? 'N/A' : value,
              textAlign: TextAlign.right,
              style: TextStyle(color: colorScheme.onSurface, fontSize: 18),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
