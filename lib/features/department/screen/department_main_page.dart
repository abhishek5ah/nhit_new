import 'package:flutter/material.dart';
import 'package:ppv_components/common_widgets/tabs.dart';
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
  int tabIndex = 0;
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
        return name.contains(searchQuery) ||
            description.contains(searchQuery);
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 12, right: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DepartmentHeader(tabIndex: tabIndex),
                  const SizedBox(height: 12),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: TabsBar(
                      tabs: const ['Department', 'Add Department'],
                      selectedIndex: tabIndex,
                      onChanged: (idx) => setState(() => tabIndex = idx),
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 250,
                    child: TextField(
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
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
                ],
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: tabIndex == 0
                  ? DepartmentTableView(
                departmentData: filteredDepartments,
                onDelete: onDeleteDepartment,
                onEdit: onEditDepartment,
              )
                  : const AddDepartmentPage(),
            ),
          ],
        ),
      ),
    );
  }
}
