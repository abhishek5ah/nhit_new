import 'package:flutter/material.dart';
import 'package:ppv_components/common_widgets/button/toggle_button.dart';
import 'package:ppv_components/common_widgets/custom_table.dart';
import 'package:ppv_components/common_widgets/custom_pagination.dart';
import 'package:ppv_components/core/accessibility/accessible_widgets.dart';
import 'package:ppv_components/features/vendor/models/vendor_model.dart';
import 'package:ppv_components/features/vendor/screen/edit_vendor.dart';
import 'package:ppv_components/features/vendor/screen/view_vendor.dart';
import 'package:ppv_components/features/vendor/widgets/vendor_grid.dart';

class VendorTableView extends StatefulWidget {
  final List<Vendor> vendorData;
  final int totalItems;
  final int currentPage; // zero-based
  final int rowsPerPage;
  final bool isLoading;
  final String? errorMessage;
  final void Function(Vendor) onDelete;
  final void Function(Vendor) onEdit;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int?> onRowsPerPageChanged;
  final VoidCallback onRefresh;

  const VendorTableView({
    super.key,
    required this.vendorData,
    required this.totalItems,
    required this.currentPage,
    required this.rowsPerPage,
    required this.isLoading,
    this.errorMessage,
    required this.onDelete,
    required this.onEdit,
    required this.onPageChanged,
    required this.onRowsPerPageChanged,
    required this.onRefresh,
  });

  @override
  State<VendorTableView> createState() => _VendorTableViewState();
}

class _VendorTableViewState extends State<VendorTableView> {
  int toggleIndex = 0;

  Future<void> deleteVendor(Vendor vendor) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete ${vendor.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (shouldDelete == true) {
      widget.onDelete(vendor);
    }
  }

  Future<void> onEditVendor(Vendor vendor) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditVendorScreen(vendor: vendor),
      ),
    );

    if (result != null) {
      widget.onEdit(result);
    }
  }

  Future<void> onViewVendor(Vendor vendor) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewVendorScreen(vendor: vendor),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final columns = [
      DataColumn(label: Text('ID', style: TextStyle(color: colorScheme.onSurface))),
      DataColumn(label: Text('Code', style: TextStyle(color: colorScheme.onSurface))),
      DataColumn(label: Text('Name', style: TextStyle(color: colorScheme.onSurface))),
      DataColumn(label: Text('Email', style: TextStyle(color: colorScheme.onSurface))),
      DataColumn(label: Text('Mobile', style: TextStyle(color: colorScheme.onSurface))),
      DataColumn(label: Text('Beneficiary Name', style: TextStyle(color: colorScheme.onSurface))),
      DataColumn(label: Text('Status', style: TextStyle(color: colorScheme.onSurface))),
      DataColumn(label: Text('Actions', style: TextStyle(color: colorScheme.onSurface))),
    ];

    final semanticallyLabeledColumns = columns
        .map(
          (column) => DataColumn(
            label: Semantics(
              label: '${column.label.runtimeType == Text ? (column.label as Text?)?.data : 'Column'} header',
              header: true,
              child: column.label,
            ),
          ),
        )
        .toList();

    final rows = widget.vendorData.map((vendor) {
      final primaryAccount = vendor.bankAccounts.isNotEmpty
          ? vendor.bankAccounts.firstWhere((acc) => acc.isPrimary, orElse: () => vendor.bankAccounts.first)
          : null;

      return DataRow(
        cells: [
          DataCell(Semantics(label: 'Vendor ID ${vendor.id}', child: Text(vendor.id.toString(), style: TextStyle(color: colorScheme.onSurface)))),
          DataCell(Semantics(label: 'Vendor code ${vendor.code}', child: Text(vendor.code, style: TextStyle(color: colorScheme.onSurface)))),
          DataCell(Semantics(label: 'Vendor name ${vendor.name}', child: Text(vendor.name, style: TextStyle(color: colorScheme.onSurface)))),
          DataCell(Semantics(label: 'Vendor email ${vendor.email}', child: Text(vendor.email, style: TextStyle(color: colorScheme.onSurface)))),
          DataCell(Semantics(label: 'Vendor mobile ${vendor.mobile}', child: Text(vendor.mobile, style: TextStyle(color: colorScheme.onSurface)))),
          DataCell(Semantics(label: 'Beneficiary ${primaryAccount?.beneficiaryName ?? 'Not available'}', child: Text(primaryAccount?.beneficiaryName ?? 'N/A', style: TextStyle(color: colorScheme.onSurface)))),
          DataCell(Semantics(label: 'Status ${vendor.status}', child: Text(vendor.status, style: TextStyle(color: colorScheme.onSurface)))),
          DataCell(
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AccessibleIconButton(
                  icon: Icons.visibility_outlined,
                  semanticLabel: 'View vendor ${vendor.name}',
                  tooltip: 'View vendor details',
                  onPressed: () => onViewVendor(vendor),
                  color: colorScheme.primary,
                  backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                ),
                const SizedBox(width: 4),
                AccessibleIconButton(
                  icon: Icons.edit_outlined,
                  semanticLabel: 'Edit vendor ${vendor.name}',
                  tooltip: 'Edit vendor information',
                  onPressed: () => onEditVendor(vendor),
                  color: colorScheme.tertiary,
                  backgroundColor: colorScheme.tertiary.withValues(alpha: 0.1),
                ),
                const SizedBox(width: 4),
                AccessibleIconButton(
                  icon: Icons.delete_outline,
                  semanticLabel: 'Delete vendor ${vendor.name}',
                  tooltip: 'Delete vendor',
                  onPressed: () => deleteVendor(vendor),
                  color: colorScheme.error,
                  backgroundColor: colorScheme.error.withValues(alpha: 0.1),
                ),
              ],
            ),
          ),
        ],
      );
    }).toList();

    Widget buildContent() {
      if (widget.isLoading && widget.vendorData.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if ((widget.errorMessage ?? '').isNotEmpty && widget.vendorData.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.errorMessage!,
                style: TextStyle(color: colorScheme.error),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: widget.onRefresh,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        );
      }

      if (widget.vendorData.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.store_mall_directory_outlined, size: 48),
              const SizedBox(height: 12),
              Text(
                'No vendors found',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        );
      }

      return toggleIndex == 0
          ? Column(
              children: [
                Expanded(
                  child: Semantics(
                    label: 'Vendor data table view',
                    container: true,
                    child: CustomTable(columns: semanticallyLabeledColumns, rows: rows),
                  ),
                ),
                CustomPaginationBar(
                  totalItems: widget.totalItems,
                  currentPage: widget.currentPage,
                  rowsPerPage: widget.rowsPerPage,
                  onPageChanged: widget.onPageChanged,
                  onRowsPerPageChanged: widget.onRowsPerPageChanged,
                ),
              ],
            )
          : VendorGridView(
              vendorList: widget.vendorData,
              rowsPerPage: widget.rowsPerPage,
              currentPage: widget.currentPage,
              totalItems: widget.totalItems,
              onPageChanged: widget.onPageChanged,
              onRowsPerPageChanged: widget.onRowsPerPageChanged,
              isLoading: widget.isLoading,
            );
    }

    return Semantics(
      label: 'Vendor management table',
      explicitChildNodes: true,
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Vendors',
                            style: TextStyle(color: colorScheme.onSurface, fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          Semantics(
                            button: true,
                            label: 'Toggle between table or grid view',
                            child: ToggleBtn(
                              labels: const ['Table', 'Grid'],
                              selectedIndex: toggleIndex,
                              onChanged: (index) => setState(() => toggleIndex = index),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Expanded(child: buildContent()),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
