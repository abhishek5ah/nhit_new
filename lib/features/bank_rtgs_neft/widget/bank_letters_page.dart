import 'package:flutter/material.dart';
import 'package:ppv_components/common_widgets/button/primary_button.dart';
import 'package:ppv_components/common_widgets/button/outlined_button.dart';
import 'package:ppv_components/common_widgets/button/secondary_button.dart';
import 'package:ppv_components/common_widgets/custom_pagination.dart';
import 'package:ppv_components/common_widgets/custom_table.dart';
import 'package:ppv_components/common_widgets/badge.dart';
import 'package:ppv_components/features/bank_rtgs_neft/widget/edit_bank_letter_content.dart';
// import 'package:ppv_components/features/bank_rtgs_neft/widget/%20edit_bank_letter_content.dart';
import 'package:ppv_components/features/bank_rtgs_neft/widget/escrow_accounts_page.dart';
import 'package:ppv_components/features/bank_rtgs_neft/widget/account_transfers_page.dart';
import 'package:ppv_components/features/bank_rtgs_neft/widget/create_bank_letter_page.dart';
import 'package:ppv_components/features/bank_rtgs_neft/models/bank_models/bank_letter_model.dart';
import 'package:ppv_components/features/bank_rtgs_neft/data/bank_dummydata/bank_letter_dummy.dart';
import 'package:ppv_components/features/bank_rtgs_neft/widget/view_bank_letter_detail.dart';

class BankLettersPage extends StatefulWidget {
  const BankLettersPage({super.key});

  @override
  State<BankLettersPage> createState() => _BankLettersPageState();
}

class _BankLettersPageState extends State<BankLettersPage> {
  int rowsPerPage = 10;
  int currentPage = 0;
  String searchQuery = '';
  String? statusFilter;

  late List<BankLetter> filteredLetters;
  late List<BankLetter> paginatedLetters;
  late List<BankLetter> allLetters;

  // Edit and View mode state
  bool _isEditMode = false;
  bool _isViewMode = false;
  BankLetter? _letterToEdit;

  @override
  void initState() {
    super.initState();
    allLetters = List<BankLetter>.from(bankLetterDummyData);
    filteredLetters = allLetters;
    _updatePagination();
  }

  void _updatePagination() {
    final start = currentPage * rowsPerPage;
    final end = (start + rowsPerPage).clamp(0, filteredLetters.length);
    paginatedLetters = filteredLetters.sublist(start, end);
  }

  void changeRowsPerPage(int? value) {
    if (value != null) {
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

  void updateSearch(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
      _applyFilters();
      currentPage = 0;
      _updatePagination();
    });
  }

  void _applyFilters() {
    filteredLetters = allLetters.where((letter) {
      final matchesSearch = searchQuery.isEmpty ||
          letter.reference.toLowerCase().contains(searchQuery) ||
          letter.type.toLowerCase().contains(searchQuery) ||
          letter.subject.toLowerCase().contains(searchQuery) ||
          letter.status.toLowerCase().contains(searchQuery);

      final matchesStatus = statusFilter == null ||
          statusFilter == 'All' ||
          letter.status == statusFilter;

      return matchesSearch && matchesStatus;
    }).toList();
  }

