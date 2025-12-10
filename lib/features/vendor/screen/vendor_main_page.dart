import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ppv_components/features/vendor/models/vendor_model.dart';
import 'package:ppv_components/features/vendor/services/vendor_api_service.dart';
import 'package:ppv_components/features/vendor/utils/vendor_mapper.dart';
import 'package:ppv_components/features/vendor/widgets/vendor_header.dart';
import 'package:ppv_components/features/vendor/widgets/vendor_table.dart';

class VendorMainPage extends StatefulWidget {
  const VendorMainPage({super.key});

  @override
  State<VendorMainPage> createState() => _VendorMainPageState();
}

class _VendorMainPageState extends State<VendorMainPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _currentPage = 0; // zero-based for UI
  int _rowsPerPage = 10;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadVendors();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadVendors({bool forceRefresh = false}) async {
    final service = context.read<VendorApiService>();
    await service.loadVendors(
      page: _currentPage + 1,
      perPage: _rowsPerPage,
      search: _searchQuery.isNotEmpty ? _searchQuery : null,
      forceRefresh: forceRefresh,
    );
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.trim();
      _currentPage = 0;
    });
    _loadVendors(forceRefresh: true);
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    _loadVendors(forceRefresh: true);
  }

  void _onRowsPerPageChanged(int? rows) {
    if (rows == null) return;
    setState(() {
      _rowsPerPage = rows;
      _currentPage = 0;
    });
    _loadVendors(forceRefresh: true);
  }

  Future<void> _onDeleteVendor(Vendor vendor) async {
    final messenger = ScaffoldMessenger.of(context);
    final service = context.read<VendorApiService>();
    final response = await service.deleteVendor(vendor.id);
    if (response.success) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Vendor deleted successfully')),
      );
      await _loadVendors(forceRefresh: true);
    } else {
      messenger.showSnackBar(
        SnackBar(content: Text(response.message ?? 'Failed to delete vendor')),
      );
    }
  }

  void _onEditVendor(Vendor _) {
    _loadVendors(forceRefresh: true);
  }

  void _onRefresh() {
    _loadVendors(forceRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer<VendorApiService>(
      builder: (context, vendorService, _) {
        final vendors = vendorService.vendors.map(mapVendorApiToUi).toList();
        final totalItems = vendorService.pagination?.total ?? vendors.length;

        return Scaffold(
          backgroundColor: colorScheme.surface,
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 12, bottom: 12, right: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      VendorHeader(),
                      SizedBox(height: 12),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Row(
                    children: [
                      const Spacer(),
                      SizedBox(
                        width: 250,
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 12,
                            ),
                            hintText: 'Search vendors',
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
                          onChanged: _onSearchChanged,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: VendorTableView(
                    vendorData: vendors,
                    totalItems: totalItems,
                    currentPage: _currentPage,
                    rowsPerPage: _rowsPerPage,
                    isLoading: vendorService.isLoading,
                    errorMessage: vendorService.error,
                    onDelete: _onDeleteVendor,
                    onEdit: _onEditVendor,
                    onPageChanged: _onPageChanged,
                    onRowsPerPageChanged: _onRowsPerPageChanged,
                    onRefresh: _onRefresh,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
