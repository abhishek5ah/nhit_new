import 'package:flutter/material.dart';
import 'package:ppv_components/common_widgets/tabs.dart';
import 'package:ppv_components/features/bank_rtgs_neft/data/bank_dummydata/bank_rtgs_neft_dummy.dart';
import 'package:ppv_components/features/bank_rtgs_neft/models/bank_models/bank_rtgs_neft_model.dart';
import 'package:ppv_components/features/bank_rtgs_neft/widget/approval_flow_page.dart';
import 'package:ppv_components/features/bank_rtgs_neft/widget/approval_table.dart';
import 'package:ppv_components/features/bank_rtgs_neft/widget/bank_header.dart';
import 'package:ppv_components/features/bank_rtgs_neft/widget/bank_rtgs_neft_form_page.dart';
import 'package:ppv_components/features/bank_rtgs_neft/widget/rtgs_table_page.dart';
import 'package:ppv_components/features/payment_notes/widget/approval_table.dart';
import 'package:ppv_components/features/bank_rtgs_neft/models/bank_models/bank_letter_approval_rules_model.dart';
import 'package:ppv_components/features/bank_rtgs_neft/data/bank_dummydata/bank_letter_approval_rules_dummy.dart';

class BankMainPage extends StatefulWidget {
  const BankMainPage({super.key});

  @override
  State<BankMainPage> createState() => _BankMainPageState();
}

class _BankMainPageState extends State<BankMainPage> {
  int tabIndex = 0;
  String searchQuery = '';
  late List<BankRtgsNeft> filteredAccounts;
  List<BankRtgsNeft> allAccounts = List<BankRtgsNeft>.from(
    bankRtgsNeftDummyData,
  );

  // Approval rules list from your dummy data
  List<BankLetterApprovalRule> approvalData = List<BankLetterApprovalRule>.from(
    bankLetterApprovalRulesDummyData,
  );

  @override
  void initState() {
    super.initState();
    filteredAccounts = List<BankRtgsNeft>.from(allAccounts);
  }

  void updateSearch(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
      filteredAccounts = allAccounts.where((account) {
        final slNo = account.slNo.toLowerCase();
        final vendor = account.vendorName.toLowerCase();
        final amount = account.amount.toLowerCase();
        final status = account.status.toLowerCase();
        final date = account.date.toLowerCase();
        return slNo.contains(searchQuery) ||
            vendor.contains(searchQuery) ||
            amount.contains(searchQuery) ||
            status.contains(searchQuery) ||
            date.contains(searchQuery);
      }).toList();
    });
  }

  void onDeleteAccount(BankRtgsNeft account) {
    setState(() {
      allAccounts.removeWhere((a) => a.id == account.id);
      updateSearch(searchQuery);
    });
  }

  void onEditAccount(BankRtgsNeft updated) {
    final idx = allAccounts.indexWhere((a) => a.id == updated.id);
    if (idx != -1) {
      setState(() {
        allAccounts[idx] = updated;
        updateSearch(searchQuery);
      });
    }
  }

  // Approval Rules callbacks
  void onDeleteApprovalRule(BankLetterApprovalRule rule) {
    setState(() {
      approvalData.removeWhere((r) => r.id == rule.id);
    });
  }

  void onEditApprovalRule(BankLetterApprovalRule updatedRule) {
    final idx = approvalData.indexWhere((r) => r.id == updatedRule.id);
    if (idx != -1) {
      setState(() {
        approvalData[idx] = updatedRule;
      });
    }
  }

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
            // ===== Header =====
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 12, right: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BankHeader(tabIndex: tabIndex), // auto updates title/subtitle
                  const SizedBox(height: 12),
                ],
              ),
            ),

            // ===== Tabs + Search =====
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: TabsBar(
                      tabs: const [
                        'RTGS/NEFT',
                        'New RTGS/NEFT',
                        'Approval Rules',
                        'Approval Flow',
                      ],
                      selectedIndex: tabIndex,
                      onChanged: (idx) => setState(() => tabIndex = idx),
                    ),
                  ),
                  const Spacer(),
                  if (tabIndex == 0) //  search only for list
                    SizedBox(
                      width: 250,
                      child: TextField(
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 12,
                          ),
                          hintText: 'Search RTGS/NEFT',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(
                              color: colorScheme.outline,
                              width: 0.25,
                            ),
                          ),
                          isDense: true,
                        ),
                        onChanged: updateSearch,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),


            // ===== Body =====
            Expanded(child: _buildTabContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (tabIndex) {
      case 0:
        return RtgsTableView(
          rtgsData: filteredAccounts,
          onDelete: (account) async {
            onDeleteAccount(account);
          },
          onEdit: (updated) async {
            onEditAccount(updated);
          },
        );
      case 1:
        return const BankRtgsNeftPage();

      case 2:
        return ApprovalRuleTableView(
          approvalRules: approvalData,
          onEdit: onEditApprovalRule,
        );

      case 3:
        return const ApprovalFlowPage();

      default:
        return const SizedBox.shrink();
    }
  }
}