  void _refreshData() {
    setState(() {
      statusFilter = null;
      searchQuery = '';
      filteredLetters = allLetters;
      currentPage = 0;
      _updatePagination();
    });
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Filter Bank Letters'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('All'),
                leading: Radio<String?>(
                  value: null,
                  groupValue: statusFilter,
                  onChanged: (value) {
                    setState(() {
                      statusFilter = value;
                    });
                    Navigator.pop(context);
                    _applyFilters();
                    _updatePagination();
                  },
                ),
              ),
              ListTile(
                title: const Text('Sent'),
                leading: Radio<String>(
                  value: 'Sent',
                  groupValue: statusFilter,
                  onChanged: (value) {
                    setState(() {
                      statusFilter = value;
                    });
                    Navigator.pop(context);
                    _applyFilters();
                    _updatePagination();
                  },
                ),
              ),
              ListTile(
                title: const Text('Pending Approval'),
                leading: Radio<String>(
                  value: 'Pending Approval',
                  groupValue: statusFilter,
                  onChanged: (value) {
                    setState(() {
                      statusFilter = value;
                    });
                    Navigator.pop(context);
                    _applyFilters();
                    _updatePagination();
                  },
                ),
              ),
              ListTile(
                title: const Text('Draft'),
                leading: Radio<String>(
                  value: 'Draft',
                  groupValue: statusFilter,
                  onChanged: (value) {
                    setState(() {
                      statusFilter = value;
                    });
                    Navigator.pop(context);
                    _applyFilters();
                    _updatePagination();
                  },
                ),
              ),
              ListTile(
                title: const Text('Approved'),
                leading: Radio<String>(
                  value: 'Approved',
                  groupValue: statusFilter,
                  onChanged: (value) {
                    setState(() {
                      statusFilter = value;
                    });
                    Navigator.pop(context);
                    _applyFilters();
                    _updatePagination();
                  },
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'sent':
        return Colors.green;
      case 'pending approval':
        return Colors.orange;
      case 'draft':
        return Colors.grey;
      case 'approved':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  void onViewLetter(BankLetter letter) {
    setState(() {
      _isViewMode = true;
      _isEditMode = false;
      _letterToEdit = letter;
    });
  }

  void onEditLetter(BankLetter letter) {
    setState(() {
      _isEditMode = true;
      _isViewMode = false;
      _letterToEdit = letter;
    });
  }

  void _saveEditedLetter(BankLetter updatedLetter) {
    final index = allLetters.indexWhere((l) => l.id == _letterToEdit!.id);
    if (index != -1) {
      setState(() {
        allLetters[index] = updatedLetter;
        _isEditMode = false;
        _isViewMode = false;
        _letterToEdit = null;
        _applyFilters();
        _updatePagination();
      });
    }
  }

  void _cancelEdit() {
    setState(() {
      _isEditMode = false;
      _isViewMode = false;
      _letterToEdit = null;
    });
  }

  Future<void> deleteLetter(BankLetter letter) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete bank letter ${letter.reference}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (shouldDelete == true) {
      setState(() {
        allLetters.removeWhere((l) => l.id == letter.id);
        _applyFilters();
        _updatePagination();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: _letterToEdit != null
          ? (_isEditMode
              ? EditBankLetterContent(
                  letter: _letterToEdit!,
                  onSave: _saveEditedLetter,
                  onCancel: _cancelEdit,
                )
              : ViewBankLetterDetail(
                  letter: _letterToEdit!,
                  onClose: _cancelEdit,
                ))
          : LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal:24, vertical:24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(context, constraints),
                        const SizedBox(height: 16),
                        _buildStatsCards(context, constraints),
                        const SizedBox(height: 16),
                        _buildTableSection(context, constraints),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildHeader(BuildContext context, BoxConstraints constraints) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final isSmallScreen = constraints.maxWidth < 900;

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline,
          width: 0.5,
        ),
      ),
      child: Column(
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
                  Icons.description,
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
                      'All Bank Letters',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage and track all bank correspondence',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              if (!isSmallScreen) ...[
                const SizedBox(width: 16),
                SecondaryButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icons.arrow_back,
                  label: 'Back',
                ),
              ],
            ],
          ),
          if (isSmallScreen) ...[
            const SizedBox(height: 16),
            SecondaryButton(
              onPressed: () => Navigator.pop(context),
              icon: Icons.arrow_back,
              label: 'Back',
            ),
          ],
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              PrimaryButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateBankLetterPage(),
                    ),
                  );
                },
                icon: Icons.add,
                label: 'New Letter',
              ),
              SecondaryButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EscrowAccountsPage(),
                    ),
                  );
                },
                icon: Icons.account_balance_wallet,
                label: 'Escrow Accounts',
              ),
              SecondaryButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AccountTransfersPage(),
                    ),
                  );
                },
                icon: Icons.swap_horiz,
                label: 'Transfers',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(BuildContext context, BoxConstraints constraints) {
    final colorScheme = Theme.of(context).colorScheme;

    int crossAxisCount = 4;
    if (constraints.maxWidth < 600) {
      crossAxisCount = 1;
    } else if (constraints.maxWidth < 900) {
      crossAxisCount = 2;
    }

    final stats = [
      {
        'icon': Icons.description,
        'label': 'Total Letters',
        'value': '${allLetters.length}',
        'color': Colors.blue,
      },
      {
        'icon': Icons.pending_actions,
        'label': 'Pending Approval',
        'value': '${allLetters.where((l) => l.status == "Pending Approval").length}',
        'color': Colors.orange,
      },
      {
        'icon': Icons.send,
        'label': 'Sent Letters',
        'value': '${allLetters.where((l) => l.status == "Sent").length}',
        'color': Colors.green,
      },
      {
        'icon': Icons.drafts,
        'label': 'Draft Letters',
        'value': '${allLetters.where((l) => l.status == "Draft").length}',
        'color': Colors.grey,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: crossAxisCount == 1
            ? 4.5
            : (crossAxisCount == 2 ? 2.8 : 2.5),
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return _buildStatCard(
          context,
          icon: stat['icon'] as IconData,
          label: stat['label'] as String,
          value: stat['value'] as String,
          color: stat['color'] as Color,
        );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline,
          width: 0.5,
        ),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: IntrinsicHeight(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: color,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.visible,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                maxLines: 2,
                overflow: TextOverflow.visible,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTableSection(BuildContext context, BoxConstraints constraints) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final isSmallScreen = constraints.maxWidth < 900;

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.table_chart,
                color: colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'All Bank Letters',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              if (!isSmallScreen) ...[
                SecondaryButton(
                  onPressed: _showFilterDialog,
                  icon: Icons.filter_list,
                  label: statusFilter == null ? 'Filter' : 'Filter: $statusFilter',
                ),
                const SizedBox(width: 12),
                SecondaryButton(
                  onPressed: _refreshData,
                  icon: Icons.refresh,
                  label: 'Refresh',
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Manage and track bank correspondence',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 16),

          CustomTable(
            columns: [
              DataColumn(
                label: Text(
                  '#',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'REFERENCE',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'TYPE',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'SUBJECT',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'BANK',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'STATUS',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'CREATED BY',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'ACTIONS',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ],
            rows: paginatedLetters.isEmpty
                ? []
                : paginatedLetters.asMap().entries.map((entry) {
                    final index = entry.key;
                    final letter = entry.value;
                    return DataRow(
                      cells: [
                        DataCell(Text('${currentPage * rowsPerPage + index + 1}')),
                        DataCell(Text(letter.reference)),
                        DataCell(Text(letter.type)),
                        DataCell(Text(letter.subject)),
                        DataCell(Text(letter.bank)),
                        DataCell(
                          BadgeChip(
                            label: letter.status,
                            type: ChipType.status,
                            statusKey: letter.status,
                            statusColorFunc: _getStatusColor,
                          ),
                        ),
                        DataCell(Text(letter.createdBy)),
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // View Icon Button
                              IconButton(
                                onPressed: () => onViewLetter(letter),
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
                                onPressed: () => onEditLetter(letter),
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
                                onPressed: () => deleteLetter(letter),
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
                  }).toList(),
            minTableWidth: 1200,
          ),

          if (paginatedLetters.isEmpty) ...[
            const SizedBox(height: 40),
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 64,
                    color: colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No bank letters found',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],

          if (filteredLetters.isNotEmpty) ...[
            CustomPaginationBar(
              totalItems: filteredLetters.length,
              currentPage: currentPage,
              rowsPerPage: rowsPerPage,
              onPageChanged: gotoPage,
              onRowsPerPageChanged: changeRowsPerPage,
              availableRowsPerPage: const [5, 10, 20, 50],
            ),
          ],
        ],
      ),
    );
  }
}
