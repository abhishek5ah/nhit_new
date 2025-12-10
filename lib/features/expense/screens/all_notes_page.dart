import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ppv_components/common_widgets/custom_table.dart';
import 'package:ppv_components/common_widgets/badge.dart';
import 'package:ppv_components/common_widgets/custom_pagination.dart';
import 'package:ppv_components/common_widgets/button/primary_button.dart';
import 'package:ppv_components/common_widgets/button/secondary_button.dart';
import '../widgets/view_green_note_detail.dart';
import '../widgets/edit_green_note_content.dart';
import '../models/green_note_model.dart';
import '../services/green_note_service.dart';
import '../services/green_note_api_client.dart';

class AllNotesPage extends StatefulWidget {
  const AllNotesPage({Key? key}) : super(key: key);

  @override
  State<AllNotesPage> createState() => _AllNotesPageState();
}

class _AllNotesPageState extends State<AllNotesPage> with SingleTickerProviderStateMixin {
  // Controllers
  late TextEditingController searchController;
  late TabController _tabController;

  // Backend API integration
  final GreenNoteService _greenNoteService = GreenNoteService();
  bool _isLoading = false;

  // State variables
  int currentPage = 0;
  int rowsPerPage = 10;
  int selectedTabIndex = 0;
  String? statusFilter;
  GreenNote? _activeNote;
  bool _isViewingNote = false;
  bool _isEditingNote = false;
  static const String _filterValueReset = '__filter_reset__';
  static const String _filterValueAll = '__filter_all__';
  final List<String> _filterStatusOptions = const [
    'All',
    'Pending',
    'Approved',
    'Rejected',
    'Draft',
    'Cancelled',
  ];
  
  // Data lists
  List<GreenNote> allNotes = [];
  List<GreenNote> filteredNotes = [];
  List<GreenNote> paginatedNotes = [];

  @override
  void initState() {
    super.initState();
    // Initialize API client
    GreenNoteApiClient().initialize();
    
    searchController = TextEditingController();
    _tabController = TabController(length: 5, vsync: this);
    
    // Load data from backend
    _loadNotes();
    
    // Add listener to tab changes
    _tabController.addListener(_handleTabChange);
  }

