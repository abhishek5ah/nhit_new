import 'package:flutter/material.dart';
import 'package:ppv_components/common_widgets/badge.dart';
import 'package:ppv_components/common_widgets/button/toggle_button.dart';
import 'package:ppv_components/common_widgets/button/outlined_button.dart';
import 'package:ppv_components/common_widgets/custom_pagination.dart';
import 'package:ppv_components/common_widgets/custom_table.dart';
import 'package:ppv_components/features/payment_notes/model/payment_notes_model.dart';
import 'package:ppv_components/features/payment_notes/screen/edit_payment_status.dart';
import 'package:ppv_components/features/payment_notes/screen/payment_note_detail_page.dart';
import 'package:ppv_components/features/payment_notes/widget/payment_grid.dart';

class PaymentTableView extends StatefulWidget {
  final List<PaymentNote> paymentData;
  final void Function(PaymentNote) onDelete;

  const PaymentTableView({
    super.key,
    required this.paymentData,
    required this.onDelete,
  });

  @override
  State<PaymentTableView> createState() => _PaymentTableViewState();
}

class _PaymentTableViewState extends State<PaymentTableView> {
  int toggleIndex = 0;
  int rowsPerPage = 10;
  int currentPage = 0;
  String searchQuery = '';
  String? statusFilter;

