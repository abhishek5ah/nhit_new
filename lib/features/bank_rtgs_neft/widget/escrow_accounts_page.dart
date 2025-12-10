import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ppv_components/common_widgets/button/primary_button.dart';
import 'package:ppv_components/common_widgets/button/secondary_button.dart';
import 'package:ppv_components/features/bank_rtgs_neft/models/escrow_account_response.dart' show EscrowAccount, EscrowAccountData;
import 'package:ppv_components/features/bank_rtgs_neft/services/escrow_account_service.dart';
import 'package:ppv_components/features/bank_rtgs_neft/services/api_client.dart';
import 'package:ppv_components/common_widgets/custom_table.dart';
import 'package:ppv_components/common_widgets/badge.dart';
import 'package:ppv_components/common_widgets/custom_pagination.dart';
import 'package:ppv_components/features/bank_rtgs_neft/widget/account_transfers_page.dart';
import 'package:ppv_components/features/bank_rtgs_neft/widget/escrow_accounts_edit_page.dart';
import 'package:ppv_components/features/bank_rtgs_neft/widget/view_escrow_account_detail.dart';

class EscrowAccountsPage extends StatefulWidget {
  const EscrowAccountsPage({
    super.key,
  });

  @override
  State<EscrowAccountsPage> createState() => _EscrowAccountsPageState();
}

class _EscrowAccountsPageState extends State<EscrowAccountsPage> {
  final EscrowAccountService _service = EscrowAccountService();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  
  int rowsPerPage = 10;
  int currentPage = 0;
  List<EscrowAccount> paginatedAccounts = [];
  List<EscrowAccount> filteredAccounts = [];
  String? statusFilter;
  String searchQuery = '';
  List<EscrowAccount> masterList = []; // Store all data for frontend filtering
  int totalCount = 0;
  int? _hoveredCardIndex;
  bool _isLoading = false;
  bool _isRefreshing = false;
  
  // Store EscrowAccountData mapping for operations that need account_id
  Map<String, EscrowAccountData> _accountDataMap = {};

  // Stats data
  int totalAccounts = 0;
  double totalBalance = 0.0;
  double availableBalance = 0.0;
  int activeAccounts = 0;

  // Edit and View mode state
  bool _isEditMode = false;
  EscrowAccountData? _accountToEdit;

