import 'package:flutter/material.dart';
import 'package:ppv_components/core/utils/responsive.dart';
import 'package:ppv_components/core/utils/status_utils.dart';
import 'package:ppv_components/common_widgets/profile_card.dart';
import 'package:ppv_components/features/finance/data/mock_expense_db.dart';

class ExpenseGrid extends StatefulWidget {
  const ExpenseGrid({super.key});

  @override
  State<ExpenseGrid> createState() => _ExpenseGridState();
}

class _ExpenseGridState extends State<ExpenseGrid> {
  int? _hoveredCardIndex; // Track hovered card index

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = getResponsiveCrossAxisCount(screenWidth);

    return Scaffold(
      backgroundColor: colorScheme.primaryContainer,
      body: Column( // Added Column to wrap Expanded, similar to invoice_grid.dart
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded( // Wrapped GridView.builder in an Expanded widget
            child: GridView.builder(
              itemCount: mockExpenses.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: 1.3,
              ),
              itemBuilder: (context, index) {
                final expense = mockExpenses[index];
                final isHovered = _hoveredCardIndex == index;

                return MouseRegion(
                  onEnter: (_) => setState(() => _hoveredCardIndex = index),
                  onExit: (_) => setState(() => _hoveredCardIndex = null),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 4), // Changed from 6 to 4 for consistency
                    decoration: BoxDecoration(
                      border: isHovered
                          ? Border(
                        top: BorderSide(
                          color: getStatusColor(expense.status),
                          width: 6,
                        ),
                        left: BorderSide(
                          color: getStatusColor(expense.status),
                          width: 6,
                        ),
                      )
                          : Border.all(color: Colors.transparent, width: 6),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(18),
                        bottomLeft: Radius.circular(18),
                      ),
                    ),
                    child: ProfileInfoCard(
                      title: expense.id,
                      company: expense.vendor,
                      email: expense.category,
                      phone: expense.date,
                      source: expense.amount,
                      topBarColor: getStatusColor(expense.status),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}