import 'package:flutter/material.dart';
import 'package:ppv_components/common_widgets/button/toggle_button.dart';
import 'package:ppv_components/common_widgets/custom_table.dart';
import 'package:ppv_components/features/payment_notes/model/approval_model.dart';
import 'package:ppv_components/features/payment_notes/widget/approval_grid.dart';

class ApprovalTableView extends StatefulWidget {
  final List<ApproverRule> approvalData;
  final void Function(ApproverRule) onDelete;

  const ApprovalTableView({
    super.key,
    required this.approvalData,
    required this.onDelete,
  });

  @override
  State<ApprovalTableView> createState() => _ApprovalTableViewState();
}

class _ApprovalTableViewState extends State<ApprovalTableView> {
  int toggleIndex = 0;
  int rowsPerPage = 10;
  int currentPage = 0;
  late List<ApproverRule> paginatedApprovals;

  @override
  void initState() {
    super.initState();
    _updatePagination();
  }

  @override
  void didUpdateWidget(covariant ApprovalTableView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updatePagination();
  }

  void _updatePagination() {
    final start = currentPage * rowsPerPage;
    final end = (start + rowsPerPage).clamp(0, widget.approvalData.length);
    setState(() {
      paginatedApprovals = widget.approvalData.sublist(start, end);
      final totalPages = (widget.approvalData.length / rowsPerPage).ceil();
      if (currentPage >= totalPages && totalPages > 0) {
        currentPage = totalPages - 1;
        paginatedApprovals = widget.approvalData.sublist(start, end);
      }
    });
  }

  void changeRowsPerPage(int? value) {
    setState(() {
      rowsPerPage = value ?? 10;
      currentPage = 0;
      _updatePagination();
    });
  }

  void gotoPage(int page) {
    setState(() {
      currentPage = page;
      _updatePagination();
    });
  }

  Future<void> deleteApproval(ApproverRule approval) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text(
          'Are you sure you want to delete approval rule for ${approval.approverLevel} and range ${approval.paymentRange}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (shouldDelete == true) {
      widget.onDelete(approval);
      _updatePagination();
    }
  }

  Future<void> onViewApproval(ApproverRule approval) async {
    await showDialog(
      context: context,
      builder: (ctx) {
        final colorScheme = Theme.of(ctx).colorScheme;

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: colorScheme.surface,
          child: Container(
            width: MediaQuery.of(ctx).size.width * 0.4,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              border: Border.all(color: colorScheme.outline, width: 0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Approval Rule Details",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      icon: Icon(Icons.close, color: colorScheme.onSurface),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildDetail(ctx, "Approver Level", approval.approverLevel),
                _buildDetail(ctx, "Users", approval.users.join(', ')),
                _buildDetail(ctx, "Payment Range", approval.paymentRange),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                    ),
                    child: const Text("Close"),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetail(BuildContext ctx, String label, String value) {
    final colorScheme = Theme.of(ctx).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline, width: 0.5),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: TextStyle(color: colorScheme.onSurface)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final columns = [
      DataColumn(
        label: Text('Approver Level', style: TextStyle(color: colorScheme.onSurface)),
      ),
      DataColumn(
        label: Text('Users', style: TextStyle(color: colorScheme.onSurface)),
      ),
      DataColumn(
        label: Text('Payment Range', style: TextStyle(color: colorScheme.onSurface)),
      ),
      DataColumn(
        label: Text('Actions', style: TextStyle(color: colorScheme.onSurface)),
      ),
    ];

    final rows = paginatedApprovals.map((approval) {
      return DataRow(
        cells: [
          DataCell(
            Text(
              approval.approverLevel,
              style: TextStyle(color: colorScheme.onSurface),
            ),
          ),
          DataCell(
            Text(
              approval.users.join(', '),
              style: TextStyle(color: colorScheme.onSurface),
            ),
          ),
          DataCell(
            Text(
              approval.paymentRange,
              style: TextStyle(color: colorScheme.onSurface),
            ),
          ),
          DataCell(
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlinedButton(
                  onPressed: () => onViewApproval(approval),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.primary,
                    side: BorderSide(color: colorScheme.outline),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                  ),
                  child: const Text('View'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () => deleteApproval(approval),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.error,
                    side: BorderSide(color: colorScheme.outline),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                  ),
                  child: const Text('Delete'),
                ),
              ],
            ),
          ),
        ],
      );
    }).toList();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(22),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Approvals',
                              style: TextStyle(
                                color: colorScheme.onSurface,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Manage your approval rules',
                              style: TextStyle(
                                color: colorScheme.onSurface.withAlpha(153),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        ToggleBtn(
                          labels: const ['Table', 'Grid'],
                          selectedIndex: toggleIndex,
                          onChanged: (index) =>
                              setState(() => toggleIndex = index),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: toggleIndex == 0
                          ? Column(
                        children: [
                          Expanded(
                            child: CustomTable(
                              columns: columns,
                              rows: rows,
                            ),
                          ),
                          _paginationBar(context),
                        ],
                      )
                          : ApprovalGrid(
                        approvalList: widget.approvalData,
                        rowsPerPage: rowsPerPage,
                        currentPage: currentPage,
                        onPageChanged: (page) =>
                            setState(() => currentPage = page),
                        onRowsPerPageChanged: (rows) => setState(() {
                          rowsPerPage = rows ?? rowsPerPage;
                          currentPage = 0;
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _paginationBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final totalPages = (widget.approvalData.length / rowsPerPage).ceil();
    final start = currentPage * rowsPerPage;
    final end = (start + rowsPerPage).clamp(0, widget.approvalData.length);

    int windowSize = 3;
    int startWindow = 0;
    int endWindow = totalPages;

    if (totalPages > windowSize) {
      if (currentPage <= 1) {
        startWindow = 0;
        endWindow = windowSize;
      } else if (currentPage >= totalPages - 2) {
        startWindow = totalPages - windowSize;
        endWindow = totalPages;
      } else {
        startWindow = currentPage - 1;
        endWindow = currentPage + 2;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Showing ${widget.approvalData.isEmpty ? 0 : start + 1} to $end of ${widget.approvalData.length} entries",
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: currentPage > 0
                    ? () => gotoPage(currentPage - 1)
                    : null,
              ),
              for (int i = startWindow; i < endWindow; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: i == currentPage
                          ? colorScheme.primary
                          : colorScheme.surfaceContainer,
                      foregroundColor: i == currentPage
                          ? Colors.white
                          : colorScheme.onSurface,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      minimumSize: const Size(40, 40),
                    ),
                    onPressed: () => gotoPage(i),
                    child: Text('${i + 1}'),
                  ),
                ),
              IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: currentPage < totalPages - 1
                    ? () => gotoPage(currentPage + 1)
                    : null,
              ),
              const SizedBox(width: 20),
              DropdownButton<int>(
                value: rowsPerPage,
                items: [5, 10, 20, 50]
                    .map((e) => DropdownMenuItem(value: e, child: Text('$e')))
                    .toList(),
                onChanged: changeRowsPerPage,
                style: Theme.of(context).textTheme.bodyMedium,
                underline: const SizedBox(),
              ),
              const SizedBox(width: 8),
              Text("page", style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}
