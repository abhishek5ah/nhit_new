import 'package:flutter/material.dart';
import 'package:ppv_components/common_widgets/button/outlined_button.dart';
import 'package:ppv_components/common_widgets/button/toggle_button.dart';
import 'package:ppv_components/common_widgets/custom_table.dart';
import 'package:ppv_components/features/vendor/models/vendor_model.dart';
import 'package:ppv_components/features/vendor/screen/edit_vendor.dart';
import 'package:ppv_components/features/vendor/screen/view_vendor.dart';
import 'package:ppv_components/features/vendor/widgets/vendor_grid.dart';

class VendorTableView extends StatefulWidget {
  final List<Vendor> vendorData;
  final void Function(Vendor) onDelete;
  final void Function(Vendor) onEdit;

  const VendorTableView({
    super.key,
    required this.vendorData,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  State<VendorTableView> createState() => _VendorTableViewState();
}

class _VendorTableViewState extends State<VendorTableView> {
  int toggleIndex = 0;
  int rowsPerPage = 10;
  int currentPage = 0;
  late List<Vendor> paginatedVendors;

  @override
  void initState() {
    super.initState();
    _updatePagination();
  }

  @override
  void didUpdateWidget(covariant VendorTableView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.vendorData != oldWidget.vendorData) {
      currentPage = 0;
      _updatePagination();
    }
  }

  void _updatePagination() {
    final start = currentPage * rowsPerPage;
    final end = (start + rowsPerPage).clamp(0, widget.vendorData.length);
    setState(() {
      paginatedVendors = widget.vendorData.sublist(start, end);
      final totalPages = (widget.vendorData.length / rowsPerPage).ceil();
      if (currentPage >= totalPages && totalPages > 0) {
        currentPage = totalPages - 1;
        paginatedVendors = widget.vendorData.sublist(
            currentPage * rowsPerPage,
            (currentPage * rowsPerPage + rowsPerPage)
                .clamp(0, widget.vendorData.length));
      }
    });
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
      // Handle the result if needed
      setState(() {
        // Refresh your vendor list
        _updatePagination();
      });
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
      DataColumn(
        label: Text('ID', style: TextStyle(color: colorScheme.onSurface)),
      ),
      DataColumn(
        label: Text('Code', style: TextStyle(color: colorScheme.onSurface)),
      ),
      DataColumn(
        label: Text('Name', style: TextStyle(color: colorScheme.onSurface)),
      ),
      DataColumn(
        label: Text('Email', style: TextStyle(color: colorScheme.onSurface)),
      ),
      DataColumn(
        label: Text('Mobile', style: TextStyle(color: colorScheme.onSurface)),
      ),
      DataColumn(
        label: Text(
          'Beneficiary Name',
          style: TextStyle(color: colorScheme.onSurface),
        ),
      ),
      DataColumn(
        label: Text('Status', style: TextStyle(color: colorScheme.onSurface)),
      ),
      DataColumn(
        label: Text('Actions', style: TextStyle(color: colorScheme.onSurface)),
      ),
    ];

    final rows = paginatedVendors.map((vendor) {
      // Find the primary bank account, or fall back to the first one.
      final primaryAccount = vendor.bankAccounts.isNotEmpty
          ? vendor.bankAccounts.firstWhere(
            (acc) => acc.isPrimary,
        orElse: () => vendor.bankAccounts.first,
      )
          : null;

      return DataRow(
        cells: [
          DataCell(
            Text(
              vendor.id.toString(),
              style: TextStyle(color: colorScheme.onSurface),
            ),
          ),
          DataCell(
            Text(vendor.code, style: TextStyle(color: colorScheme.onSurface)),
          ),
          DataCell(
            Text(vendor.name, style: TextStyle(color: colorScheme.onSurface)),
          ),
          DataCell(
            Text(vendor.email, style: TextStyle(color: colorScheme.onSurface)),
          ),
          DataCell(
            Text(vendor.mobile, style: TextStyle(color: colorScheme.onSurface)),
          ),
          DataCell(
            Text(
              primaryAccount?.beneficiaryName ?? 'N/A',
              style: TextStyle(color: colorScheme.onSurface),
            ),
          ),
          DataCell(
            Text(vendor.status, style: TextStyle(color: colorScheme.onSurface)),
          ),
          DataCell(
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlinedButton(
                  onPressed: () => onEditVendor(vendor),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.onSurface,
                    side: BorderSide(color: colorScheme.outline),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                  ),
                  child: const Text('Edit'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () => onViewVendor(vendor),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.primary,
                    side: BorderSide(color: colorScheme.outline),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                  ),
                  child: const Text('View'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () => deleteVendor(vendor),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.error,
                    side: BorderSide(color: colorScheme.outline),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                  ),
                  child: const Text('Delete'),
                ),
              ],
            ),
          ),
        ],
      );
    }).toList();

    return Scaffold(
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
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ToggleBtn(
                          labels: ['Table', 'Grid'],
                          selectedIndex: toggleIndex,
                          onChanged: (index) =>
                              setState(() => toggleIndex = index),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: toggleIndex == 0
                          ? Column(
                        children: [
                          Expanded(
                            child: CustomTable(
                              columns: columns,
                              rows: rows,
                            ),
                          ),
                          _paginationBar(context),
                        ],
                      )
                          : VendorGridView(
                        vendorList: widget.vendorData,
                        rowsPerPage: rowsPerPage,
                        currentPage: currentPage,
                        onPageChanged: (page) {
                          setState(() {
                            currentPage = page;
                            _updatePagination();
                          });
                        },
                        onRowsPerPageChanged: (rows) {
                          setState(() {
                            rowsPerPage = rows ?? rowsPerPage;
                            currentPage = 0;
                            _updatePagination();
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _paginationBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final totalPages = (widget.vendorData.length / rowsPerPage).ceil();
    final start = currentPage * rowsPerPage;
    final end = (start + rowsPerPage).clamp(0, widget.vendorData.length);

    int windowSize = 3;
    int startWindow = 0;
    int endWindow = totalPages;

    if (totalPages > windowSize) {
      if (currentPage <= 1) {
        startWindow = 0;
        endWindow = windowSize;
      } else if (currentPage >= totalPages - 2) {
        startWindow = totalPages - windowSize;
        endWindow = totalPages;
      } else {
        startWindow = currentPage - 1;
        endWindow = currentPage + 2;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Showing ${widget.vendorData.isEmpty ? 0 : start + 1} to $end of ${widget.vendorData.length} entries",
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: currentPage > 0
                    ? () => gotoPage(currentPage - 1)
                    : null,
              ),
              for (int i = startWindow; i < endWindow; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: i == currentPage
                          ? colorScheme.primary
                          : colorScheme.surfaceContainer,
                      foregroundColor: i == currentPage
                          ? Colors.white
                          : colorScheme.onSurface,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      minimumSize: const Size(40, 40),
                    ),
                    onPressed: () => gotoPage(i),
                    child: Text('${i + 1}'),
                  ),
                ),
              IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: currentPage < totalPages - 1
                    ? () => gotoPage(currentPage + 1)
                    : null,
              ),
              const SizedBox(width: 20),
              DropdownButton<int>(
                value: rowsPerPage,
                items: [5, 10, 20, 50]
                    .map((e) => DropdownMenuItem(value: e, child: Text('$e')))
                    .toList(),
                onChanged: changeRowsPerPage,
                style: Theme.of(context).textTheme.bodyMedium,
                underline: const SizedBox(),
              ),
              const SizedBox(width: 8),
              Text("page", style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}
