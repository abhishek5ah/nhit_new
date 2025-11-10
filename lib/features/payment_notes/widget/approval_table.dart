import 'package:flutter/material.dart';
import 'package:ppv_components/common_widgets/button/toggle_button.dart';
import 'package:ppv_components/common_widgets/custom_pagination.dart';
import 'package:ppv_components/common_widgets/custom_table.dart';
import 'package:ppv_components/features/payment_notes/model/approval_model.dart';
import 'package:ppv_components/features/payment_notes/widget/approval_grid.dart';
import 'package:ppv_components/features/payment_notes/widget/approval_view.dart';

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
    if (widget.approvalData != oldWidget.approvalData) {
      currentPage = 0;
    }
    _updatePagination();
  }

  void _updatePagination() {
    final start = currentPage * rowsPerPage;
    final end = (start + rowsPerPage).clamp(0, widget.approvalData.length);
    setState(() {
      final totalPages = (widget.approvalData.length / rowsPerPage).ceil();
      if (currentPage >= totalPages && totalPages > 0) {
        currentPage = totalPages - 1;
      }
      paginatedApprovals = widget.approvalData.sublist(
        (currentPage * rowsPerPage).clamp(0, widget.approvalData.length),
        (currentPage * rowsPerPage + rowsPerPage)
            .clamp(0, widget.approvalData.length),
      );
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
          'Are you sure you want to delete the rule for ${approval.approverLevel} in range ${approval.paymentRange}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );
    if (shouldDelete == true) {
      widget.onDelete(approval);
    }
  }

  // Updated to navigate to the new screen
  Future<void> onViewApproval(ApproverRule approval) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewApprovalScreen(approval: approval),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final columns = [
      DataColumn(
        label: Text('Approver Level',
            style: TextStyle(color: colorScheme.onSurface)),
      ),
      DataColumn(
        label: Text('Users', style: TextStyle(color: colorScheme.onSurface)),
      ),
      DataColumn(
        label: Text('Payment Range',
            style: TextStyle(color: colorScheme.onSurface)),
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
                IconButton(
                  icon: const Icon(Icons.visibility_outlined),
                  tooltip: 'View Rule',
                  onPressed: () => onViewApproval(approval),
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.delete_outline, color: colorScheme.error),
                  tooltip: 'Delete Rule',
                  onPressed: () => deleteApproval(approval),
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
                                color: colorScheme.onSurface.withOpacity(0.6),
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
                          CustomPaginationBar(
                            totalItems: widget.approvalData.length,
                            rowsPerPage: rowsPerPage,
                            currentPage: currentPage,
                            onPageChanged: gotoPage,
                            onRowsPerPageChanged: changeRowsPerPage,
                          ),
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
}
