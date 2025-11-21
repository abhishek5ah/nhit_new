import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ppv_components/features/department/model/department_model.dart';
import 'package:ppv_components/features/department/widgets/add_department.dart';
import 'package:ppv_components/features/department/widgets/department_header.dart';
import 'package:ppv_components/features/department/widgets/department_table.dart';
import 'package:ppv_components/features/department/providers/department_provider.dart';

class DepartmentMainPage extends StatefulWidget {
  const DepartmentMainPage({super.key});

  @override
  State<DepartmentMainPage> createState() => _DepartmentMainPageState();
}

class _DepartmentMainPageState extends State<DepartmentMainPage> {
  String searchQuery = '';
  late List<Department> filteredDepartments = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDepartments();
    });
  }

  Future<void> _loadDepartments() async {
    final provider = context.read<DepartmentProvider>();
    await provider.loadDepartments();
    _updateFilteredList();
  }

  void _updateFilteredList() {
    final provider = context.read<DepartmentProvider>();
    setState(() {
      filteredDepartments = provider.searchDepartments(searchQuery);
    });
  }

  void updateSearch(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
      _updateFilteredList();
    });
  }

  Future<void> onDeleteDepartment(Department department) async {
    final provider = context.read<DepartmentProvider>();
    final result = await provider.deleteDepartment(department.id);
    
    if (result.success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message ?? 'Department deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _updateFilteredList();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message ?? 'Failed to delete department'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> onEditDepartment(Department department) async {
    await _loadDepartments();
  }

  Future<void> onAddDepartment() async {
    await showDialog(
      context: context,
      builder: (context) => Dialog(
        child: SizedBox(
          width: 600,
          height: 600,
          child: AddDepartmentPage(
            onDepartmentAdded: () {
              Navigator.of(context).pop();
              _loadDepartments();
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 12, right: 12),
              child: DepartmentHeader(),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: SizedBox(
                width: 250,
                child: TextField(
                  decoration: InputDecoration(
                    contentPadding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    hintText: 'Search departments',
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
            ),
            // const SizedBox(height: 6),
            Expanded(
              child: DepartmentTableView(
                departmentData: filteredDepartments,
                onDelete: onDeleteDepartment,
                onEdit: onEditDepartment,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