  late List<PaymentNote> filteredPayments;
  late List<PaymentNote> paginatedPayments;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredPayments = widget.paymentData;
    _updatePagination();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant PaymentTableView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.paymentData != oldWidget.paymentData) {
      currentPage = 0;
      _applyFilters();
    }
    _updatePagination();
  }

  void _updatePagination() {
    final start = currentPage * rowsPerPage;
    final end = (start + rowsPerPage).clamp(0, filteredPayments.length);
    setState(() {
      final totalPages = (filteredPayments.length / rowsPerPage).ceil();
      if (currentPage >= totalPages && totalPages > 0) {
        currentPage = totalPages - 1;
      }
      paginatedPayments = filteredPayments.sublist(
        (currentPage * rowsPerPage).clamp(0, filteredPayments.length),
        (currentPage * rowsPerPage + rowsPerPage).clamp(0, filteredPayments.length),
      );
    });
  }

  void _applyFilters() {
    setState(() {
      filteredPayments = widget.paymentData.where((payment) {
        // Search filter
        final matchesSearch = searchQuery.isEmpty ||
            payment.sno.toString().contains(searchQuery) ||
            payment.projectName.toLowerCase().contains(searchQuery.toLowerCase()) ||
            payment.vendorName.toLowerCase().contains(searchQuery.toLowerCase()) ||
            payment.invoiceValue.toLowerCase().contains(searchQuery.toLowerCase()) ||
            payment.status.toLowerCase().contains(searchQuery.toLowerCase()) ||
            payment.nextApprover.toLowerCase().contains(searchQuery.toLowerCase());

        // Status filter
        final matchesStatus = statusFilter == null ||
            statusFilter == 'All' ||
            payment.status == statusFilter;

        return matchesSearch && matchesStatus;
      }).toList();
    });
  }

  void updateSearch(String query) {
    setState(() {
      searchQuery = query;
      _applyFilters();
      currentPage = 0;
      _updatePagination();
    });
  }

  void _refreshData() {
    setState(() {
      statusFilter = null;
      searchQuery = '';
      _searchController.clear();
      filteredPayments = widget.paymentData;
      currentPage = 0;
      _updatePagination();
    });
  }

  void _showFilterDialog() {
    // Get unique statuses from payment data
    final uniqueStatuses = widget.paymentData
        .map((p) => p.status)
        .toSet()
        .toList()
      ..sort();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Filter Payments'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('All'),
                  leading: Radio<String?>(
                    value: null,
                    groupValue: statusFilter,
                    onChanged: (value) {
                      setState(() {
                        statusFilter = value;
                      });
                      Navigator.pop(context);
                      _applyFilters();
                      currentPage = 0;
                      _updatePagination();
                    },
                  ),
                ),
                ...uniqueStatuses.map((status) {
                  return ListTile(
                    title: Text(status),
                    leading: Radio<String>(
                      value: status,
                      groupValue: statusFilter,
                      onChanged: (value) {
                        setState(() {
                          statusFilter = value;
                        });
                        Navigator.pop(context);
                        _applyFilters();
                        currentPage = 0;
                        _updatePagination();
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
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

  Future<void> deletePayment(PaymentNote payment) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text(
          'Are you sure you want to delete payment #${payment.sno}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (shouldDelete == true) {
      widget.onDelete(payment);
    }
  }

  // Helper method to get status color
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return Colors.grey;
      case 'pending':
        return Colors.orange;
      case 'submitted':
        return Colors.blue;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'paid':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    final columns = [
      DataColumn(
        label: Text('S.No', style: TextStyle(color: colorScheme.onSurface)),
      ),
      DataColumn(
        label: Text(
          'Project Name',
          style: TextStyle(color: colorScheme.onSurface),
        ),
      ),
      DataColumn(
        label: Text(
          'Vendor Name',
          style: TextStyle(color: colorScheme.onSurface),
        ),
      ),
      DataColumn(
        label: Text(
          'Amount',
          style: TextStyle(color: colorScheme.onSurface),
        ),
      ),
      DataColumn(
        label: Text('Date', style: TextStyle(color: colorScheme.onSurface)),
      ),
      DataColumn(
        label: Text('Status', style: TextStyle(color: colorScheme.onSurface)),
      ),
      DataColumn(
        label: Text(
          'Next Approver',
          style: TextStyle(color: colorScheme.onSurface),
        ),
      ),
      DataColumn(
        label: Text('Actions', style: TextStyle(color: colorScheme.onSurface)),
      ),
    ];

    final rows = paginatedPayments.map((payment) {
      return DataRow(
        cells: [
          DataCell(
            Text(
              payment.sno.toString(),
              style: TextStyle(color: colorScheme.onSurface),
            ),
          ),
          DataCell(
            Text(
              payment.projectName,
              style: TextStyle(color: colorScheme.onSurface),
            ),
          ),
          DataCell(
            Text(
              payment.vendorName,
              style: TextStyle(color: colorScheme.onSurface),
            ),
          ),
          DataCell(
            Text(
              payment.invoiceValue,
              style: TextStyle(color: colorScheme.onSurface),
            ),
          ),
          DataCell(
            Text(payment.date, style: TextStyle(color: colorScheme.onSurface)),
          ),
          DataCell(
            BadgeChip(
              label: payment.status,
              type: ChipType.status,
              statusKey: payment.status,
              backgroundColor: _getStatusColor(payment.status),
              textColor: Colors.white,
            ),
          ),
          DataCell(
            Text(
              payment.nextApprover,
              style: TextStyle(color: colorScheme.onSurface),
            ),
          ),
          DataCell(
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.visibility_outlined),
                  tooltip: 'View Payment',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const PaymentNoteDetailPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.edit_outlined, color: Colors.orange[600]),
                  tooltip: 'Edit Status',
                  onPressed: () async {
                    final result = await Navigator.of(context).push<PaymentNote>(
                      MaterialPageRoute(
                        builder: (context) => EditPaymentStatusScreen(payment: payment),
                      ),
                    );

                    // If status was updated, refresh the data
                    if (result != null) {
                      setState(() {
                        // Update the payment in the list
                        final index = widget.paymentData.indexWhere((p) => p.sno == result.sno);
                        if (index != -1) {
                          widget.paymentData[index] = result;
                        }
                        _applyFilters();
                        _updatePagination();
                      });
                    }
                  },
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.delete_outline, color: colorScheme.error),
                  tooltip: 'Delete Payment',
                  onPressed: () => deletePayment(payment),
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
                    // Header with title, Filter, Refresh, and Toggle in same row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Title section on left
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Payments',
                                style: TextStyle(
                                  color: colorScheme.onSurface,
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Manage your payments',
                                style: TextStyle(
                                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Buttons section on right
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            OutlineButton(
                              onPressed: _showFilterDialog,
                              icon: Icons.filter_list,
                              label: statusFilter == null ? 'Filter' : 'Filter: $statusFilter',
                            ),
                            const SizedBox(width: 8),
                            OutlineButton(
                              onPressed: _refreshData,
                              icon: Icons.refresh,
                              label: 'Refresh',
                            ),
                            const SizedBox(width: 12),
                            ToggleBtn(
                              labels: const ['Table', 'Grid'],
                              selectedIndex: toggleIndex,
                              onChanged: (index) =>
                                  setState(() => toggleIndex = index),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Display active filters using BadgeChip
                    if (statusFilter != null || searchQuery.isNotEmpty) ...[
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (statusFilter != null)
                            BadgeChip(
                              label: 'Status: $statusFilter',
                              type: ChipType.removable,
                              backgroundColor: colorScheme.primaryContainer,
                              textColor: colorScheme.onPrimaryContainer,
                              onRemove: () {
                                setState(() {
                                  statusFilter = null;
                                  _applyFilters();
                                  currentPage = 0;
                                  _updatePagination();
                                });
                              },
                            ),
                          if (searchQuery.isNotEmpty)
                            BadgeChip(
                              label: 'Search: "$searchQuery"',
                              type: ChipType.removable,
                              backgroundColor: colorScheme.secondaryContainer,
                              textColor: colorScheme.onSecondaryContainer,
                              onRemove: () {
                                _searchController.clear();
                                updateSearch('');
                              },
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],

                    const SizedBox(height: 16),

                    // Table or Grid View
                    Expanded(
                      child: toggleIndex == 0
                          ? Column(
                        children: [
                          Expanded(
                            child: filteredPayments.isEmpty
                                ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.inbox_outlined,
                                    size: 64,
                                    color: colorScheme.onSurface.withValues(alpha: 0.3),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No payments found',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Try adjusting your filters',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurface.withValues(alpha: 0.4),
                                    ),
                                  ),
                                ],
                              ),
                            )
                                : CustomTable(
                              columns: columns,
                              rows: rows,
                            ),
                          ),
                          if (filteredPayments.isNotEmpty)
                            CustomPaginationBar(
                              totalItems: filteredPayments.length,
                              rowsPerPage: rowsPerPage,
                              currentPage: currentPage,
                              onPageChanged: gotoPage,
                              onRowsPerPageChanged: changeRowsPerPage,
                            ),
                        ],
                      )
                          : PaymentGrid(
                        paymentList: filteredPayments,
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
