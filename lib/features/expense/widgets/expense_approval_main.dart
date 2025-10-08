import 'package:flutter/material.dart';
import 'package:ppv_components/features/expense/widgets/approval_rule_form.dart';
import 'package:ppv_components/features/expense/widgets/approval_rules.dart';

class ExpenseApprovalRule extends StatelessWidget {
  const ExpenseApprovalRule({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1800),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: const [
                  ApprovalRulesForm(),
                  SizedBox(height: 30),
                  ApprovalRulesTablePage(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
