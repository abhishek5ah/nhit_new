import 'package:flutter/material.dart';
import 'package:ppv_components/common_widgets/button/primary_button.dart';
import 'package:ppv_components/common_widgets/custom_table.dart';
import 'package:ppv_components/common_widgets/custom_pagination.dart';
import 'package:ppv_components/features/designation/model/designation_model.dart';
import 'package:ppv_components/features/designation/screen/create_designation.dart';
import 'package:ppv_components/features/designation/screen/edit_designation.dart';
import 'package:ppv_components/features/designation/screen/view_designation.dart';

class DesignationTableView extends StatefulWidget {
  final List<Designation> designationData;
  final void Function(Designation) onDelete;
  final void Function(Designation) onEdit;

  const DesignationTableView({
    super.key,
    required this.designationData,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  State<DesignationTableView> createState() => _DesignationTableViewState();
}

class _DesignationTableViewState extends State<DesignationTableView> {
  int rowsPerPage = 10;
  int currentPage = 0;
  late List<Designation> paginatedDesignations;

  @override
  void initState() {
    super.initState();
    _updatePagination();
  }

  @override
  void didUpdateWidget(covariant DesignationTableView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updatePagination();
  }

  void _updatePagination() {
    final totalPages = (widget.designationData.length / rowsPerPage).ceil();
    if (currentPage >= totalPages && totalPages > 0) {
      currentPage = totalPages - 1;
    }
    final start = currentPage * rowsPerPage;
    final end = (start + rowsPerPage).clamp(0, widget.designationData.length);
    paginatedDesignations = widget.designationData.sublist(start, end);
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

  Future<void> onAddDesignation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateDesignationScreen(),
      ),
    );

    if (result != null && result is Designation) {
      widget.onEdit(result);
      _updatePagination();
    }
  }

  Future<void> onEditDesignation(Designation designation) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditDesignationScreen(designation: designation),
      ),
    );

    if (result != null && result is Designation) {
      widget.onEdit(result);
      _updatePagination();
    }
  }

  Future<void> onViewDesignation(Designation designation) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewDesignationScreen(designation: designation),
      ),
    );
  }

  Future<void> deleteDesignation(Designation designation) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete ${designation.name}?'),
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
      widget.onDelete(designation);
      _updatePagination();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final columns = [
      DataColumn(label: Text('#', style: TextStyle(color: colorScheme.onSurface))),
      DataColumn(label: Text('Name', style: TextStyle(color: colorScheme.onSurface))),
      DataColumn(label: Text('Description', style: TextStyle(color: colorScheme.onSurface))),
      DataColumn(label: Text('Actions', style: TextStyle(color: colorScheme.onSurface))),
    ];

    int rowIndex = 0;
    final rows = paginatedDesignations.map((designation) {
      final displayIndex = currentPage * rowsPerPage + rowIndex + 1;
      rowIndex++;
      return DataRow(
        cells: [
          DataCell(Text(displayIndex.toString(), style: TextStyle(color: colorScheme.onSurface))),
          DataCell(Text(designation.name, style: TextStyle(color: colorScheme.onSurface))),
          DataCell(Text(designation.description, style: TextStyle(color: colorScheme.onSurface))),
          DataCell(
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // View Icon Button
                IconButton(
                  onPressed: () => onViewDesignation(designation),
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
                  onPressed: () => onEditDesignation(designation),
                  icon: const Icon(Icons.edit_outlined),
                  color: colorScheme.tertiary,
                  iconSize: 20,
                  tooltip: 'Edit',
                  style: IconButton.styleFrom(
                    backgroundColor: colorScheme.tertiary.withValues(alpha: 0.1),
                  ),
                ),
                const SizedBox(width: 4),
                // Delete Icon Button
                IconButton(
                  onPressed: () => deleteDesignation(designation),
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

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Designations',
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        PrimaryButton(
                          label: 'Add Designation',
                          onPressed: onAddDesignation,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(child: CustomTable(columns: columns, rows: rows)),
                    // Replace the pagination bar widget call with the reusable component:
                    CustomPaginationBar(
                      totalItems: widget.designationData.length,
                      currentPage: currentPage,
                      rowsPerPage: rowsPerPage,
                      onPageChanged: gotoPage,
                      onRowsPerPageChanged: changeRowsPerPage,
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
