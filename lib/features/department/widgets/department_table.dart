import 'package:flutter/material.dart';
import 'package:ppv_components/common_widgets/button/primary_button.dart';
import 'package:ppv_components/common_widgets/custom_table.dart';
import 'package:ppv_components/common_widgets/custom_pagination.dart';
import 'package:ppv_components/features/department/model/department_model.dart';
import 'package:ppv_components/features/department/screen/create_department.dart';
import 'package:ppv_components/features/department/screen/view_department.dart';
import 'package:ppv_components/features/department/screen/edit_department.dart';

class DepartmentTableView extends StatefulWidget {
  final List<Department> departmentData;
  final void Function(Department) onDelete;
  final void Function(Department) onEdit;

  const DepartmentTableView({
    super.key,
    required this.departmentData,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  State<DepartmentTableView> createState() => _DepartmentTableViewState();
}

class _DepartmentTableViewState extends State<DepartmentTableView> {
  int rowsPerPage = 10;
  int currentPage = 0;
  late List<Department> paginatedDepartments;

  @override
  void initState() {
    super.initState();
    _updatePagination();
  }

  @override
  void didUpdateWidget(covariant DepartmentTableView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updatePagination();
  }

  void _updatePagination() {
    final totalPages = (widget.departmentData.length / rowsPerPage).ceil();
    if (currentPage >= totalPages && totalPages > 0) {
      currentPage = totalPages - 1;
    }
    final start = currentPage * rowsPerPage;
    final end = (start + rowsPerPage).clamp(0, widget.departmentData.length);
    paginatedDepartments = widget.departmentData.sublist(start, end);
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

  Future<void> onAddDepartment() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateDepartmentScreen()),
    );

    if (result != null && result is Department) {
      widget.onEdit(result);
      _updatePagination();
    }
  }

  Future<void> onEditDepartment(Department department) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditDepartmentPage(department: department),
      ),
    );

    if (result != null && result is Department) {
      widget.onEdit(result);
      _updatePagination();
    }
  }

  Future<void> onViewDepartment(Department department) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewDepartmentPage(department: department),
      ),
    );
  }

  Future<void> deleteDepartment(Department department) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete ${department.name}?'),
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
      widget.onDelete(department);
      _updatePagination();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final columns = [
      DataColumn(label: Text('ID', style: TextStyle(color: colorScheme.onSurface))),
      DataColumn(label: Text('Name', style: TextStyle(color: colorScheme.onSurface))),
      DataColumn(label: Text('Description', style: TextStyle(color: colorScheme.onSurface))),
      DataColumn(label: Text('Actions', style: TextStyle(color: colorScheme.onSurface))),
    ];

      final rows = paginatedDepartments.map((department) {
        return DataRow(
          cells: [
            DataCell(Text(department.id, style: TextStyle(color: colorScheme.onSurface))),
            DataCell(Text(department.name, style: TextStyle(color: colorScheme.onSurface))),
            DataCell(Text(department.description, style: TextStyle(color: colorScheme.onSurface))),
            DataCell(
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // View Icon Button
                  IconButton(
                    onPressed: () => onViewDepartment(department),
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
                    onPressed: () => onEditDepartment(department),
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
                    onPressed: () => deleteDepartment(department),
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
                          'Departments',
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        PrimaryButton(
                          label: 'Add Department',
                          onPressed: onAddDepartment,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(child: CustomTable(columns: columns, rows: rows)),
                    // Use the reusable pagination widget here:
                    CustomPaginationBar(
                      totalItems: widget.departmentData.length,
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
