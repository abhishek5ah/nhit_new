import 'package:flutter/material.dart';
import 'package:ppv_components/common_widgets/custom_table.dart';
import 'package:ppv_components/features/payment_notes/data/detail_page_mockdb.dart';
import 'package:ppv_components/features/payment_notes/widget/detail_page_header.dart';

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

  List<DataRow> _buildRows() {
    final colorScheme = Theme.of(context).colorScheme;
    int start = currentPage * rowsPerPage;
    int end = (start + rowsPerPage).clamp(0, attachedDocsFiltered.length);
    final pageItems = attachedDocsFiltered.sublist(start, end);
    return pageItems.map<DataRow>((doc) {
      return DataRow(
        cells: [
          DataCell(
            Text(
              doc.sno.toString(),
              style: TextStyle(color: colorScheme.onSurface),
            ),
          ),
          DataCell(
            Text(doc.fileName, style: TextStyle(color: colorScheme.onSurface)),
          ),
          DataCell(Icon(Icons.insert_drive_file, color: colorScheme.primary)),
          DataCell(
            Text(
              doc.uploadDate,
              style: TextStyle(color: colorScheme.onSurface),
            ),
          ),
          DataCell(
            Text(
              doc.uploadedBy,
              style: TextStyle(color: colorScheme.onSurface),
            ),
          ),
          DataCell(
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.download_rounded, size: 20),
                  onPressed: () {},
                  splashRadius: 18,
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  onPressed: () => deleteDoc(doc),
                  splashRadius: 18,
                ),
              ],
            ),
          ),
        ],
      );
    }).toList();
  }

  Widget _buildSummaryTable(BuildContext context) {
    final note = paymentNoteDetailMockData;
    final colorScheme = Theme.of(context).colorScheme;
    return Table(
      border: TableBorder.all(color: colorScheme.outline, width: 1),
      columnWidths: const {0: FlexColumnWidth(3), 1: FlexColumnWidth(2)},
      children: [
        TableRow(
          decoration: BoxDecoration(color: colorScheme.surfaceContainer),
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Particulars',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Payable Amount',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        _buildSummaryTableRow(
          'Taxable Amount',
          note.paymentSummary.taxableAmount,
        ),
        _buildSummaryTableRow('Add : GST', note.paymentSummary.gst),
        _buildSummaryTableRow(
          'Add: Other charges',
          note.paymentSummary.otherCharges,
        ),
        _buildSummaryTableRow('Gross Amount', note.paymentSummary.grossAmount),
        _buildSummaryTableRow(
          'Less: TDS @ 2% U/s 194C',
          note.paymentSummary.tds,
        ),
        _buildSummaryTableRow(
          'Net Payable Amount',
          note.paymentSummary.netPayableAmount,
        ),
        _buildSummaryTableRow(
          'Net Payable Amount (Round Off)',
          note.paymentSummary.netPayableAmountRoundOff,
        ),
      ],
    );
  }

  TableRow _buildSummaryTableRow(String key, String value) {
    return TableRow(
      children: [
        Padding(padding: const EdgeInsets.all(8.0), child: Text(key)),
        Padding(padding: const EdgeInsets.all(8.0), child: Text(value)),
      ],
    );
  }

  Widget _buildAttachedDocsSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final columns = [
      DataColumn(
        label: Text(
          'S no.',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      DataColumn(
        label: Text(
          'File name',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      DataColumn(
        label: Text(
          'File',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      DataColumn(
        label: Text(
          'Upload Date',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      DataColumn(
        label: Text(
          'Uploaded By',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      DataColumn(
        label: Text(
          'Action',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ];
    int startItem = attachedDocsFiltered.isEmpty
        ? 0
        : currentPage * rowsPerPage + 1;
    int endItem = (currentPage * rowsPerPage + rowsPerPage).clamp(
      0,
      attachedDocsFiltered.length,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(height: 12),
        const SizedBox(height: 32),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Attached Supporting Docs',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {},
              child: const Text('View Green Note'),
            ),
            const Spacer(),
            SizedBox(
              width: 250,
              child: TextField(
                onChanged: updateSearch,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 12,
                  ),
                  hintText: 'Search files',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  prefixIcon: const Icon(Icons.search),
                  isDense: true,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            DropdownButton<int>(
              value: rowsPerPage,
              items: [5, 10, 20, 50]
                  .map(
                    (e) =>
                        DropdownMenuItem(value: e, child: Text('$e entries')),
                  )
                  .toList(),
              onChanged: changeRowsPerPage,
            ),
            Text(
              'Showing $startItem to $endItem of ${attachedDocsFiltered.length} entries',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: 12),
        CustomTable(columns: columns, rows: _buildRows()),
      ],
    );
  }

  Widget _buildCommentSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 30, bottom: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colorScheme.outline.withValues(alpha: 0.06),
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Comments (0)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextField(
              minLines: 2,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Write a comment...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                isDense: true,
              ),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size(120, 38)),
              onPressed: () {},
              child: const Text('Add Comment'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlowCard(BuildContext context) {
    final note = paymentNoteDetailMockData;
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(18),
      margin: const EdgeInsets.only(top: 24, right: 12, left:12, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Flow', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          SizedBox(
            height: 220,
            child: ListView.builder(
              itemCount: note.workflowSteps.length,
              itemBuilder: (context, index) {
                final flow = note.workflowSteps[index];
                bool isLast = index == note.workflowSteps.length - 1;
                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Process bar with dot and connecting vertical line
                      Container(
                        width: 24,
                        child: Column(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            if (!isLast)
                              Expanded(
                                child: Container(
                                  width: 2,
                                  color: colorScheme.primary
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Step details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Step ${flow.step}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Maker: ${flow.makerName}',
                              style: theme.textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 2),
                            Container(
                              decoration: BoxDecoration(
                                color: colorScheme.primary.withValues(
                                  alpha: 0.08,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              child: Text(
                                flow.status,
                                style: TextStyle(
                                  color: colorScheme.primary,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              flow.dateTime,
                              style: theme.textTheme.bodySmall,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Next Approver: ${flow.nextApprover}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main scrollable content in the left side
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
                      color: colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // All original main content
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Left main content expanded to fixed width for predictable width inside horizontal scroll
                                SizedBox(
                                  width: 1200,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Payment Note (${paymentNoteDetailMockData.paymentNoteNo})',
                                        style: theme.textTheme.titleLarge,
                                      ),
                                      const SizedBox(height: 16),
                                      ElevatedButton(
                                        onPressed: () {},
                                        child: const Text('Download'),
                                      ),
                                      Center(
                                        child: Column(
                                          children: [
                                            Text(
                                              'NHIT Western Projects Private Limited',
                                              style: theme.textTheme.titleMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              'Note for Approval of Payment',
                                              style: theme.textTheme.bodyLarge
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 28),
                                      DefaultTextStyle(
                                        style: theme.textTheme.bodyMedium!.copyWith(height: 2.5),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                              Text('Date: ${paymentNoteDetailMockData.date}'),
                                              Text('Note No.: ${paymentNoteDetailMockData.noteNo}'),
                                            ]),
                                            const SizedBox(height: 6),
                                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                              Text('Green Note No: ${paymentNoteDetailMockData.greenNoteNo}'),
                                              Text('Department: ${paymentNoteDetailMockData.department}'),
                                            ]),
                                            const SizedBox(height: 6),
                                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                              Text('Green Note App. Date: ${paymentNoteDetailMockData.greenNoteAppDate}'),
                                              Text('Green Note Approver: ${paymentNoteDetailMockData.greenNoteApprover}'),
                                            ]),
                                            const SizedBox(height: 12),
                                            Text('Subject: ${paymentNoteDetailMockData.subject}'),
                                            const SizedBox(height: 8),
                                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                              Text('Vendor Code: ${paymentNoteDetailMockData.vendorCode}'),
                                              Text('Vendor Name: ${paymentNoteDetailMockData.vendorName}'),
                                            ]),
                                            const SizedBox(height: 6),
                                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                              Text('Invoice No.: ${paymentNoteDetailMockData.invoiceNo}'),
                                              Text('Date: ${paymentNoteDetailMockData.invoiceDate}'),
                                              Text('Amount: ${paymentNoteDetailMockData.invoiceAmount}'),
                                            ]),
                                            const SizedBox(height: 6),
                                            Text('Invoice Approved by: ${paymentNoteDetailMockData.invoiceApprovedBy}'),
                                            const SizedBox(height: 10),
                                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                              Text('LOA/PO No.: ${paymentNoteDetailMockData.loaPoNo}'),
                                              Text('LOA/PO Amount: ${paymentNoteDetailMockData.loaPoAmount}'),
                                              Text('LOA/PO Date: ${paymentNoteDetailMockData.loaPoDate}'),
                                            ]),
                                            const SizedBox(height: 16),
                                            Text('Summary of payment', style: theme.textTheme.titleMedium),
                                            _buildSummaryTable(context),
                                            const SizedBox(height: 8),
                                            Text('Net Payable Amount (Words): ${paymentNoteDetailMockData.paymentSummary.netPayableWords}'),
                                            const SizedBox(height: 16),
                                            Text('Bank Details:', style: theme.textTheme.titleMedium),
                                            Text('Name of Account holder: ${paymentNoteDetailMockData.bankAccountHolder}'),
                                            Text('Bank Name: ${paymentNoteDetailMockData.bankName}'),
                                            Text('Bank Account: ${paymentNoteDetailMockData.bankAccountNumber}'),
                                            Text('IFSC: ${paymentNoteDetailMockData.bankIfsc}'),
                                            const SizedBox(height: 10),
                                            Text('Recommendation of Payment', style: theme.textTheme.titleMedium),
                                            Text(paymentNoteDetailMockData.recommendation),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(height: 16),
                                      Text(
                                        'Approval Matrix',
                                        style: theme.textTheme.titleMedium,
                                      ),
                                      DataTable(
                                        columns: const [
                                          DataColumn(label: Text('Role')),
                                          DataColumn(label: Text('Name')),
                                          DataColumn(
                                            label: Text('Designation'),
                                          ),
                                          DataColumn(
                                            label: Text('Date & Signature'),
                                          ),
                                        ],
                                        rows: paymentNoteDetailMockData
                                            .approvalMatrix
                                            .map(
                                              (entry) => DataRow(
                                                cells: [
                                                  DataCell(Text(entry.role)),
                                                  DataCell(Text(entry.name)),
                                                  DataCell(
                                                    Text(entry.designation),
                                                  ),
                                                  DataCell(
                                                    Text(entry.dateSignature),
                                                  ),
                                                ],
                                              ),
                                            )
                                            .toList(),
                                      ),
                                    ],
                                  ),
                                ),
                                // No Flow widget here!
                              ],
                            ),
                          ),
                          _buildAttachedDocsSection(context),
                          _buildCommentSection(context),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // The side "Flow" card
          Container(
            width: 300,
            child: _buildFlowCard(context),
          ),
        ],
      ),
    );
  }
}
