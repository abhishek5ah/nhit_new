import 'package:flutter/material.dart';
import 'package:ppv_components/common_widgets/tabs.dart';
import 'package:ppv_components/features/expense/dart/expense_mockdb.dart';
import 'package:ppv_components/features/expense/model/expense_model.dart';
import 'package:ppv_components/features/expense/widgets/create_expense.dart';
import 'package:ppv_components/features/expense/widgets/expense_approval_main.dart';
import 'package:ppv_components/features/expense/widgets/expense_detail_page.dart';
import 'package:ppv_components/features/expense/widgets/expense_header.dart';
import 'package:ppv_components/features/expense/widgets/expense_table.dart';
class ExpenseMainPage extends StatefulWidget {
  const ExpenseMainPage({super.key});

  @override
  State<ExpenseMainPage> createState() => _ExpenseMainPageState();
}

class _ExpenseMainPageState extends State<ExpenseMainPage> {
  int tabIndex = 0;
  String searchQuery = '';
  late List<GreenNote> filteredNotes;
  List<GreenNote> allNotes = List<GreenNote>.from(dummyGreenNotes);


  @override
  void initState() {
    super.initState();
    filteredNotes = List<GreenNote>.from(allNotes);
  }

  void updateSearch(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
      filteredNotes = allNotes.where((note) {
        final project = note.projectName.toLowerCase();
        final vendor = note.vendorName.toLowerCase();
        final invoice = note.invoiceValue.toLowerCase();
        return project.contains(searchQuery) ||
            vendor.contains(searchQuery) ||
            invoice.contains(searchQuery);
      }).toList();
    });
  }

  void onDeleteNote(GreenNote note) {
    setState(() {
      allNotes.removeWhere((n) => n.sNo == note.sNo);
      updateSearch(searchQuery);
    });
  }

  void onEditNote(GreenNote note) {
    final index = allNotes.indexWhere((n) => n.sNo == note.sNo);
    if (index != -1) {
      setState(() {
        allNotes[index] = note;
        updateSearch(searchQuery);
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
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 12, right: 12),
              child: ExpenseHeader(tabIndex: tabIndex),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: TabsBar(
                      tabs: const ['Expense', 'Create Expense','Approval Rules','Detail'],
                      selectedIndex: tabIndex,
                      onChanged: (idx) => setState(() => tabIndex = idx),
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 250,
                    child: TextField(
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                        hintText: 'Search expenses',
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
              child: Builder(
                builder: (context) {
                  if (tabIndex == 0) {
                    return ExpenseTableView(
                      expenseData: filteredNotes,
                      onDelete: onDeleteNote,
                      onEdit: onEditNote,
                    );
                  } else if (tabIndex == 1) {
                    return const CreateExpense();
                  } else if (tabIndex == 2) {
                    return ExpenseApprovalRule();
                  }else if (tabIndex == 3) {
                    return SupportingDocsPage();
                  } else {
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
