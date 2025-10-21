import 'package:flutter/material.dart';
import 'package:ppv_components/features/payment_notes/widget/detail_page_header.dart';
import 'package:ppv_components/features/payment_notes/widget/detail_page_widgets/flow_card.dart';
import 'package:ppv_components/features/payment_notes/widget/detail_page_widgets/payment_note_attached_docs.dart';
import 'package:ppv_components/features/payment_notes/widget/detail_page_widgets/payment_note_comments.dart';
import 'package:ppv_components/features/payment_notes/widget/detail_page_widgets/payment_note_summary.dart';
import 'package:ppv_components/features/payment_notes/data/detail_page_mockdb.dart';

class PaymentNoteDetailPage extends StatefulWidget {
  const PaymentNoteDetailPage({super.key});

  @override
  State<PaymentNoteDetailPage> createState() => _PaymentNoteDetailPageState();
}

class _PaymentNoteDetailPageState extends State<PaymentNoteDetailPage> {
  int rowsPerPage = 10;
  int currentPage = 0;
  String searchQuery = '';
  late List attachedDocsFiltered;

  @override
  void initState() {
    super.initState();
    attachedDocsFiltered = List.from(attachedDocsMock);
  }

  void updateSearch(String query) {
    searchQuery = query.toLowerCase();
    _filterDocs();
  }

  void _filterDocs() {
    setState(() {
      attachedDocsFiltered = attachedDocsMock.where((doc) {
        return doc.fileName.toLowerCase().contains(searchQuery);
      }).toList();
      currentPage = 0;
    });
  }

  void changeRowsPerPage(int? value) {
    setState(() {
      rowsPerPage = value ?? 10;
      currentPage = 0;
    });
  }

  void gotoPage(int page) {
    setState(() {
      currentPage = page;
    });
  }

  Future<void> deleteDoc(dynamic doc) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete File'),
        content: Text('Are you sure you want to delete "${doc.fileName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      setState(() {
        attachedDocsMock.remove(doc);
        attachedDocsFiltered.remove(doc);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerHigh,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main content
          Expanded(
            flex: 3,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const PaymentDetailPageHeader(tabIndex: 0),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Payment summary widget
                          PaymentNoteSummary(note: paymentNoteDetailMockData),

                          // Attached documents widget
                          PaymentNoteAttachedDocs(
                            attachedDocsFiltered: attachedDocsFiltered,
                            rowsPerPage: rowsPerPage,
                            currentPage: currentPage,
                            onSearch: updateSearch,
                            onChangeRowsPerPage: changeRowsPerPage,
                            onGotoPage: gotoPage,
                            onDeleteDoc: deleteDoc,
                          ),

                          // Comments widget
                          PaymentNoteComments(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Side Flow card
          SizedBox(
            width: 300,
            child: FlowCard(step: paymentNoteDetailMockData.workflowSteps[0]),
          ),
        ],
      ),
    );
  }
}
