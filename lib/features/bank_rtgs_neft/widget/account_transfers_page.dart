import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ppv_components/common_widgets/button/primary_button.dart';
import 'package:ppv_components/common_widgets/button/secondary_button.dart';
import 'package:ppv_components/common_widgets/custom_table.dart';
import 'package:ppv_components/common_widgets/custom_pagination.dart';
import 'package:ppv_components/common_widgets/badge.dart';
import 'package:ppv_components/core/utils/secure_storage.dart';
import 'package:ppv_components/features/bank_rtgs_neft/models/transfer_models/transfer_enums.dart';
import 'package:ppv_components/features/bank_rtgs_neft/models/transfer_models/transfer_model.dart';
import 'package:ppv_components/features/bank_rtgs_neft/services/account_transfer_service.dart';

class AccountTransfersPage extends StatefulWidget {
  const AccountTransfersPage({super.key});

  @override
  State<AccountTransfersPage> createState() => _AccountTransfersPageState();
}

class _AccountTransfersPageState extends State<AccountTransfersPage> {
  final AccountTransferService _transferService = AccountTransferService();

  int rowsPerPage = 10;
  int currentPage = 0;
  String searchQuery = '';
  String? statusFilter;
  bool _isLoading = false;
  bool _isDetailLoading = false;

  // Hover states for stat cards and quick action buttons
  int? _hoveredCardIndex;
  int? _hoveredButtonIndex;

  // Edit and View mode state
  bool _isEditMode = false;
  bool _isViewMode = false;
  Transfer? _transferToEdit;
  TransferStatus? _editingStatus;

  List<Transfer> filteredTransfers = [];
  List<Transfer> paginatedTransfers = [];
  List<Transfer> allTransfers = [];

