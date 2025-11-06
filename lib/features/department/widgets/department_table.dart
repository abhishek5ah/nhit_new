import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ppv_components/common_widgets/button/primary_button.dart';
import 'package:ppv_components/common_widgets/custom_table.dart';
import 'package:ppv_components/features/department/model/department_model.dart';
import 'package:ppv_components/features/department/screen/create_department.dart';
import 'package:ppv_components/features/department/screen/view_department.dart';
import 'package:ppv_components/features/department/widgets/add_department.dart';

import '../screen/edit_department.dart';

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
    setState(() {
      paginatedDepartments = widget.departmentData.sublist(start, end);
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

  //Navigate to AddDepartmentPage
  Future<void> onAddDepartment() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddDepartmentPage(),
      ),
    );

    if (result != null && result is Department) {
      widget.onEdit(result);
      _updatePagination();
    }
  }

  // Navigate to EditDepartmentPage
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

  // Navigate to ViewDepartmentDetailsPage
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

  Widget _buildInputField(BuildContext context, String label, TextEditingController controller,
      {int maxLines = 1}) {
    final theme = Theme.of(context);
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: theme.colorScheme.onSurface),
        filled: true,
        fillColor: theme.colorScheme.surfaceContainer,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: theme.colorScheme.outline),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: theme.colorScheme.primary),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: (val) {
        if (val == null || val.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
    );
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
          DataCell(Text(department.id.toString(), style: TextStyle(color: colorScheme.onSurface))),
          DataCell(Text(department.name, style: TextStyle(color: colorScheme.onSurface))),
          DataCell(Text(department.description, style: TextStyle(color: colorScheme.onSurface))),
          DataCell(Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              OutlinedButton(
                onPressed: () => onEditDepartment(department),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.onSurface,
                  side: BorderSide(color: colorScheme.outline),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
                child: const Text('Edit'),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () => onViewDepartment(department),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.primary,
                  side: BorderSide(color: colorScheme.outline),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
                child: const Text('View'),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () => deleteDepartment(department),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.error,
                  side: BorderSide(color: colorScheme.outline),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
                child: const Text('Delete'),
              ),
            ],
          )),
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
                        // PrimaryButton(
                        //   label: 'Create Department',
                        //   onPressed: onAddDepartment,
                        // )
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: CustomTable(
                        columns: columns,
                        rows: rows,
                      ),
                    ),
                    _paginationBar(context),
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
    final totalPages = (widget.departmentData.length / rowsPerPage).ceil();
    final start = currentPage * rowsPerPage;
    final end = (start + rowsPerPage).clamp(0, widget.departmentData.length);

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
            "Showing ${widget.departmentData.isEmpty ? 0 : start + 1} to $end of ${widget.departmentData.length} entries",
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: currentPage > 0 ? () => gotoPage(currentPage - 1) : null,
              ),
              for (int i = startWindow; i < endWindow; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      i == currentPage ? colorScheme.primary : colorScheme.surfaceContainer,
                      foregroundColor: i == currentPage ? Colors.white : colorScheme.onSurface,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      minimumSize: const Size(40, 40),
                    ),
                    onPressed: () => gotoPage(i),
                    child: Text('${i + 1}'),
                  ),
                ),
              IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: currentPage < totalPages - 1 ? () => gotoPage(currentPage + 1) : null,
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
