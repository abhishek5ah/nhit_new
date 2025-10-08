import 'package:flutter/material.dart';
import 'package:ppv_components/features/designation/data/designation_mockdb.dart';
import 'package:ppv_components/features/designation/model/designation_model.dart';
import 'package:ppv_components/features/designation/widgets/designation_header.dart';
import 'package:ppv_components/features/designation/widgets/designation_table.dart';

class DesignationMainPage extends StatefulWidget {
  const DesignationMainPage({super.key});

  @override
  State<DesignationMainPage> createState() => _DesignationMainPageState();
}

class _DesignationMainPageState extends State<DesignationMainPage> {
  String searchQuery = '';
  late List<Designation> filteredDesignations;
  List<Designation> allDesignations = List<Designation>.from(designationData);

  @override
  void initState() {
    super.initState();
    filteredDesignations = List<Designation>.from(allDesignations);
  }

  void updateSearch(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
      filteredDesignations = allDesignations.where((designation) {
        final name = designation.name.toLowerCase();
        final description = designation.description.toLowerCase();
        return name.contains(searchQuery) ||
            description.contains(searchQuery);
      }).toList();
    });
  }

  void onDeleteDesignation(Designation designation) {
    setState(() {
      allDesignations.removeWhere((d) => d.id == designation.id);
      updateSearch(searchQuery);
    });
  }

  void onEditDesignation(Designation designation) {
    final index = allDesignations.indexWhere((d) => d.id == designation.id);
    if (index != -1) {
      setState(() {
        allDesignations[index] = designation;
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
              child: DesignationHeader(tabIndex: 0),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Spacer(),
                  SizedBox(
                    width: 250,
                    child: TextField(
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                        hintText: 'Search designations',
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
            Expanded(
              child: DesignationTableView(
                designationData: filteredDesignations,
                onDelete: onDeleteDesignation,
                onEdit: onEditDesignation,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
