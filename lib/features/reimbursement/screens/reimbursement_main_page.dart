import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:ppv_components/common_widgets/tabs.dart';
import 'package:ppv_components/features/reimbursement/widget/create_reimbursement_form%20.dart';
import 'package:ppv_components/features/reimbursement/widget/reimbursement_detail_page.dart';
import 'package:ppv_components/features/reimbursement/widget/reimbursement_header.dart';
import 'package:ppv_components/features/reimbursement/widget/reimbursement_table_page.dart';


class ReimbursementMainPage extends StatefulWidget {
  const ReimbursementMainPage({super.key});

  @override
  State<ReimbursementMainPage> createState() => _ReimbursementMainPageState();
}

class _ReimbursementMainPageState extends State<ReimbursementMainPage> {
  int tabIndex = 0;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    // initialize reimbursement data here if you have any
  }

  void updateSearch(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
      // If you have a list of reimbursements, filter it here using searchQuery
      // e.g. filtered = allReimb.where(...).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // central tabs list (single source of truth)
    final List<String> tabs = const [
      'Reimbursements',
      'Add Reimbursement',
      'Approval Rules',
    ];

    // clamp the tabIndex used for rendering so it never goes out of range
    final int safeTabIndex = (tabIndex.clamp(0, math.max(0, tabs.length - 1))).toInt();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // header
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 12, right: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  ReimbursementHeader(tabIndex: safeTabIndex),
                  const SizedBox(height: 12),
                ],
              ),
            ),

            // tabs + search
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: TabsBar(
                      tabs: tabs,
                      selectedIndex: safeTabIndex,
                      onChanged: (idx) {
                        final int newIndex = (idx.clamp(0, math.max(0, tabs.length - 1))).toInt();
                        setState(() => tabIndex = newIndex);
                      },
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 250,
                    child: TextField(
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                        hintText: 'Search reimbursements',
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



            // body: handle all tabs explicitly using safeTabIndex
            Expanded(
              child: Builder(
                builder: (_) {
                  switch (safeTabIndex) {
                    case 0:
                    // show reimbursement table (create ReimbursementTablePage accordingly)
                      return const ReimbursementTablePage();
                    case 1:
                    // page to create a reimbursement
                      return ReimbursementForm();
                    case 2:
                    // reuse approval rules combined page
                      return const ReimbursementDetailPage();
                    default:
                      return const SizedBox.shrink();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
