import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ppv_components/common_widgets/button/primary_button.dart';
import 'package:ppv_components/common_widgets/button/secondary_button.dart';
import 'package:ppv_components/common_widgets/custom_pagination.dart';
import 'package:ppv_components/common_widgets/custom_table.dart';
import 'package:ppv_components/common_widgets/badge.dart';
import 'package:ppv_components/features/reimbursement/data/reimbursement_dummydata/reimbursement_note_dummy.dart';
import 'package:ppv_components/features/reimbursement/models/reimbursement_models/travel_detail_model.dart';
import 'dart:async';

class ReimbursementTablePage extends StatefulWidget {
  const ReimbursementTablePage({super.key});

  @override
  State<ReimbursementTablePage> createState() => _ReimbursementTablePageState();
}

class _ReimbursementTablePageState extends State<ReimbursementTablePage> {
  late List<ReimbursementNote> allNotes;
  late List<ReimbursementNote> masterList;
  late List<ReimbursementNote> filteredNotes;
  List<ReimbursementNote> paginatedNotes = [];
  int rowsPerPage = 10;
  int currentPage = 0;
  
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  String searchQuery = '';
  String? statusFilter;
  bool _isLoading = false;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  void _loadData() {
    setState(() {
      _isLoading = true;
    });
    
    // Simulate loading data
    allNotes = List<ReimbursementNote>.from(dummyReimbursementNotes);
    masterList = List<ReimbursementNote>.from(allNotes);
    filteredNotes = List<ReimbursementNote>.from(allNotes);
    
    setState(() {
      _isLoading = false;
      currentPage = 0;
      _updatePagination();
    });
  }
  
  
  void _applyFrontendFilters() {
    setState(() {
      filteredNotes = masterList.where((note) {
        final matchesStatus = statusFilter == null || 
            note.status.toLowerCase().contains(statusFilter!.toLowerCase());
        
        final matchesSearch = searchQuery.isEmpty ||
            note.projectName.toLowerCase().contains(searchQuery) ||
            note.employeeName.toLowerCase().contains(searchQuery) ||
            note.amount.toLowerCase().contains(searchQuery) ||
            note.status.toLowerCase().contains(searchQuery);
        
        return matchesStatus && matchesSearch;
      }).toList();
      
      _updatePagination();
    });
  }
  
