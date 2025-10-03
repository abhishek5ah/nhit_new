import 'package:flutter/material.dart';
import 'package:ppv_components/common_widgets/tabs.dart';
import 'package:ppv_components/features/payment_notes/data/approval_mockdb.dart';
import 'package:ppv_components/features/payment_notes/model/approval_model.dart';
import 'package:ppv_components/features/payment_notes/widget/approval_table.dart';

class ApprovalMainPage extends StatefulWidget {
  const ApprovalMainPage({super.key});

  @override
  State<ApprovalMainPage> createState() => _ApprovalMainPageState();
}

class _ApprovalMainPageState extends State<ApprovalMainPage> {
  int tabIndex = 0;
  String searchQuery = '';
  late List<ApproverRule> filteredApprovals;
  List<ApproverRule> allApprovals = List<ApproverRule>.from(approverRuleMockDB);

  @override
  void initState() {
    super.initState();
    filteredApprovals = List<ApproverRule>.from(allApprovals);
  }

  void updateSearch(String query) {
    searchQuery = query.toLowerCase();
    _filterApprovals();
  }

  void _filterApprovals() {
    List<ApproverRule> filtered = allApprovals.where((approval) {
      bool searchMatches = approval.approverLevel.toLowerCase().contains(searchQuery) ||
          approval.paymentRange.toLowerCase().contains(searchQuery) ||
          approval.users.any((user) => user.toLowerCase().contains(searchQuery));

      return searchMatches;
    }).toList();

    setState(() {
      filteredApprovals = filtered;
    });
  }

  void onDeleteApproval(ApproverRule approval) {
    setState(() {
      allApprovals.removeWhere((a) =>
      a.approverLevel == approval.approverLevel &&
          a.paymentRange == approval.paymentRange);
      _filterApprovals();
    });
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
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: TabsBar(
                      tabs: const ['All'],
                      selectedIndex: tabIndex,
                      onChanged: (idx) {
                      },
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 250,
                    child: TextField(
                      decoration: InputDecoration(
                        contentPadding:
                        const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                        hintText: 'Search approvals',
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
            const SizedBox(height: 14),
            Expanded(
              child: ApprovalTableView(
                approvalData: filteredApprovals,
                onDelete: onDeleteApproval,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
