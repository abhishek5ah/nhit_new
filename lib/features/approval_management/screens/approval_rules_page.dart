import 'package:flutter/material.dart';
import 'package:ppv_components/common_widgets/custom_table.dart';
import 'package:ppv_components/common_widgets/dropdown.dart';

class ApprovalRulesPage extends StatefulWidget {
  const ApprovalRulesPage({super.key});

  @override
  State<ApprovalRulesPage> createState() => _ApprovalRulesPageState();
}

class _ApprovalRulesPageState extends State<ApprovalRulesPage> {
  String? selectedFeatureType;
  
  final List<String> featureTypes = [
    'Expense Note',
    'Payment Note',
    'Bank Letter',
  ];

  // Mock data for the table
  final List<Map<String, dynamic>> mockData = [
    {
      'featureType': 'Expense Note',
      'totalRules': 12,
      'activeRules': 10,
      'avgApprovers': 3,
      'lastUpdated': '2024-01-15',
    },
    {
      'featureType': 'Payment Note',
      'totalRules': 8,
      'activeRules': 7,
      'avgApprovers': 4,
      'lastUpdated': '2024-01-10',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Row(
              children: [
                Icon(
                  Icons.rule,
                  size: 32,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Approval Rules',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Home / Approval Rules',
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),

            // Select Feature Type Section
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.3),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.layers,
                        size: 20,
                        color: colorScheme.onSurface,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Select Feature Type',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose the feature you want to manage approval rules for',
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: CustomDropdown(
                          value: selectedFeatureType,
                          items: featureTypes,
                          hint: 'Select Feature Type...',
                          onChanged: (value) {
                            setState(() {
                              selectedFeatureType = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Feature Comparison Table Section
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.compare_arrows,
                      color: colorScheme.onPrimary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Feature Comparison',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Table
            Expanded(
              child: CustomTable(
                columns: [
                  DataColumn(
                    label: Text(
                      'FEATURE TYPE',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'TOTAL RULES',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'ACTIVE RULES',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'AVG APPROVERS',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'LAST UPDATED',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'ACTIONS',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
                rows: mockData.map((item) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Text(
                          item['featureType'],
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          item['totalRules'].toString(),
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          item['activeRules'].toString(),
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          item['avgApprovers'].toString(),
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          item['lastUpdated'],
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      DataCell(
                        Container(
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.arrow_forward,
                              color: colorScheme.onPrimary,
                              size: 18,
                            ),
                            onPressed: () {
                              // Navigate to specific feature rules
                            },
                            tooltip: 'View Details',
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
                minTableWidth: 1000,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
