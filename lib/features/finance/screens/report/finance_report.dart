import 'package:flutter/material.dart';
import 'package:ppv_components/features/finance/data/finance_report/financial_report.dart';
import 'package:ppv_components/features/finance/data/finance_report/report_summary_card_db.dart';
import 'package:ppv_components/features/finance/screens/report/widgets/summary_card.dart';

class FinanceReportsDashboard extends StatelessWidget {
  const FinanceReportsDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final cardBg = colorScheme.surfaceContainer;
    final outline = colorScheme.outline.withValues(alpha:0.33);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmall = constraints.maxWidth < 800;
        final isMedium = constraints.maxWidth < 1200;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flex(
                direction: isSmall ? Axis.vertical : Axis.horizontal,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: isSmall ? CrossAxisAlignment.stretch : CrossAxisAlignment.start,
                children: [
                  for (int i = 0; i < mockSummaryCards.length; i++) ...[
                    if (i != 0)
                      SizedBox(width: isSmall ? 0 : 28, height: isSmall ? 28 : 0),
                    SummaryCard(
                      title: mockSummaryCards[i].title,
                      value: mockSummaryCards[i].value,
                      subtext: mockSummaryCards[i].subtext,
                      onView: () {/* TODO: handle view */},
                      colorScheme: colorScheme,
                      background: cardBg,
                      outline: outline,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 36),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: outline),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 22, top: 22, right: 22, bottom: 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Financial Reports",
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            "Access detailed financial reports",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface.withValues(alpha:0.6),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    ..._financialReportRows(colorScheme, isMedium),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  static List<Widget> _financialReportRows(ColorScheme colorScheme, bool isMedium) {
    return [
      for (int i = 0; i < mockFinancialReports.length; i++) ...[
        if (i != 0) const Divider(height: 1),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 22, vertical: isMedium ? 18 : 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mockFinancialReports[i].title,
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      mockFinancialReports[i].description,
                      style: TextStyle(
                        color: colorScheme.onSurface.withValues(alpha:0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.onSurface,
                  side: BorderSide(
                    color: colorScheme.outline.withValues(alpha:0.4),
                    width: 1.4,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 11),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  // TODO: handle report generation
                },
                child: const Text("Generate"),
              )
            ],
          ),
        )
      ],
    ];
  }
}
