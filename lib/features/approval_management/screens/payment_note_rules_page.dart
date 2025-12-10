import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ppv_components/common_widgets/button/primary_button.dart';
import 'package:ppv_components/common_widgets/button/secondary_button.dart';
import 'package:ppv_components/common_widgets/custom_pagination.dart';
import 'package:ppv_components/common_widgets/custom_table.dart';
import 'package:ppv_components/common_widgets/badge.dart';
import 'package:ppv_components/features/approval_management/models/approval_rule_model.dart';
import 'package:ppv_components/features/approval_management/data/approval_rule_dummy.dart';
import 'package:ppv_components/features/approval_management/widgets/view_approval_rule_detail.dart';
import 'package:ppv_components/features/approval_management/widgets/edit_approval_rule_content.dart';
import 'package:intl/intl.dart';

class PaymentNoteRulesPage extends StatefulWidget {
  const PaymentNoteRulesPage({super.key});

  @override
  State<PaymentNoteRulesPage> createState() => _PaymentNoteRulesPageState();
}

class _PaymentNoteRulesPageState extends State<PaymentNoteRulesPage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  
  int rowsPerPage = 10;
  int currentPage = 0;
  List<ApprovalRule> paginatedRules = [];
  List<ApprovalRule> filteredRules = [];
  String? statusFilter;
  String searchQuery = '';
  List<ApprovalRule> masterList = List<ApprovalRule>.from(approvalRulesDummyData);
  int totalCount = 0;
  int? _hoveredCardIndex;
  bool _isLoading = false;
  bool _isRefreshing = false;
  final NumberFormat _amountFormat = NumberFormat('#,##,##0.00', 'en_IN');
  
  // Stats data
  int totalRules = 0;
  int activeRules = 0;
  int inactiveRules = 0;
  double avgApprovers = 0.0;

  // Edit and View mode state
  bool _isEditMode = false;
  ApprovalRule? _ruleToEdit;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData({bool showLoader = true}) async {
    await Future.wait([
      _loadStats(),
      _loadRules(showLoader: showLoader),
    ]);
  }

  Future<void> _loadStats() async {
    if (mounted) {
      setState(() {
        totalRules = masterList.length;
        activeRules = masterList.where((r) => r.status == 'Active').length;
        inactiveRules = masterList.where((r) => r.status == 'Inactive').length;
        avgApprovers = masterList.isEmpty
            ? 0.0
            : masterList.map((r) => r.approvers).reduce((a, b) => a + b) / masterList.length;
      });
    }
  }

  Future<void> _loadRules({bool showLoader = true}) async {
    if ((_isLoading && showLoader) || (_isRefreshing && !showLoader)) {
      return;
    }

    if (showLoader) {
      setState(() {
        _isLoading = true;
      });
    } else {
      setState(() {
        _isRefreshing = true;
      });
    }

    try {
      await Future.delayed(const Duration(milliseconds: 300));

      setState(() {
        filteredRules = masterList;
        totalCount = masterList.length;
        currentPage = 0;
        _updatePagination();
      });
    } finally {
      if (mounted) {
        setState(() {
          if (showLoader) {
            _isLoading = false;
          } else {
            _isRefreshing = false;
          }
        });
      }
    }
  }

  void _applyFilter() {
    setState(() {
      currentPage = 0;
    });
    _applyFrontendFilters();
  }

  void _applyFrontendFilters() {
    setState(() {
      filteredRules = masterList.where((rule) {
        final matchesStatus = statusFilter == null || 
            statusFilter == 'All' || 
            rule.status.toLowerCase() == statusFilter!.toLowerCase();
        
        final matchesSearch = searchQuery.isEmpty ||
            rule.ruleName.toLowerCase().contains(searchQuery) ||
            rule.amountRange.toLowerCase().contains(searchQuery) ||
            rule.status.toLowerCase().contains(searchQuery);
        
        return matchesStatus && matchesSearch;
      }).toList();
      
      _updatePagination();
    });
  }

  void _refreshData() {
    if (_isRefreshing) return;
    setState(() {
      statusFilter = null;
      searchQuery = '';
      _searchController.clear();
      currentPage = 0;
    });
    _loadData(showLoader: false);
  }
  
  void _onSearchChanged(String value) {
    if (!mounted) return;
    
    _debounceTimer?.cancel();
    
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      if (mounted) {
        setState(() {
          searchQuery = value.toLowerCase();
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

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Filter Rules'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('All'),
                leading: Radio<String?>(
                  value: null,
                  groupValue: statusFilter,
                  onChanged: (value) => _handleStatusSelection(context, value),
                ),
                onTap: () => _handleStatusSelection(context, null),
              ),
              ListTile(
                title: const Text('Active'),
                leading: Radio<String?>(
                  value: 'Active',
                  groupValue: statusFilter,
                  onChanged: (value) => _handleStatusSelection(context, value),
                ),
                onTap: () => _handleStatusSelection(context, 'Active'),
              ),
              ListTile(
                title: const Text('Inactive'),
                leading: Radio<String?>(
                  value: 'Inactive',
                  groupValue: statusFilter,
                  onChanged: (value) => _handleStatusSelection(context, value),
                ),
                onTap: () => _handleStatusSelection(context, 'Inactive'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleStatusSelection(BuildContext dialogContext, String? value) {
    setState(() {
      statusFilter = value;
    });
    Navigator.pop(dialogContext);
    _applyFilter();
  }

  void _updatePagination() {
    final start = currentPage * rowsPerPage;
    final end = (start + rowsPerPage).clamp(0, filteredRules.length);
    paginatedRules = filteredRules.sublist(start, end);
  }

  void changeRowsPerPage(int? value) {
    if (value == null) return;
    setState(() {
      rowsPerPage = value;
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'inactive':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  void copyRule(ApprovalRule rule) {
    final ruleData = 'Rule: ${rule.ruleName}\nAmount Range: ${rule.amountRange}\nApprovers: ${rule.approvers}\nLevels: ${rule.levels}\nStatus: ${rule.status}';
    Clipboard.setData(ClipboardData(text: ruleData));
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Rule data copied to clipboard'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> onViewRule(ApprovalRule rule) async {
    if (mounted) {
      setState(() {
        _isEditMode = false;
        _ruleToEdit = rule;
      });
    }
  }

  Future<void> onEditRule(ApprovalRule rule) async {
    if (mounted) {
      setState(() {
        _isEditMode = true;
        _ruleToEdit = rule;
      });
    }
  }

  Future<void> _saveEditedRule(ApprovalRule updatedRule) async {
    try {
      // UI-only: Update in masterList
      final index = masterList.indexWhere((r) => r.id == updatedRule.id);
      if (index != -1) {
        masterList[index] = updatedRule;
      }

      if (mounted) {
        setState(() {
          _isEditMode = false;
          _ruleToEdit = null;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Rule updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        
        await _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update rule: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _cancelEdit() {
    setState(() {
      _isEditMode = false;
      _ruleToEdit = null;
    });
  }

  Future<void> deleteRule(ApprovalRule rule) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete rule "${rule.ruleName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    
    if (shouldDelete == true) {
      try {
        // UI-only: Remove from masterList
        masterList.removeWhere((r) => r.id == rule.id);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Rule deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          
          await _loadData();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete rule: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
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
          : _ruleToEdit != null
          ? (_isEditMode
          ? EditApprovalRuleContent(
        rule: _ruleToEdit!,
        onSave: _saveEditedRule,
        onCancel: _cancelEdit,
      )
          : ViewApprovalRuleDetail(
        rule: _ruleToEdit!,
        onClose: _cancelEdit,
      ))
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal:24, vertical:24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 16),
              _buildStatsCards(context),
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
          final isCompact = constraints.maxWidth < 700;

          final infoRow = Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.rule_folder,
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
                      'Payment Note Rules',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage approval rules and workflows for payment notes',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );

          final actionButton = PrimaryButton(
            icon: Icons.add,
            label: 'Create Rule',
            onPressed: () {
              // Navigate to create rule page
            },
          );

          if (isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                infoRow,
                const SizedBox(height: 16),
                actionButton,
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: infoRow),
              const SizedBox(width: 16),
              actionButton,
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatsCards(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth == double.infinity
            ? MediaQuery.of(context).size.width
            : constraints.maxWidth;
        final isCompact = maxWidth < 900;
        final cardWidth = isCompact ? maxWidth : (maxWidth - 48) / 4;

        Widget wrapCard(int index, Widget child) {
          return SizedBox(
            width: cardWidth,
            child: child,
          );
        }

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            wrapCard(
              0,
              _buildStatCard(
                context,
                index: 0,
                icon: Icons.rule,
                iconColor: colorScheme.primary.withValues(alpha: 0.1),
                iconForeground: colorScheme.primary,
                label: 'Total Rules',
                value: '$totalRules',
                badge: '$activeRules',
                badgeColor: colorScheme.primary.withValues(alpha: 0.1),
                badgeTextColor: colorScheme.primary,
              ),
            ),
            wrapCard(
              1,
              _buildStatCard(
                context,
                index: 1,
                icon: Icons.check_circle,
                iconColor: Colors.green.withValues(alpha: 0.1),
                iconForeground: Colors.green,
                label: 'Active Rules',
                value: '$activeRules',
                badge: '',
                badgeColor: Colors.transparent,
                badgeTextColor: Colors.transparent,
              ),
            ),
            wrapCard(
              2,
              _buildStatCard(
                context,
                index: 2,
                icon: Icons.cancel,
                iconColor: Colors.red.withValues(alpha: 0.1),
                iconForeground: Colors.red,
                label: 'Inactive Rules',
                value: '$inactiveRules',
                badge: '',
                badgeColor: Colors.transparent,
                badgeTextColor: Colors.transparent,
              ),
            ),
            wrapCard(
              3,
              _buildStatCard(
                context,
                index: 3,
                icon: Icons.people,
                iconColor: Colors.blue.withValues(alpha: 0.1),
                iconForeground: Colors.blue,
                label: 'Avg Approvers',
                value: avgApprovers.toStringAsFixed(1),
                badge: '',
                badgeColor: Colors.transparent,
                badgeTextColor: Colors.transparent,
              ),
            ),
          ],
        );
      },
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
          LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 700;

              final titleRow = Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.grid_view,
                    color: colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'All Payment Note Rules',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              );

              final actionButtons = Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: isCompact ? WrapAlignment.start : WrapAlignment.end,
                children: [
                  SecondaryButton(
                    icon: Icons.filter_list,
                    label: statusFilter == null ? 'Filter' : 'Filter: $statusFilter',
                    onPressed: _showFilterDialog,
                  ),
                  SecondaryButton(
                    icon: Icons.refresh,
                    label: 'Refresh',
                    onPressed: _refreshData,
                  ),
                ],
              );

              if (isCompact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    titleRow,
                    const SizedBox(height: 12),
                    actionButtons,
                  ],
                );
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(child: titleRow),
                  actionButtons,
                ],
              );
            },
          ),
          const SizedBox(height: 8),
          Text(
            'Manage and monitor all approval rules for payment notes',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 16),
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
                hintText: 'Search by rule name or amount range...',
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
              : paginatedRules.isEmpty
                  ? _buildEmptyState(context)
                  : _buildTable(context),
          if (filteredRules.isNotEmpty) ...[
            CustomPaginationBar(
              totalItems: filteredRules.length,
              currentPage: currentPage,
              rowsPerPage: rowsPerPage,
              availableRowsPerPage: const [5, 10, 20, 50],
              onRowsPerPageChanged: changeRowsPerPage,
              onPageChanged: gotoPage,
            ),
          ],
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
              Icons.rule_outlined,
              size: 64,
              color: colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              searchQuery.isNotEmpty || statusFilter != null
                  ? 'No matching rules found'
                  : 'No approval rules found',
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

  Widget _buildStatCard(
      BuildContext context, {
        required int index,
        required IconData icon,
        required Color iconColor,
        required Color iconForeground,
        required String label,
        required String value,
        required String badge,
        required Color badgeColor,
        required Color badgeTextColor,
      }) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final isHovered = _hoveredCardIndex == index;

    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _hoveredCardIndex = index;
        });
      },
      onExit: (_) {
        setState(() {
          _hoveredCardIndex = null;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        transform: Matrix4.identity()..scale(isHovered ? 1.02 : 1.0),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isHovered ? colorScheme.primary : colorScheme.outline,
            width: isHovered ? 1.5 : 0.5,
          ),
          boxShadow: isHovered
              ? [
            BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconForeground, size: 24),
                ),
                const Spacer(),
                if (badge.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      badge,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: badgeTextColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
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
        label: Text('Project', style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.w600)),
      ),
      DataColumn(
        label: Text('Department', style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.w600)),
      ),
      DataColumn(
        label: Text('Rule Name', style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.w600)),
      ),
      DataColumn(
        label: Text('Amount Rangejhhhhhhhhhhh', style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.w600)),
      ),
      DataColumn(
        label: Text('Approvers', style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.w600)),
      ),
      DataColumn(
        label: Text('Created', style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.w600)),
      ),
      DataColumn(
        label: Text('Status', style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.w600)),
      ),
      DataColumn(
        label: Text('Levels', style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.w600)),
      ),
      DataColumn(
        label: Text('Actions', style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.w600)),
      ),
    ];

    final rows = paginatedRules.map((rule) {
      return DataRow(
        cells: [
          DataCell(
            Text(
              rule.project,
              style: const TextStyle(color: Colors.black87, fontSize: 13),
            ),
          ),
          DataCell(
            Text(
              rule.department,
              style: const TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
          DataCell(
            Text(
              rule.ruleName,
              style: TextStyle(color: colorScheme.primary, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
          DataCell(
            Text(
              rule.amountRange,
              style: const TextStyle(color: Colors.black87, fontSize: 13),
            ),
          ),
          DataCell(
            Text(
              rule.approvers.toString(),
              style: const TextStyle(color: Colors.black87, fontSize: 13),
            ),
          ),
          DataCell(
            Text(
              rule.created,
              style: const TextStyle(color: Colors.black87, fontSize: 13),
            ),
          ),
          DataCell(
            BadgeChip(
              label: rule.status,
              type: ChipType.status,
              statusKey: rule.status,
              statusColorFunc: _getStatusColor,
            ),
          ),
          DataCell(
            _buildLevelsList(rule.ruleLevels),
          ),
          DataCell(
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () => onViewRule(rule),
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
                  onPressed: () => onEditRule(rule),
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
                  onPressed: () => copyRule(rule),
                  icon: const Icon(Icons.copy_outlined),
                  color: colorScheme.secondary,
                  iconSize: 20,
                  tooltip: 'Copy',
                  style: IconButton.styleFrom(
                    backgroundColor: colorScheme.secondary.withValues(alpha: 0.1),
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  onPressed: () => deleteRule(rule),
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

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 900),
        child: CustomTable(
          columns: columns,
          rows: rows,
        ),
      ),
    );
  }

  Widget _buildLevelsList(List<RuleLevel> levels) {
    if (levels.isEmpty) {
      return const Text(
        '• Level 1 – — – (0.00)',
        style: TextStyle(fontSize: 12),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: levels
          .map(
            (lvl) => Text(
              '• Level ${lvl.level} – ${lvl.approverName} – (${_amountFormat.format(lvl.amount)})',
              style: const TextStyle(fontSize: 12),
            ),
          )
          .toList(),
    );
  }
}
