import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ppv_components/features/designation/model/designation_model.dart';
import 'package:ppv_components/features/designation/widgets/designation_header.dart';
import 'package:ppv_components/features/designation/widgets/designation_table.dart';
import 'package:ppv_components/features/designation/providers/designation_provider.dart';

class DesignationMainPage extends StatefulWidget {
  const DesignationMainPage({super.key});

  @override
  State<DesignationMainPage> createState() => _DesignationMainPageState();
}

class _DesignationMainPageState extends State<DesignationMainPage> {
  String searchQuery = '';
  late List<Designation> filteredDesignations = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDesignations();
    });
  }

  Future<void> _loadDesignations() async {
    final provider = context.read<DesignationProvider>();
    await provider.loadDesignations();
    _updateFilteredList();
  }

  void _updateFilteredList() {
    final provider = context.read<DesignationProvider>();
    setState(() {
      filteredDesignations = provider.searchDesignations(searchQuery);
    });
  }

  void updateSearch(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
      _updateFilteredList();
    });
  }

  Future<void> onDeleteDesignation(Designation designation) async {
    final provider = context.read<DesignationProvider>();
    final result = await provider.deleteDesignation(designation.id);
    
    if (result.success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message ?? 'Designation deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _updateFilteredList();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message ?? 'Failed to delete designation'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> onEditDesignation(Designation designation) async {
    await _loadDesignations();
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
              child: DesignationHeader(),
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
