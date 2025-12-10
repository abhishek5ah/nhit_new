import 'package:flutter/material.dart';
import 'package:ppv_components/common_widgets/button/primary_button.dart';
import 'package:go_router/go_router.dart';
import 'package:ppv_components/features/approval_management/models/approval_rule_model.dart';
import 'package:ppv_components/features/approval_management/data/approval_rule_dummy.dart';
import 'package:ppv_components/features/approval_management/widgets/approval_rules_table.dart';
import 'package:ppv_components/features/approval_management/widgets/view_approval_rule_detail.dart';
import 'package:ppv_components/features/approval_management/widgets/edit_approval_rule_content.dart';

class ApprovalRulesManagementPage extends StatefulWidget {
  final String ruleType; // 'green_note', 'payment_note', 'reimbursement_note', 'bank_letter'

  const ApprovalRulesManagementPage({super.key, required this.ruleType});

  @override
  State<ApprovalRulesManagementPage> createState() =>
      _ApprovalRulesManagementPageState();
}

class _ApprovalRulesManagementPageState
    extends State<ApprovalRulesManagementPage> {
  List<ApprovalRule> allRules = List<ApprovalRule>.from(approvalRulesDummyData);
  
  // Edit and View mode state
  bool _isEditMode = false;
  ApprovalRule? _ruleToEdit;

  String get ruleTypeTitleShort {
    switch (widget.ruleType) {
      case 'green_note':
        return 'Expense note';
      case 'payment_note':
        return 'Payment note';
      case 'reimbursement_note':
        return 'Reimbursement note';
      case 'bank_letter':
        return 'Bank letter';
      default:
        return 'Approval';
    }
  }

  // Calculate statistics
  int get totalRules => allRules.length;
  int get activeRules => allRules.where((r) => r.status == 'Active').length;
  int get inactiveRules => allRules.where((r) => r.status == 'Inactive').length;
  double get avgApprovers => allRules.isEmpty
      ? 0
      : allRules.map((r) => r.approvers).reduce((a, b) => a + b) /
            allRules.length;

  void onViewRule(ApprovalRule rule) {
    setState(() {
      _isEditMode = false;
      _ruleToEdit = rule;
    });
  }

  void onEditRule(ApprovalRule rule) {
    setState(() {
      _isEditMode = true;
      _ruleToEdit = rule;
    });
  }

  void _saveEditedRule(ApprovalRule updatedRule) {
    final index = allRules.indexWhere((r) => r.id == _ruleToEdit!.id);
    if (index != -1) {
      setState(() {
        allRules[index] = updatedRule;
        _isEditMode = false;
        _ruleToEdit = null;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rule updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _cancelEdit() {
    setState(() {
      _isEditMode = false;
      _ruleToEdit = null;
    });
  }

  void onDeleteRule(ApprovalRule rule) {
    setState(() {
      allRules.removeWhere((r) => r.id == rule.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: _ruleToEdit != null
          ? (_isEditMode
              ? EditApprovalRuleContent(
                  rule: _ruleToEdit!,
                  onSave: _saveEditedRule,
                  onCancel: _cancelEdit,
                )
              : ViewApprovalRuleDetail(
                  rule: _ruleToEdit!,
                  onClose: _cancelEdit,
                ))
          : LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Section (Create Escrow Page Style)
                        _buildHeader(context, constraints),
                        const SizedBox(height: 24),

                        // Table Section (Bank Letter Page Style)
                        SizedBox(
                          height: 600,
                          child: ApprovalRulesTable(
                            rulesData: allRules,
                            title: 'Approval Rules for ${ruleTypeTitleShort[0].toUpperCase()}${ruleTypeTitleShort.substring(1)}',
                            onView: onViewRule,
                            onEdit: onEditRule,
                            onDelete: onDeleteRule,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildHeader(BuildContext context, BoxConstraints constraints) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final isSmallScreen = constraints.maxWidth < 600;

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline,
          width: 0.5,
        ),
      ),
      child: isSmallScreen
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.rule_folder,
                        size: 24,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Approval Rules - ${ruleTypeTitleShort[0].toUpperCase()}${ruleTypeTitleShort.substring(1)}',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Manage approval rules and workflows for ${ruleTypeTitleShort}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                PrimaryButton(
                  label: 'Create New Rule',
                  icon: Icons.add_circle,
                  onPressed: () {
                    final type = widget.ruleType;
                    context.go('/approval-rules/$type/create');
                  },
                  backgroundColor: Colors.green,
                ),
              ],
            )
          : Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.rule_folder,
                    size: 28,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Approval Rules - ${ruleTypeTitleShort[0].toUpperCase()}${ruleTypeTitleShort.substring(1)}',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Manage approval rules and workflows for ${ruleTypeTitleShort}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                PrimaryButton(
                  label: 'Create New Rule',
                  icon: Icons.add_circle,
                  onPressed: () {
                    final type = widget.ruleType;
                    context.go('/approval-rules/$type/create');
                  },
                  backgroundColor: Colors.green,
                ),
              ],
            ),
    );
  }

}
