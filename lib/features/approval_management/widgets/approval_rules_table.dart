import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:ppv_components/common_widgets/custom_table.dart';
import 'package:ppv_components/common_widgets/custom_pagination.dart';
import 'package:ppv_components/common_widgets/badge.dart';
import 'package:ppv_components/common_widgets/button/secondary_button.dart';
import 'package:ppv_components/features/approval_management/models/approval_rule_model.dart';

class ApprovalRulesTable extends StatefulWidget {
  final List<ApprovalRule> rulesData;
  final String? title;
  final Function(ApprovalRule)? onView;
  final Function(ApprovalRule)? onEdit;
  final Function(ApprovalRule)? onDelete;

  const ApprovalRulesTable({
    super.key,
    required this.rulesData,
    this.title,
    this.onView,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<ApprovalRulesTable> createState() => _ApprovalRulesTableState();
}

class _ApprovalRulesTableState extends State<ApprovalRulesTable> {
  int rowsPerPage = 10;
  int currentPage = 0;
  late List<ApprovalRule> paginatedRules;
  late List<ApprovalRule> filteredRules;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  String searchQuery = '';
  String? statusFilter;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    filteredRules = List<ApprovalRule>.from(widget.rulesData);
    _updatePagination();
  }

  @override
  void didUpdateWidget(covariant ApprovalRulesTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    filteredRules = List<ApprovalRule>.from(widget.rulesData);
    _applyFilters();
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }
  
  void _applyFilters() {
    setState(() {
      filteredRules = widget.rulesData.where((rule) {
        final matchesStatus = statusFilter == null || rule.status == statusFilter;
        final matchesSearch = searchQuery.isEmpty ||
            rule.ruleName.toLowerCase().contains(searchQuery) ||
            rule.amountRange.toLowerCase().contains(searchQuery);
        return matchesStatus && matchesSearch;
      }).toList();
      currentPage = 0;
      _updatePagination();
    });
  }

  void _refreshData() {
    if (_isRefreshing) return;
    setState(() {
      _isRefreshing = true;
      statusFilter = null;
      searchQuery = '';
      _searchController.clear();
      currentPage = 0;
    });
    
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          filteredRules = List<ApprovalRule>.from(widget.rulesData);
          _updatePagination();
          _isRefreshing = false;
        });
      }
    });
  }

  void copyRule(ApprovalRule rule) {
    final ruleData = 'Rule: ${rule.ruleName}\nAmount Range: ${rule.amountRange}\nApprovers: ${rule.approvers}\nLevels: ${rule.levels}\nStatus: ${rule.status}';
    Clipboard.setData(ClipboardData(text: ruleData));
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Rule data copied to clipboard'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> deleteRule(ApprovalRule rule) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete rule "${rule.ruleName}"?'),
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
    
    if (shouldDelete == true && widget.onDelete != null) {
      widget.onDelete!(rule);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rule deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'inactive':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
  
  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      if (mounted) {
        setState(() {
          searchQuery = value.toLowerCase();
          currentPage = 0;
        });
        _applyFilters();
      }
    });
  }
  
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Filter by Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('All'),
                leading: Radio<String?>(
                  value: null,
                  groupValue: statusFilter,
                  onChanged: (value) {
                    Navigator.pop(context);
                    setState(() {
                      statusFilter = value;
                    });
                    _applyFilters();
                  },
                ),
              ),
              ListTile(
                title: const Text('Active'),
                leading: Radio<String?>(
                  value: 'Active',
                  groupValue: statusFilter,
                  onChanged: (value) {
                    Navigator.pop(context);
                    setState(() {
                      statusFilter = value;
                    });
                    _applyFilters();
                  },
                ),
              ),
              ListTile(
                title: const Text('Inactive'),
                leading: Radio<String?>(
                  value: 'Inactive',
                  groupValue: statusFilter,
                  onChanged: (value) {
                    Navigator.pop(context);
                    setState(() {
                      statusFilter = value;
                    });
                    _applyFilters();
                  },
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _updatePagination() {
    final start = currentPage * rowsPerPage;
    final end = (start + rowsPerPage).clamp(0, widget.rulesData.length);
    setState(() {
      paginatedRules = widget.rulesData.sublist(start, end);
      final totalPages = (widget.rulesData.length / rowsPerPage).ceil();
      if (currentPage >= totalPages && totalPages > 0) {
        currentPage = totalPages - 1;
        paginatedRules = widget.rulesData.sublist(start, end);
      }
    });
  }

  void changeRowsPerPage(int? value) {
    setState(() {
      rowsPerPage = value ?? 25;
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final columns = [
      DataColumn(
        label: Text('RULE NAME',
            style: TextStyle(
                color: colorScheme.onSurface, fontWeight: FontWeight.bold)),
      ),
      DataColumn(
        label: Text('AMOUNT RANGE',
            style: TextStyle(
                color: colorScheme.onSurface, fontWeight: FontWeight.bold)),
      ),
      DataColumn(
        label: Text('APPROVERS',
            style: TextStyle(
                color: colorScheme.onSurface, fontWeight: FontWeight.bold)),
      ),
      DataColumn(
        label: Text('LEVELS',
            style: TextStyle(
                color: colorScheme.onSurface, fontWeight: FontWeight.bold)),
      ),
      DataColumn(
        label: Text('CREATED',
            style: TextStyle(
                color: colorScheme.onSurface, fontWeight: FontWeight.bold)),
      ),
      DataColumn(
        label: Text('STATUS',
            style: TextStyle(
                color: colorScheme.onSurface, fontWeight: FontWeight.bold)),
      ),
      DataColumn(
        label: Text('ACTIONS',
            style: TextStyle(
                color: colorScheme.onSurface, fontWeight: FontWeight.bold)),
      ),
    ];

    final rows = paginatedRules.map((rule) {
      return DataRow(
        cells: [
          DataCell(
            Text(
              rule.ruleName,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          DataCell(
            Text(rule.amountRange,
                style: TextStyle(color: colorScheme.onSurface)),
          ),
          DataCell(
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${rule.approvers} Approvers',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          DataCell(
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.cyan,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${rule.levels} Levels',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          DataCell(
            Text(rule.created, style: TextStyle(color: colorScheme.onSurface)),
          ),
          DataCell(
            BadgeChip(
              label: rule.status,
              type: ChipType.status,
              statusKey: rule.status,
              statusColorFunc: _getStatusColor,
            ),
          ),
          DataCell(
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // View Icon Button
                IconButton(
                  onPressed: widget.onView != null ? () => widget.onView!(rule) : null,
                  icon: const Icon(Icons.visibility_outlined),
                  color: colorScheme.primary,
                  iconSize: 20,
                  tooltip: 'View',
                  style: IconButton.styleFrom(
                    backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                  ),
                ),
                const SizedBox(width: 4),
                // Edit Icon Button
                IconButton(
                  onPressed: widget.onEdit != null ? () => widget.onEdit!(rule) : null,
                  icon: const Icon(Icons.edit_outlined),
                  color: colorScheme.tertiary,
                  iconSize: 20,
                  tooltip: 'Edit',
                  style: IconButton.styleFrom(
                    backgroundColor: colorScheme.tertiary.withValues(alpha: 0.1),
                  ),
                ),
                const SizedBox(width: 4),
                // Copy Icon Button
                IconButton(
                  onPressed: () => copyRule(rule),
                  icon: const Icon(Icons.copy_outlined),
                  color: colorScheme.secondary,
                  iconSize: 20,
                  tooltip: 'Copy',
                  style: IconButton.styleFrom(
                    backgroundColor: colorScheme.secondary.withValues(alpha: 0.1),
                  ),
                ),
                const SizedBox(width: 4),
                // Delete Icon Button
                IconButton(
                  onPressed: () => deleteRule(rule),
                  icon: const Icon(Icons.delete_outline),
                  color: colorScheme.error,
                  iconSize: 20,
                  tooltip: 'Delete',
                  style: IconButton.styleFrom(
                    backgroundColor: colorScheme.error.withValues(alpha: 0.1),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }).toList();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.grid_view, size: 20, color: colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    widget.title ?? 'Approval Rules',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  SecondaryButton(
                    icon: Icons.filter_list,
                    label: statusFilter == null ? 'Filter' : 'Filter: $statusFilter',
                    onPressed: _showFilterDialog,
                  ),
                  const SizedBox(width: 8),
                  SecondaryButton(
                    icon: Icons.refresh,
                    label: 'Refresh',
                    onPressed: _refreshData,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Table
          Expanded(
            child: CustomTable(
              columns: columns,
              rows: rows,
              minTableWidth: 1200,
            ),
          ),

          // Pagination
          _paginationBar(context),
        ],
      ),
    );
  }

  Widget _paginationBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final totalPages = (widget.rulesData.length / rowsPerPage).ceil();
    final start = currentPage * rowsPerPage;
    final end = (start + rowsPerPage).clamp(0, widget.rulesData.length);

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
            "Showing ${widget.rulesData.isEmpty ? 0 : start + 1} to $end of ${widget.rulesData.length} entries",
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Row(
            children: [
              TextButton(
                onPressed:
                    currentPage > 0 ? () => gotoPage(currentPage - 1) : null,
                child: const Text('Previous'),
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
              TextButton(
                onPressed: currentPage < totalPages - 1
                    ? () => gotoPage(currentPage + 1)
                    : null,
                child: const Text('Next'),
              ),
              const SizedBox(width: 20),
              DropdownButton<int>(
                value: rowsPerPage,
                items: [10, 25, 50, 100]
                    .map((e) => DropdownMenuItem(value: e, child: Text('$e')))
                    .toList(),
                onChanged: changeRowsPerPage,
                style: Theme.of(context).textTheme.bodyMedium,
                underline: const SizedBox(),
              ),
              const SizedBox(width: 8),
              Text("/ page", style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}
