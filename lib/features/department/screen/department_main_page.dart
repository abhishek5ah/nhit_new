import 'package:flutter/material.dart';
import 'package:ppv_components/features/department/model/department_model.dart';
import 'package:ppv_components/features/department/widgets/add_department.dart';
import 'package:ppv_components/features/department/widgets/department_header.dart';
import 'package:ppv_components/features/department/widgets/department_table.dart';
import 'package:ppv_components/features/department/data/department_mockdb.dart';

class DepartmentMainPage extends StatefulWidget {
  const DepartmentMainPage({super.key});

  @override
  State<DepartmentMainPage> createState() => _DepartmentMainPageState();
}

class _DepartmentMainPageState extends State<DepartmentMainPage> {
  String searchQuery = '';
  late List<Department> filteredDepartments;
  List<Department> allDepartments = List<Department>.from(departmentData);

  @override
  void initState() {
    super.initState();
    filteredDepartments = List<Department>.from(allDepartments);
  }

  void updateSearch(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
      filteredDepartments = allDepartments.where((department) {
        final name = department.name.toLowerCase();
        final description = department.description.toLowerCase();
        return name.contains(searchQuery) || description.contains(searchQuery);
      }).toList();
    });
  }

  void onDeleteDepartment(Department department) {
    setState(() {
      allDepartments.removeWhere((d) => d.id == department.id);
      updateSearch(searchQuery);
    });
  }

  void onEditDepartment(Department department) {
    final index = allDepartments.indexWhere((d) => d.id == department.id);
    if (index != -1) {
      setState(() {
        allDepartments[index] = department;
        updateSearch(searchQuery);
      });
    }
  }

  void onAddDepartment() {
    showDialog(
      context: context,
      builder: (context) => const Dialog(
        child: SizedBox(
          width: 600,
          height: 600,
          child: AddDepartmentPage(),
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
              child: DepartmentHeader(tabIndex: 0),
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