  Future<void> _loadNotes() async {
    setState(() => _isLoading = true);
    try {
      final notes = await _greenNoteService.listGreenNotes(
        page: currentPage + 1,
        pageSize: 100, // Load all for client-side filtering
      );
      
      if (mounted) {
        setState(() {
          allNotes = notes;
          _filterNotes();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load notes: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      _filterNotes();
    }
  }

  void _updatePagination() {
    final start = currentPage * rowsPerPage;
    final end = (start + rowsPerPage).clamp(0, filteredNotes.length);
    setState(() {
      paginatedNotes = filteredNotes.sublist(
        start, 
        end < filteredNotes.length ? end : filteredNotes.length
      );
    });
  }

  void _filterNotes() {
    final searchTerm = searchController.text.toLowerCase();
    
    // Apply tab filter
    List<GreenNote> workingList;
    if (_tabController.index == 0) {
      workingList = List<GreenNote>.from(allNotes);
    } else {
      final status = _getStatusForTab(_tabController.index);
      workingList = allNotes.where((note) =>
          note.status.toLowerCase() == status.toLowerCase()).toList();
    }

    if (statusFilter != null) {
      workingList = workingList
          .where((note) => note.status.toLowerCase() == statusFilter!.toLowerCase())
          .toList();
    }

    // Apply search filter
    if (searchTerm.isNotEmpty) {
      workingList = workingList.where((note) {
        return note.projectName.toLowerCase().contains(searchTerm) ||
               note.supplierName.toLowerCase().contains(searchTerm) ||
               note.totalAmount.toString().contains(searchTerm) ||
               note.workOrderNo.toLowerCase().contains(searchTerm);
      }).toList();
    }

    filteredNotes = workingList;
    // Reset to first page when filters change
    currentPage = 0;
    _updatePagination();
  }

  String _getStatusForTab(int tabIndex) {
    switch (tabIndex) {
      case 1: return 'Pending';
      case 2: return 'Approved';
      case 3: return 'Rejected';
      case 4: return 'Draft';
      default: return '';
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      case 'draft':
        return Colors.grey;
      default:
        return Colors.blueGrey;
    }
  }

  void changeRowsPerPage(int? value) {
    if (value != null && mounted) {
      setState(() {
        rowsPerPage = value;
        currentPage = 0;
        _updatePagination();
      });
    }
  }

  void gotoPage(int page) {
    setState(() {
      currentPage = page;
      _updatePagination();
    });
  }

  void _openViewNote(GreenNote note) {
    setState(() {
      _activeNote = note;
      _isViewingNote = true;
      _isEditingNote = false;
    });
  }

  void _openEditNote(GreenNote note) {
    setState(() {
      _activeNote = note;
      _isViewingNote = false;
      _isEditingNote = true;
    });
  }

  void _closeDetailView() {
    setState(() {
      _activeNote = null;
      _isViewingNote = false;
      _isEditingNote = false;
    });
  }

  void _handleFilterSelection(String selection) {
    setState(() {
      if (selection == _filterValueReset) {
        statusFilter = null;
        searchController.clear();
      } else if (selection == _filterValueAll) {
        statusFilter = null;
      } else {
        statusFilter = selection;
      }
      currentPage = 0;
    });
    _filterNotes();
  }

  Future<void> _cancelExpenseNote(GreenNote note) async {
    // Show dialog to get cancel reason
    final TextEditingController reasonController = TextEditingController();
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Note'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to cancel ${note.projectName.isEmpty ? 'this note' : note.projectName}?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Cancel Reason *',
                hintText: 'Enter reason for cancellation',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          FilledButton(
            onPressed: () {
              if (reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cancel reason is required'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              Navigator.of(context).pop(true);
            },
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (shouldCancel == true && note.id != null) {
      try {
        await _greenNoteService.cancelGreenNote(
          note.id!,
          cancelReason: reasonController.text.trim(),
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Note cancelled successfully'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          // Reload notes
          _loadNotes();
        }
      } catch (e) {
        print('❌ Error cancelling note: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to cancel note: ${e.toString()}'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
    reasonController.dispose();
  }

  void _updateNote(GreenNote updatedNote) {
    setState(() {
      final index = allNotes.indexWhere((note) => note.id == updatedNote.id);
      if (index != -1) {
        allNotes[index] = updatedNote;
      }
    });
    _filterNotes();
  }

  Future<void> _saveEditedNote(GreenNote updatedNote) async {
    try {
      await _greenNoteService.updateGreenNote(updatedNote.id!, updatedNote);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Green Note updated successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        
        // Reload notes from backend
        await _loadNotes();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update note: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
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
                  'All Expense Notes',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage and track expense note requests and approvals',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          PrimaryButton(
            label: 'Create Expense Note',
            icon: Icons.add,
            onPressed: () {
              context.go('/expense/create-note');
            },
          ),
        ],
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
              Row(
                children: [
                  Icon(
                    Icons.grid_view,
                    color: colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'All Expense Notes',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  PopupMenuButton<String>(
                    onSelected: _handleFilterSelection,
                    offset: const Offset(0, 40),
                    child: SecondaryButton(
                      icon: Icons.filter_list,
                      label: statusFilter == null ? 'Filter' : 'Filter: $statusFilter',
                      onPressed: null,
                    ),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: _filterValueReset,
                        child: Row(
                          children: [
                            Icon(Icons.refresh, size: 18, color: colorScheme.primary),
                            const SizedBox(width: 8),
                            const Text('Reset All'),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      ..._filterStatusOptions.map((option) {
                        final value = option == 'All' ? _filterValueAll : option;
                        return PopupMenuItem(
                          value: value,
                          child: Row(
                            children: [
                              if (statusFilter == null && option == 'All' || statusFilter == option)
                                Icon(Icons.check, size: 18, color: colorScheme.primary)
                              else
                                const SizedBox(width: 18),
                              const SizedBox(width: 8),
                              Text(option),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                  const SizedBox(width: 8),
                  SecondaryButton(
                    icon: Icons.refresh,
                    label: 'Refresh',
                    onPressed: () {
                      setState(() {
                        statusFilter = null;
                        searchController.clear();
                      });
                      _filterNotes();
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Manage and track expense note requests and approvals',
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
              controller: searchController,
              textInputAction: TextInputAction.search,
              onChanged: (value) {
                setState(() {
                  currentPage = 0;
                  _filterNotes();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search by project, vendor, or amount...',
                hintStyle: TextStyle(
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                  size: 20,
                ),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: colorScheme.onSurface.withValues(alpha: 0.5),
                          size: 20,
                        ),
                        onPressed: () {
                          searchController.clear();
                          setState(() {
                            currentPage = 0;
                            _filterNotes();
                          });
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
          paginatedNotes.isEmpty
              ? _buildEmptyState(context)
              : _buildTable(context),
          if (paginatedNotes.isNotEmpty)
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
              searchController.text.isNotEmpty || statusFilter != null
                  ? 'No matching notes found'
                  : 'No expense notes found',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              searchController.text.isNotEmpty || statusFilter != null
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

  Widget _buildPagination(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: CustomPaginationBar(
        totalItems: filteredNotes.length,
        currentPage: currentPage,
        rowsPerPage: rowsPerPage,
        availableRowsPerPage: const [5, 10, 20, 50],
        onRowsPerPageChanged: changeRowsPerPage,
        onPageChanged: gotoPage,
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
        label: Text('Project Name', style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.w600)),
      ),
      DataColumn(
        label: Text('Vendor Name', style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.w600)),
      ),
      DataColumn(
        label: Text('Invoice Amount', style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.w600)),
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

    final rows = List.generate(paginatedNotes.length, (index) {
      final note = paginatedNotes[index];

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
              note.supplierName.isEmpty ? 'N/A' : note.supplierName,
              style: TextStyle(color: Colors.black87, fontSize: 13),
            ),
          ),
          DataCell(
            Text(
              '₹${note.totalAmount.toStringAsFixed(2)}',
              style: TextStyle(
                color: Colors.green.shade700,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          DataCell(
            Text(
              note.createdAt ?? 'N/A',
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
                // View Icon Button
                IconButton(
                  onPressed: () => _openViewNote(note),
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
                  onPressed: () => _openEditNote(note),
                  icon: const Icon(Icons.edit_outlined),
                  color: colorScheme.tertiary,
                  iconSize: 20,
                  tooltip: 'Edit',
                  style: IconButton.styleFrom(
                    backgroundColor: colorScheme.tertiary.withValues(alpha: 0.1),
                  ),
                ),
                const SizedBox(width: 4),
                // Cancel Icon Button
                IconButton(
                  onPressed: () => _cancelExpenseNote(note),
                  icon: const Icon(Icons.cancel_outlined),
                  color: colorScheme.error,
                  iconSize: 20,
                  tooltip: 'Cancel',
                  style: IconButton.styleFrom(
                    backgroundColor: colorScheme.error.withValues(alpha: 0.1),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });

    return CustomTable(
      columns: columns,
      rows: rows,
    );
  }


  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    // View mode
    if (_isViewingNote && _activeNote != null) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        body: ViewGreenNoteDetail(
          note: _activeNote!,
          onClose: _closeDetailView,
        ),
      );
    }

    // Edit mode
    if (_isEditingNote && _activeNote != null) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        body: EditGreenNoteContent(
          note: _activeNote!,
          onSave: (updatedNote) async {
            await _saveEditedNote(updatedNote);
            _closeDetailView();
          },
          onCancel: _closeDetailView,
        ),
      );
    }
    
    // List view
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: colorScheme.primary),
                  const SizedBox(height: 16),
                  Text(
                    'Loading notes...',
                    style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
                  ),
                ],
              ),
            )
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
}
