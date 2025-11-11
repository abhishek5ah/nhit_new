import 'package:flutter/material.dart';
import 'package:ppv_components/common_widgets/tabs.dart';
import 'package:ppv_components/features/payment_notes/data/approval_mockdb.dart';
import 'package:ppv_components/features/payment_notes/data/payment_notes_mockdb.dart';
import 'package:ppv_components/features/payment_notes/model/approval_model.dart';
import 'package:ppv_components/features/payment_notes/model/payment_notes_model.dart';
import 'package:ppv_components/features/payment_notes/widget/approval_table.dart';
import 'package:ppv_components/features/payment_notes/widget/payment_header.dart';
import 'package:ppv_components/features/payment_notes/widget/payment_table.dart';

class PaymentMainPage extends StatefulWidget {
  const PaymentMainPage({super.key});

  @override
  State<PaymentMainPage> createState() => _PaymentMainPageState();
}

class _PaymentMainPageState extends State<PaymentMainPage> {
  int tabIndex = 0;
  String searchQuery = '';
  late List<PaymentNote> filteredPayments;
  late List<ApproverRule> filteredApprovals;
  List<ApproverRule> allApprovals = List<ApproverRule>.from(approverRuleMockDB);
  List<PaymentNote> allPayments = List<PaymentNote>.from(paymentNoteData);

  @override
  void initState() {
    super.initState();
    filteredPayments = List<PaymentNote>.from(allPayments);
    filteredApprovals = List<ApproverRule>.from(allApprovals);
  }

  void updateSearch(String query) {
    searchQuery = query.toLowerCase();
    if (tabIndex == 0) {
      _filterPayments();
    } else if (tabIndex == 1) {
      _filterApprovals();
    }
  }

  void _filterPayments() {
    List<PaymentNote> filtered = allPayments.where((payment) {
      bool searchMatches = payment.projectName.toLowerCase().contains(searchQuery) ||
          payment.vendorName.toLowerCase().contains(searchQuery) ||
          payment.status.toLowerCase().contains(searchQuery);

      return searchMatches;
    }).toList();

    setState(() {
      filteredPayments = filtered;
    });
  }

  void onDeletePayment(PaymentNote payment) {
    setState(() {
      allPayments.removeWhere((p) => p.sno == payment.sno);
      _filterPayments();
    });
  }

  void onTabChanged(int idx) {
    setState(() {
      tabIndex = idx;
      searchQuery = '';
      if (tabIndex == 0) {
        _filterPayments();
      } else if (tabIndex == 1) {
        _filterApprovals();
      }
    });
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
              padding: const EdgeInsets.only(left: 12, bottom: 12, right: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PaymentHeader(tabIndex: tabIndex),
                  const SizedBox(height: 12),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: TabsBar(
                      tabs: const ['All Payments', 'Approval Notes'],
                      selectedIndex: tabIndex,
                      onChanged: onTabChanged,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 250,
                    child: TextField(
                      decoration: InputDecoration(
                        contentPadding:
                        const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                        hintText: tabIndex == 0 ? 'Search payments' : 'Search approvals',
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

            Expanded(
              child: tabIndex == 0
                  ? PaymentTableView(
                paymentData: filteredPayments,
                onDelete: onDeletePayment,
              )
                  : ApprovalTableView(
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