  @override
  void initState() {
    super.initState();
    // Initialize API client before making any API calls
    ApiClient().initialize();
    _loadData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check if we need to refresh from navigation arguments
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map && args['refresh'] == true) {
      _loadData();
    }
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
      _loadAccounts(showLoader: showLoader),
    ]);
  }

  Future<void> _loadStats() async {
    try {
      final stats = await _service.getEscrowAccountStats();
      if (mounted) {
        setState(() {
          // Backend returns camelCase keys, not snake_case
          totalAccounts = stats['totalAccounts'] ?? 0;
          totalBalance = (stats['totalBalance'] ?? 0).toDouble();
          availableBalance = (stats['availableBalance'] ?? 0).toDouble();
          activeAccounts = stats['activeAccounts'] ?? 0;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load stats: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadAccounts({bool showLoader = true}) async {
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
      // Fetch ALL records from backend with high page_size (only once)
      final accountsData = await _service.listEscrowAccounts(
        page: 1,
        pageSize: 1000, // Fetch all records
        searchQuery: null, // No search filter on API
        statusFilter: null, // No status filter on API
      );

      print('🔍 DEBUG: Fetched ${accountsData.length} accounts from backend');
      if (accountsData.isNotEmpty) {
        print('🔍 DEBUG: First account data: ${accountsData.first.accountName}, ${accountsData.first.bankName}, ${accountsData.first.accountType}');
      }

      // Convert to UI model and build mapping
      final uiAccounts = _service.convertToEscrowAccounts(accountsData);
      
      print('🔍 DEBUG: Converted to ${uiAccounts.length} UI accounts');
      if (uiAccounts.isNotEmpty) {
        print('🔍 DEBUG: First UI account: ${uiAccounts.first.accountName}, ${uiAccounts.first.bank}, ${uiAccounts.first.type}');
      }
      
      // Store mapping from accountNumber to EscrowAccountData for ID lookups
      _accountDataMap.clear();
      for (var accountData in accountsData) {
        if (accountData.accountNumber.isNotEmpty) {
          _accountDataMap[accountData.accountNumber] = accountData;
        }
      }

      setState(() {
        masterList = uiAccounts; // Store all data
        filteredAccounts = uiAccounts; // Initialize filtered list
        totalCount = uiAccounts.length;
        currentPage = 0;
        _updatePagination();
      });
    } catch (e) {
      print('❌ ERROR loading accounts: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load accounts: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
      currentPage = 1;
    });
    _applyFrontendFilters(); // Filter locally, no API call
  }

  void _applyFrontendFilters() {
    setState(() {
      // Start with master list and apply both search and status filters
      filteredAccounts = masterList.where((account) {
        // Apply status filter
        final matchesStatus = statusFilter == null || 
            statusFilter == 'All' || 
            account.status.toLowerCase() == statusFilter!.toLowerCase();
        
        // Apply search filter
        final matchesSearch = searchQuery.isEmpty ||
            account.accountName.toLowerCase().contains(searchQuery) ||
            account.accountNumber.toLowerCase().contains(searchQuery) ||
            account.bank.toLowerCase().contains(searchQuery) ||
            account.type.toLowerCase().contains(searchQuery) ||
            account.status.toLowerCase().contains(searchQuery);
        
        return matchesStatus && matchesSearch;
      }).toList();
      
      // Update paginated accounts from filtered list
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
    _loadData(showLoader: false); // Refresh in background without blocking UI
  }
  
  void _onSearchChanged(String value) {
    // Only update if widget is still mounted
    if (!mounted) return;
    
    // Cancel previous timer
    _debounceTimer?.cancel();
    
    // Set up new timer for debounce (400ms)
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      if (mounted) {
        setState(() {
          searchQuery = value.toLowerCase();
        });
        _applyFrontendFilters(); // Filter locally, no API call
      }
    });
  }

  void _onSearchSubmitted() {
    // Immediate search on Enter or Search button click
    _debounceTimer?.cancel();
    if (mounted) {
      setState(() {
        searchQuery = _searchController.text.toLowerCase();
        currentPage = 0;
      });
      _applyFrontendFilters(); // Filter locally, no API call
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Filter Accounts'),
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
                    _applyFilter();
                  },
                ),
              ),
              ListTile(
                title: const Text('Active'),
                leading: Radio<String>(
                  value: 'Active',
                  groupValue: statusFilter,
                  onChanged: (value) {
                    setState(() {
                      statusFilter = value;
                    });
                    Navigator.pop(context);
                    _applyFilter();
                  },
                ),
              ),
              ListTile(
                title: const Text('Inactive'),
                leading: Radio<String>(
                  value: 'Inactive',
                  groupValue: statusFilter,
                  onChanged: (value) {
                    setState(() {
                      statusFilter = value;
                    });
                    Navigator.pop(context);
                    _applyFilter();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _updatePagination() {
    final start = currentPage * rowsPerPage;
    final end = (start + rowsPerPage).clamp(0, filteredAccounts.length);
    paginatedAccounts =
        filteredAccounts.sublist(start, end);
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
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> onViewAccount(EscrowAccount account) async {
    try {
      // Get account_id from the mapping
      final accountData = _accountDataMap[account.accountNumber];
      if (accountData == null) {
        throw Exception('Account data not found');
      }
      
      // Fetch full details using account_id
      final fullAccountData = await _service.getEscrowAccount(accountData.accountId);
      if (mounted) {
        setState(() {
          _isEditMode = false;
          _accountToEdit = fullAccountData;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load account details: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> onEditAccount(EscrowAccount account) async {
    try {
      // Get account_id from the mapping
      final accountData = _accountDataMap[account.accountNumber];
      if (accountData == null) {
        throw Exception('Account data not found');
      }
      
      // Fetch full details using account_id
      final fullAccountData = await _service.getEscrowAccount(accountData.accountId);
      if (mounted) {
        setState(() {
          _isEditMode = true;
          _accountToEdit = fullAccountData;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load account details: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveEditedAccount(EscrowAccountData updatedAccount) async {
    try {
      await _service.updateEscrowAccount(
        accountId: updatedAccount.accountId,
        accountName: updatedAccount.accountName,
        accountNumber: updatedAccount.accountNumber,
        bankName: updatedAccount.bankName,
        branchName: updatedAccount.branchName,
        ifscCode: updatedAccount.ifscCode,
        accountType: updatedAccount.accountType,
        description: updatedAccount.description,
        authorizedSignatories: updatedAccount.authorizedSignatories,
        status: updatedAccount.status,
      );

      if (mounted) {
        setState(() {
          _isEditMode = false;
          _accountToEdit = null;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Refresh both stats and table data
        await _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update account: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _cancelEdit() {
    setState(() {
      _isEditMode = false;
      _accountToEdit = null;
    });
  }

  Future<void> deleteAccount(EscrowAccount account) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete ${account.accountName}?'),
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
        // Get account_id from the mapping
        final accountData = _accountDataMap[account.accountNumber];
        if (accountData == null) {
          throw Exception('Account data not found');
        }
        
        // Delete using account_id
        await _service.deleteEscrowAccount(accountData.accountId);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Refresh both stats and table data
          await _loadData();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete account: ${e.toString()}'),
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
          : _accountToEdit != null
          ? (_isEditMode
          ? EditEscrowAccountContent(
        account: _accountToEdit!,
        onSave: _saveEditedAccount,
        onCancel: _cancelEdit,
      )
          : ViewEscrowAccountDetail(
        account: _accountToEdit!,
        onClose: _cancelEdit,
      ))
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.account_balance,
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
                  'Escrow Accounts',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage your organization\'s escrow accounts and fund transfers',
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
            label: 'Add Account',
            onPressed: () {
              GoRouter.of(context).go('/escrow-accounts/create');
            },
          ),

          const SizedBox(width: 12),
          SecondaryButton(
            icon: Icons.swap_horiz,
            label: 'View Transfers',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AccountTransfersPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            index: 0,
            icon: Icons.account_balance,
            iconColor: colorScheme.primary.withValues(alpha: 0.1),
            iconForeground: colorScheme.primary,
            label: 'Total Accounts',
            value: '$totalAccounts',
            badge: '$activeAccounts',
            badgeColor: colorScheme.primary.withValues(alpha: 0.1),
            badgeTextColor: colorScheme.primary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            context,
            index: 1,
            icon: Icons.currency_rupee,
            iconColor: Colors.green.withValues(alpha: 0.1),
            iconForeground: Colors.green,
            label: 'Total Balance',
            value: '₹${totalBalance.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
            badge: '',
            badgeColor: Colors.transparent,
            badgeTextColor: Colors.transparent,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            context,
            index: 2,
            icon: Icons.wallet,
            iconColor: Colors.blue.withValues(alpha: 0.1),
            iconForeground: Colors.blue,
            label: 'Available Balance',
            value: '₹${availableBalance.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
            badge: '',
            badgeColor: Colors.transparent,
            badgeTextColor: Colors.transparent,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            context,
            index: 3,
            icon: Icons.trending_up,
            iconColor: Colors.orange.withValues(alpha: 0.1),
            iconForeground: Colors.orange,
            label: 'Active Accounts',
            value: '$activeAccounts',
            badge: '',
            badgeColor: Colors.transparent,
            badgeTextColor: Colors.transparent,
          ),
        ),
      ],
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
                    'All Escrow Accounts',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  SecondaryButton(
                    icon: Icons.filter_list,
                    label: statusFilter == null ? 'Filter' : 'Filter: $statusFilter',
                    onPressed: _showFilterDialog,
                  ),
                  const SizedBox(width: 8),
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
            'Manage and monitor all escrow accounts',
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
                hintText: 'Search by account name, number, or bank...',
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
              : paginatedAccounts.isEmpty
                  ? _buildEmptyState(context)
                  : _buildTable(context),
          if (paginatedAccounts.isNotEmpty && !_isLoading)
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
              Icons.account_balance_outlined,
              size: 64,
              color: colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              searchQuery.isNotEmpty || statusFilter != null
                  ? 'No matching accounts found'
                  : 'No escrow accounts found',
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
        label: Text('#', style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.w600)),
      ),
      DataColumn(
        label: Text('Account Name', style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.w600)),
      ),
      DataColumn(
        label: Text('Account Number', style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.w600)),
      ),
      DataColumn(
        label: Text('Bank', style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.w600)),
      ),
      DataColumn(
        label: Text('Branch', style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.w600)),
      ),
      DataColumn(
        label: Text('Type', style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.w600)),
      ),
      DataColumn(
        label: Text('Status', style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.w600)),
      ),
      DataColumn(
        label: Text('Balance', style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.w600)),
      ),
      DataColumn(
        label: Text('Actions', style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.w600)),
      ),
    ];

    final rows = paginatedAccounts.asMap().entries.map((entry) {
      final index = entry.key;
      final account = entry.value;
      
      // Debug print for each account
      print('🔍 TABLE ROW ${index + 1}: name="${account.accountName}", number="${account.accountNumber}", bank="${account.bank}", type="${account.type}", status="${account.status}"');
      
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
              account.accountName.isEmpty ? 'N/A' : account.accountName,
              style: TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
          DataCell(
            Text(
              account.accountNumber.isEmpty ? 'N/A' : account.accountNumber,
              style: TextStyle(color: Colors.black87, fontSize: 13),
            ),
          ),
          DataCell(
            Text(
              account.bank.isEmpty ? 'N/A' : account.bank,
              style: TextStyle(color: Colors.black87, fontSize: 13),
            ),
          ),
          DataCell(
            Text(
              account.branchName.isEmpty ? 'N/A' : account.branchName,
              style: TextStyle(color: Colors.black87, fontSize: 13),
            ),
          ),
          DataCell(
            Text(
              account.type.isEmpty ? 'N/A' : account.type,
              style: TextStyle(color: Colors.black87, fontSize: 13),
            ),
          ),
          DataCell(
            BadgeChip(
              label: account.status,
              type: ChipType.status,
              statusKey: account.status,
              statusColorFunc: _getStatusColor,
            ),
          ),
          DataCell(
            Text(
              account.balance,
              style: TextStyle(
                color: Colors.green.shade700,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          DataCell(
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // View Icon Button
                IconButton(
                  onPressed: () => onViewAccount(account),
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
                  onPressed: () => onEditAccount(account),
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
                  onPressed: () => deleteAccount(account),
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
      columns: columns,
      rows: rows,
    );
  }

  Widget _buildPagination(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: CustomPaginationBar(
        totalItems: filteredAccounts.length,
        currentPage: currentPage,
        rowsPerPage: rowsPerPage,
        availableRowsPerPage: const [5, 10, 20, 50],
        onRowsPerPageChanged: changeRowsPerPage,
        onPageChanged: gotoPage,
      ),
    );
  }
}