  void _onSearchChanged(String value) {
    if (!mounted) return;
    
    _debounceTimer?.cancel();
    
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      if (mounted) {
        setState(() {
          searchQuery = value.toLowerCase();
          currentPage = 0;
        });
        _applyFrontendFilters();
      }
    });
  }
  
  void _onSearchSubmitted() {
    _debounceTimer?.cancel();
    if (mounted) {
      setState(() {
        searchQuery = _searchController.text.toLowerCase();
        currentPage = 0;
      });
      _applyFrontendFilters();
    }
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
    
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _loadData();
        setState(() {
          _isRefreshing = false;
        });
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
                      currentPage = 0;
                      _applyFrontendFilters();
                    });
                  },
                ),
              ),
              ListTile(
                title: const Text('Pending'),
                leading: Radio<String?>(
                  value: 'Pending',
                  groupValue: statusFilter,
                  onChanged: (value) {
                    Navigator.pop(context);
                    setState(() {
                      statusFilter = value;
                      currentPage = 0;
                      _applyFrontendFilters();
                    });
                  },
                ),
              ),
              ListTile(
                title: const Text('Approved'),
                leading: Radio<String?>(
                  value: 'Approved',
                  groupValue: statusFilter,
                  onChanged: (value) {
                    Navigator.pop(context);
                    setState(() {
                      statusFilter = value;
                      currentPage = 0;
                      _applyFrontendFilters();
                    });
                  },
                ),
              ),
              ListTile(
                title: const Text('Rejected'),
                leading: Radio<String?>(
                  value: 'Rejected',
                  groupValue: statusFilter,
                  onChanged: (value) {
                    Navigator.pop(context);
                    setState(() {
                      statusFilter = value;
                      currentPage = 0;
                      _applyFrontendFilters();
                    });
                  },
                ),
              ),
              ListTile(
                title: const Text('Paid'),
                leading: Radio<String?>(
                  value: 'Paid',
                  groupValue: statusFilter,
                  onChanged: (value) {
                    Navigator.pop(context);
                    setState(() {
                      statusFilter = value;
                      currentPage = 0;
                      _applyFrontendFilters();
                    });
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

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _updatePagination() {
    final start = currentPage * rowsPerPage;
    final end = (start + rowsPerPage).clamp(0, filteredNotes.length);
    paginatedNotes = filteredNotes.sublist(start, end);
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


  void onAddNote() {
    // Navigate to create reimbursement form page
    context.go('/reimbursement-note/create');
  }

  void onEditNote(ReimbursementNote note) {
    context.go('/reimbursement-note/edit/${note.id}');
  }

  void onViewNote(ReimbursementNote note) {
    context.go('/reimbursement-note/view/${note.id}');
  }

  Future<void> onDeleteNote(ReimbursementNote note) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: Text("Are you sure you want to delete ${note.projectName}?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
    if (shouldDelete == true) {
      setState(() {
        allNotes.removeWhere((n) => n.sNo == note.sNo);
        masterList.removeWhere((n) => n.sNo == note.sNo);
        filteredNotes.removeWhere((n) => n.sNo == note.sNo);
        final totalPagesNow = (filteredNotes.isEmpty ? 1 : (filteredNotes.length / rowsPerPage).ceil());
        if (currentPage >= totalPagesNow && currentPage > 0) {
          currentPage = totalPagesNow - 1;
        }
        _updatePagination();
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${note.projectName} deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: _isLoading && masterList.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: 16),
                    _buildTableSection(context),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline,
          width: 0.5,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isSmallScreen = constraints.maxWidth < 600;
          
          if (isSmallScreen) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.receipt_long,
                        size: 28,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Reimbursement Notes',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Manage employee travel and expense reimbursements',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    icon: Icons.add,
                    label: 'Add Note',
                    onPressed: onAddNote,
                  ),
                ),
              ],
            );
          }
          
          return Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.receipt_long,
                  size: 28,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reimbursement Notes',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage employee travel and expense reimbursements',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              PrimaryButton(
                icon: Icons.add,
                label: 'Add Note',
                onPressed: onAddNote,
              ),
            ],
          );
        },
      ),
    );
  }


  Widget _buildTableSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: colorScheme.outline,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.grid_view,
                      color: colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'All Reimbursement Notes',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Wrap(
                spacing: 8,
                children: [
                  SecondaryButton(
                    icon: Icons.filter_list,
                    label: statusFilter == null ? 'Filter' : 'Filter: ${statusFilter ?? ""}',
                    onPressed: _showFilterDialog,
                  ),
                  SecondaryButton(
                    icon: Icons.refresh,
                    label: 'Refresh',
                    onPressed: _refreshData,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Manage and monitor all reimbursement requests',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 16),
          // Search bar
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 400),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onChanged: (value) {
                if (mounted) {
                  _onSearchChanged(value);
                }
              },
              onSubmitted: (_) => _onSearchSubmitted(),
              decoration: InputDecoration(
                hintText: 'Search by project, employee, amount...',
                hintStyle: TextStyle(
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                  size: 20,
                ),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: colorScheme.onSurface.withValues(alpha: 0.5),
                          size: 20,
                        ),
                        onPressed: () {
                          if (mounted && _searchController.text.isNotEmpty) {
                            _searchController.clear();
                            _onSearchChanged('');
                          }
                        },
                      )
                    : null,
                filled: true,
                fillColor: colorScheme.surface,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: colorScheme.outline),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: colorScheme.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: colorScheme.primary, width: 2),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _isLoading
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              : paginatedNotes.isEmpty
                  ? _buildEmptyState(context)
                  : _buildTable(context),
          if (paginatedNotes.isNotEmpty && !_isLoading)
            _buildPagination(context),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              searchQuery.isNotEmpty || statusFilter != null
                  ? 'No matching reimbursements found'
                  : 'No reimbursement notes found',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              searchQuery.isNotEmpty || statusFilter != null
                  ? 'Try adjusting your search or filter criteria'
                  : 'Showing 0 to 0 of 0 entries',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTable(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final columns = [
      DataColumn(
        label: Text('#', style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.w600)),
      ),
      DataColumn(
        label: Text('Project', style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.w600)),
      ),
      DataColumn(
        label: Text('Employee', style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.w600)),
      ),
      DataColumn(
        label: Text('Amount', style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.w600)),
      ),
      DataColumn(
        label: Text('Date', style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.w600)),
      ),
      DataColumn(
        label: Text('Status', style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.w600)),
      ),
      DataColumn(
        label: Text('Actions', style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.w600)),
      ),
    ];

    final rows = paginatedNotes.asMap().entries.map((entry) {
      final index = entry.key;
      final note = entry.value;

      return DataRow(
        cells: [
          DataCell(
            Text(
              '${index + 1}',
              style: TextStyle(color: colorScheme.onSurface, fontSize: 13),
            ),
          ),
          DataCell(
            Text(
              note.projectName.isEmpty ? 'N/A' : note.projectName,
              style: TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
          DataCell(
            Text(
              note.employeeName.isEmpty ? 'N/A' : note.employeeName,
              style: TextStyle(color: Colors.black87, fontSize: 13),
            ),
          ),
          DataCell(
            Text(
              '₹${note.amount}',
              style: TextStyle(color: Colors.black87, fontSize: 13),
            ),
          ),
          DataCell(
            Text(
              note.date.isEmpty ? 'N/A' : note.date,
              style: TextStyle(color: Colors.black87, fontSize: 13),
            ),
          ),
          DataCell(
            BadgeChip(
              label: note.status,
              type: ChipType.status,
              statusKey: note.status,
              statusColorFunc: _getStatusColor,
            ),
          ),
          DataCell(
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () => onViewNote(note),
                  icon: const Icon(Icons.visibility_outlined),
                  color: colorScheme.primary,
                  iconSize: 20,
                  tooltip: 'View',
                  style: IconButton.styleFrom(
                    backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  onPressed: () => onEditNote(note),
                  icon: const Icon(Icons.edit_outlined),
                  color: colorScheme.tertiary,
                  iconSize: 20,
                  tooltip: 'Edit',
                  style: IconButton.styleFrom(
                    backgroundColor: colorScheme.tertiary.withValues(alpha: 0.1),
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  onPressed: () => onDeleteNote(note),
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

    return CustomTable(
      minTableWidth: 1200,
      columns: columns,
      rows: rows,
    );
  }

  Color _getStatusColor(String status) {
    // Use primary color for all statuses to maintain consistency
    return Theme.of(context).colorScheme.primary;
  }

  Widget _buildPagination(BuildContext context) {
    return CustomPaginationBar(
      currentPage: currentPage,
      totalItems: filteredNotes.length,
      rowsPerPage: rowsPerPage,
      onPageChanged: (page) {
        setState(() {
          currentPage = page;
          _updatePagination();
        });
      },
      onRowsPerPageChanged: (value) {
        setState(() {
          rowsPerPage = value ?? 10;
          currentPage = 0;
          _updatePagination();
        });
      },
    );
  }

}