  // Stats data
  int totalTransfers = 0;
  int pendingApproval = 0;
  int completed = 0;
  int totalAmount = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Widget _buildReadOnlyField(
    BuildContext context, {
    required String label,
    required String value,
    int maxLines = 1,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: value.isEmpty ? '-' : value,
          readOnly: true,
          maxLines: maxLines,
          decoration: InputDecoration(
            filled: true,
            fillColor: colorScheme.surface,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: maxLines > 1 ? 18 : 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: colorScheme.outline.withValues(alpha: 0.4),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: colorScheme.primary.withValues(alpha: 0.6),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTransferDetailView(BuildContext context, Transfer transfer) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final fromAccount = transfer.sourceAccountName?.isNotEmpty == true
        ? transfer.sourceAccountName!
        : transfer.transferLegs.isNotEmpty
        ? (transfer.transferLegs.first.sourceAccount?.accountName ??
              transfer.transferLegs.first.sourceAccountId)
        : '-';
    final toAccount = transfer.destinationAccountName?.isNotEmpty == true
        ? transfer.destinationAccountName!
        : (transfer.transferLegs.isNotEmpty
              ? (transfer.transferLegs.first.destinationAccount?.accountName ??
                    transfer.transferLegs.first.destinationVendor?.name ??
                    transfer.transferLegs.first.destinationAccountId ??
                    transfer.transferLegs.first.destinationVendorId ??
                    '-')
              : '-');

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.visibility, color: colorScheme.primary),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'View Transfer',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Transfer details and information',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.4),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.swap_horiz,
                        color: colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Transfer Information',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _buildReadOnlyField(
                          context,
                          label: 'Reference',
                          value: transfer.transferReference,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildReadOnlyField(
                          context,
                          label: 'Type',
                          value: transfer.transferType.value.split('_').last,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildReadOnlyField(
                          context,
                          label: 'Mode',
                          value: transfer.transferMode.value.split('_').last,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildReadOnlyField(
                          context,
                          label: 'Amount',
                          value: '₹${transfer.totalAmount.toStringAsFixed(2)}',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildReadOnlyField(
                          context,
                          label: 'From Account',
                          value: fromAccount,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildReadOnlyField(
                          context,
                          label: 'To Account',
                          value: toAccount,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildReadOnlyField(
                          context,
                          label: 'Status',
                          value: transfer.status.value.split('_').last,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildReadOnlyField(
                          context,
                          label: 'Requested By',
                          value:
                              transfer.requestedBy?.name ??
                              transfer.requestedById,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildReadOnlyField(
                          context,
                          label: 'Purpose',
                          value: transfer.purpose,
                          maxLines: 3,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildReadOnlyField(
                          context,
                          label: 'Remarks',
                          value: transfer.remarks,
                          maxLines: 3,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerRight,
              child: SecondaryButton(
                label: 'Close',
                icon: Icons.close,
                onPressed: _cancelEdit,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransferEditView(BuildContext context, Transfer transfer) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final statusOptions = TransferStatus.values
        .where((s) => s != TransferStatus.unknown)
        .toList();
    final currentStatus = _editingStatus ?? transfer.status;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.edit, color: colorScheme.primary),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Edit Transfer',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Update transfer details and information',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.4),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.assignment,
                        color: colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Transfer Information',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _buildReadOnlyField(
                          context,
                          label: 'Reference',
                          value: transfer.transferReference,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildReadOnlyField(
                          context,
                          label: 'Type',
                          value: transfer.transferType.value.split('_').last,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildReadOnlyField(
                          context,
                          label: 'From Account',
                          value: transfer.sourceAccountName ?? '-',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildReadOnlyField(
                          context,
                          label: 'To Account',
                          value: transfer.destinationAccountName ?? '-',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildReadOnlyField(
                          context,
                          label: 'Amount',
                          value: '₹${transfer.totalAmount.toStringAsFixed(2)}',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<TransferStatus>(
                          value: currentStatus,
                          decoration: InputDecoration(
                            labelText: 'Status',
                            filled: true,
                            fillColor: colorScheme.surface,
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: colorScheme.outline.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: colorScheme.primary.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          items: statusOptions
                              .map(
                                (status) => DropdownMenuItem(
                                  value: status,
                                  child: Text(status.value.split('_').last),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _editingStatus = value;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SecondaryButton(label: 'Cancel', onPressed: _cancelEdit),
                  const SizedBox(width: 12),
                  PrimaryButton(
                    label: 'Save Changes',
                    icon: Icons.check,
                    onPressed: () {
                      if (_editingStatus == null) return;
                      final updatedTransfer = transfer.copyWith(
                        status: _editingStatus,
                      );
                      _saveEditedTransfer(updatedTransfer);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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

  Future<void> _loadData() async {
    await Future.wait([_loadStats(), _loadTransfers()]);
  }

  Future<void> _loadStats() async {
    try {
      final stats = await _transferService.getTransferStats();

      // Support both snake_case (older API) and camelCase (current API)
      int _getStatValue(String camelCaseKey, String snakeCaseKey) {
        if (stats.containsKey(camelCaseKey)) {
          return stats[camelCaseKey] as int? ?? 0;
        }
        if (stats.containsKey(snakeCaseKey)) {
          return stats[snakeCaseKey] as int? ?? 0;
        }
        return 0;
      }

      if (mounted) {
        setState(() {
          totalTransfers =
              _getStatValue('totalTransfers', 'total_transfers');
          pendingApproval =
              _getStatValue('pendingApproval', 'pending_approval');
          completed = _getStatValue('completed', 'completed_transfers');
          totalAmount = _getStatValue('totalAmount', 'total_amount');
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load stats: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadTransfers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final transfers = await _transferService.listTransfers(
        page: 1,
        pageSize: 1000, // Load all for client-side filtering
      );

      setState(() {
        allTransfers = transfers;
        _applyFilters();
        _updatePagination();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load transfers: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _updatePagination() {
    final start = currentPage * rowsPerPage;
    final end = (start + rowsPerPage).clamp(0, filteredTransfers.length);
    paginatedTransfers = filteredTransfers.sublist(start, end);
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
    filteredTransfers = allTransfers.where((transfer) {
      final statusString = transfer.status
          .toString()
          .split('.')
          .last
          .toLowerCase();
      final referenceString = transfer.transferReference;

      // Prefer backend-provided top-level fields, fallback to legs for backward compatibility
      final sourceAccountName =
          transfer.sourceAccountName ??
          (transfer.transferLegs.isNotEmpty
              ? (transfer.transferLegs.first.sourceAccount?.accountName ??
                    transfer.transferLegs.first.sourceAccountId)
              : null);

      final destinationAccountName =
          transfer.destinationAccountName ??
          (transfer.transferLegs.isNotEmpty
              ? (transfer.transferLegs.first.destinationAccount?.accountName ??
                    transfer.transferLegs.first.destinationVendor?.name ??
                    transfer.transferLegs.first.destinationAccountId ??
                    transfer.transferLegs.first.destinationVendorId ??
                    '')
              : null);

      final matchesSearch =
          searchQuery.isEmpty ||
          referenceString.toLowerCase().contains(searchQuery) ||
          (sourceAccountName ?? '').toLowerCase().contains(searchQuery) ||
          (destinationAccountName ?? '').toLowerCase().contains(searchQuery) ||
          statusString.contains(searchQuery);

      final matchesStatus =
          statusFilter == null ||
          statusFilter == 'All' ||
          statusString == statusFilter?.toLowerCase();

      return matchesSearch && matchesStatus;
    }).toList();
  }

  void _refreshData() {
    setState(() {
      statusFilter = null;
      searchQuery = '';
      filteredTransfers = allTransfers;
      currentPage = 0;
      _updatePagination();
    });
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Filter Transfers'),
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
                title: const Text('Completed'),
                leading: Radio<String>(
                  value: 'Completed',
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
                title: const Text('In Progress'),
                leading: Radio<String>(
                  value: 'In Progress',
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
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pendingapproval':
      case 'pending approval':
      case 'pending':
        return Colors.orange;
      case 'inprogress':
      case 'in progress':
      case 'processing':
        return Colors.blue;
      case 'approved':
        return Colors.lightGreen;
      case 'rejected':
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _openTransferDetail(
    Transfer transfer, {
    required bool edit,
  }) async {
    setState(() {
      _isDetailLoading = true;
    });

    try {
      final freshTransfer = await _transferService.getTransfer(
        transfer.transferId,
      );
      if (!mounted) return;
      setState(() {
        _transferToEdit = freshTransfer;
        _editingStatus = freshTransfer.status;
        _isEditMode = edit;
        _isViewMode = !edit;
        _isDetailLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isDetailLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load transfer details: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void onViewTransfer(Transfer transfer) {
    _openTransferDetail(transfer, edit: false);
  }

  void onEditTransfer(Transfer transfer) {
    _openTransferDetail(transfer, edit: true);
  }

  void _saveEditedTransfer(Transfer updatedTransfer) {
    final index = allTransfers.indexWhere(
      (t) => t.transferId == _transferToEdit!.transferId,
    );
    if (index != -1) {
      setState(() {
        allTransfers[index] = updatedTransfer;
        _isEditMode = false;
        _isViewMode = false;
        _transferToEdit = null;
        _editingStatus = null;
        _applyFilters();
        _updatePagination();
      });
    }
  }

  void _cancelEdit() {
    setState(() {
      _isEditMode = false;
      _isViewMode = false;
      _transferToEdit = null;
      _editingStatus = null;
      _isDetailLoading = false;
    });
  }

  /// Get current logged-in user ID from secure storage
  /// Falls back to mock user ID if not available
  Future<String> _getCurrentUserId() async {
    try {
      // Try to get user ID from secure storage
      // Note: You may need to store user_id during login
      final userId = await SecureStorage.read('user_id');
      if (userId != null && userId.isNotEmpty) {
        return userId;
      }

      // Fallback to provided default user ID when secure storage is empty
      const defaultUserId = '123e4567-e89b-12d3-a456-426614174000';
      print(
        '⚠️ Warning: user_id missing in secure storage. Using default ID $defaultUserId.',
      );
      return defaultUserId;
    } catch (e) {
      const defaultUserId = '123e4567-e89b-12d3-a456-426614174000';
      print('⚠️ Error getting user ID: $e. Using default ID $defaultUserId.');
      return defaultUserId;
    }
  }

  Future<void> deleteTransfer(Transfer transfer) async {
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Transfer'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to cancel this transfer?',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Transfer Reference: ${transfer.transferReference}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'Cancellation Reason *',
                  hintText: 'Enter reason for cancellation',
                  border: OutlineInputBorder(),
                ),
                minLines: 2,
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please provide a reason for cancellation';
                  }
                  if (value.trim().length < 5) {
                    return 'Reason must be at least 5 characters';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.of(ctx).pop(true);
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Yes, Cancel Transfer'),
          ),
        ],
      ),
    );

    if (shouldCancel == true) {
      final reason = reasonController.text.trim();

      // Show loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 12),
                Text('Cancelling transfer...'),
              ],
            ),
            duration: Duration(seconds: 30),
          ),
        );
      }

      try {
        // Get current logged-in user ID
        final userId = await _getCurrentUserId();

        print('🔄 Attempting to cancel transfer:');
        print('   Transfer ID: ${transfer.transferId}');
        print('   User ID: $userId');
        print('   Reason: $reason');

        // Call cancel API with correct parameters
        await _transferService.cancelTransfer(
          transfer.transferId,
          userId,
          reason,
        );

        if (mounted) {
          // Hide loading indicator
          ScaffoldMessenger.of(context).hideCurrentSnackBar();

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Transfer ${transfer.transferReference} cancelled successfully',
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );

          // Refresh both stats and transfers list
          await Future.wait([_loadStats(), _loadTransfers()]);
        }
      } catch (e) {
        print('❌ Error cancelling transfer: $e');

        if (mounted) {
          // Hide loading indicator
          ScaffoldMessenger.of(context).hideCurrentSnackBar();

          // Extract error message
          String errorMessage = 'Failed to cancel transfer';
          if (e.toString().contains('Exception:')) {
            errorMessage = e.toString().replaceAll('Exception:', '').trim();
          } else {
            errorMessage = e.toString();
          }

          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Failed to Cancel Transfer',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(errorMessage),
                ],
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: 'Dismiss',
                textColor: Colors.white,
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
              ),
            ),
          );
        }
      }
    }

    // Dispose controller
    reasonController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: _isDetailLoading
          ? const Center(child: CircularProgressIndicator())
          : _transferToEdit != null
          ? (_isEditMode
                ? _buildTransferEditView(context, _transferToEdit!)
                : _buildTransferDetailView(context, _transferToEdit!))
          : LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(context, constraints),
                        const SizedBox(height: 16),
                        _buildStatsCards(context, constraints),
                        const SizedBox(height: 16),
                        _buildQuickActions(context, constraints),
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
        border: Border.all(color: colorScheme.outline, width: 0.5),
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
                  Icons.swap_horiz,
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
                      'Account Transfers',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage fund transfers between accounts and to vendors',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              if (!isSmallScreen) const SizedBox(width: 16),
            ],
          ),
          if (isSmallScreen) const SizedBox(height: 16),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              PrimaryButton(
                onPressed: () async {
                  final result = await context.push<bool>('/escrow/create');
                  if (result == true) {
                    _loadTransfers();
                  }
                },
                icon: Icons.add,
                label: 'New Transfer',
              ),
              SecondaryButton(
                onPressed: () => context.go('/escrow-accounts'),
                icon: Icons.account_balance_wallet,
                label: 'Escrow Accounts',
              ),
              SecondaryButton(
                onPressed: () => context.go('/escrow/bank-letter'),
                icon: Icons.description,
                label: 'Bank Letters',
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
        'icon': Icons.sync_alt,
        'label': 'Total Transfers',
        'value': '$totalTransfers',
        'color': Colors.blue,
      },
      {
        'icon': Icons.pending_actions,
        'label': 'Pending Approval',
        'value': '$pendingApproval',
        'color': Colors.orange,
      },
      {
        'icon': Icons.check_circle,
        'label': 'Completed',
        'value': '$completed',
        'color': Colors.green,
      },
      {
        'icon': Icons.hourglass_empty,
        'label': 'Total Amount',
        'value': '$totalAmount',
        'color': Colors.cyan,
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
            ? 4.0
            : (crossAxisCount == 2 ? 2.5 : 2.2),
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return _buildStatCard(
          context,
          index: index,
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
    required int index,
    required IconData icon,
    required String label,
    required String value,
    required Color color,
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isHovered ? colorScheme.primary : colorScheme.outline,
            width: isHovered ? 2.0 : 0.5,
          ),
          boxShadow: isHovered
              ? [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
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
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, BoxConstraints constraints) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final isSmallScreen = constraints.maxWidth < 900;

    final quickActions = [
      {
        'icon': Icons.swap_horiz,
        'label': 'Internal Transfer',
        'color': Colors.blue,
        'onTap': () => context.push('/escrow/create'),
      },
      {
        'icon': Icons.send,
        'label': 'External Transfer',
        'color': Colors.purple,
        'onTap': () => context.push('/escrow/create'),
      },
      {
        'icon': Icons.description,
        'label': 'Bank Letter',
        'color': Colors.green,
        'onTap': () => context.push('/escrow/bank-letter/create'),
      },
      {
        'icon': Icons.add_circle_outline,
        'label': 'Add Account',
        'color': Colors.grey,
        'onTap': () => context.push('/escrow-accounts/create'),
      },
    ];

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.flash_on, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              Text(
                'Quick Transfer Actions',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          isSmallScreen
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: quickActions.asMap().entries.map((entry) {
                    final index = entry.key;
                    final action = entry.value;
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: index < quickActions.length - 1 ? 12 : 0,
                      ),
                      child: _buildQuickActionButton(
                        context,
                        index: index,
                        icon: action['icon'] as IconData,
                        label: action['label'] as String,
                        color: action['color'] as Color,
                        onTap: action['onTap'] as VoidCallback,
                      ),
                    );
                  }).toList(),
                )
              : Row(
                  children: quickActions.asMap().entries.map((entry) {
                    final index = entry.key;
                    final action = entry.value;
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: index < quickActions.length - 1 ? 12 : 0,
                        ),
                        child: _buildQuickActionButton(
                          context,
                          index: index,
                          icon: action['icon'] as IconData,
                          label: action['label'] as String,
                          color: action['color'] as Color,
                          onTap: action['onTap'] as VoidCallback,
                        ),
                      ),
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context, {
    required int index,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final isHovered = _hoveredButtonIndex == index;

    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _hoveredButtonIndex = index;
        });
      },
      onExit: (_) {
        setState(() {
          _hoveredButtonIndex = null;
        });
      },
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isHovered
                  ? color.withValues(alpha: 0.5)
                  : colorScheme.outline.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
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
        border: Border.all(color: colorScheme.outline, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.table_chart, color: colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'All Transfers',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
              const Spacer(),
              if (!isSmallScreen) ...[
                SecondaryButton(
                  onPressed: _showFilterDialog,
                  icon: Icons.filter_list,
                  label: statusFilter == null
                      ? 'Filter'
                      : 'Filter: $statusFilter',
                ),
                const SizedBox(width: 8),
                SecondaryButton(
                  onPressed: _refreshData,
                  icon: Icons.refresh,
                  label: 'Refresh',
                ),
              ],
            ],
          ),
          if (isSmallScreen) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    onPressed: _showFilterDialog,
                    icon: Icons.filter_list,
                    label: statusFilter == null
                        ? 'Filter'
                        : 'Filter: $statusFilter',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SecondaryButton(
                    onPressed: _refreshData,
                    icon: Icons.refresh,
                    label: 'Refresh',
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          Text(
            'Track and manage all fund transfers',
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
                  'FROM ACCOUNT',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'TO ACCOUNT',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'AMOUNT',
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
                  'REQUESTED BY',
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
            rows: paginatedTransfers.isEmpty
                ? []
                : paginatedTransfers.asMap().entries.map((entry) {
                    final index = entry.key;
                    final transfer = entry.value;
                    // Extract display data from transferLegs
                    final firstLeg = transfer.transferLegs.isNotEmpty
                        ? transfer.transferLegs.first
                        : null;
                    final fromAccount =
                        transfer.sourceAccountName ??
                        firstLeg?.sourceAccount?.accountName ??
                        firstLeg?.sourceAccountId ??
                        transfer.sourceAccountId ??
                        '-';
                    final toAccount =
                        transfer.destinationAccountName ??
                        firstLeg?.destinationAccount?.accountName ??
                        firstLeg?.destinationVendor?.name ??
                        firstLeg?.destinationAccountId ??
                        firstLeg?.destinationVendorId ??
                        transfer.destinationAccountId ??
                        '-';
                    final statusString = transfer.status
                        .toString()
                        .split('.')
                        .last;

                    return DataRow(
                      cells: [
                        DataCell(
                          Text('${currentPage * rowsPerPage + index + 1}'),
                        ),
                        DataCell(Text(transfer.transferReference)),
                        DataCell(Text(fromAccount)),
                        DataCell(Text(toAccount)),
                        DataCell(
                          Text('₹${transfer.totalAmount.toStringAsFixed(2)}'),
                        ),
                        DataCell(
                          BadgeChip(
                            label: statusString,
                            type: ChipType.status,
                            statusKey: statusString,
                            statusColorFunc: _getStatusColor,
                          ),
                        ),
                        DataCell(
                          Text(
                            transfer.requestedBy?.name ??
                                transfer.requestedById,
                          ),
                        ),
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // View Icon Button
                              IconButton(
                                onPressed: () => onViewTransfer(transfer),
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
                                onPressed: () => onEditTransfer(transfer),
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
                                onPressed: () => deleteTransfer(transfer),
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
            minTableWidth: 1100,
          ),
          if (paginatedTransfers.isEmpty) ...[
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
                    'No transfers found',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
          if (filteredTransfers.isNotEmpty) ...[
            CustomPaginationBar(
              totalItems: filteredTransfers.length,
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
