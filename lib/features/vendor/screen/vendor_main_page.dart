import 'package:flutter/material.dart';
import 'package:ppv_components/common_widgets/tabs.dart';
import 'package:ppv_components/features/vendor/data/vendor_mockdb.dart';
import 'package:ppv_components/features/vendor/models/vendor_model.dart';
import 'package:ppv_components/features/vendor/widgets/add_vendor_form.dart';
import 'package:ppv_components/features/vendor/widgets/vendor_header.dart';
import 'package:ppv_components/features/vendor/widgets/vendor_table.dart';

class VendorMainPage extends StatefulWidget {
  const VendorMainPage({super.key});

  @override
  State<VendorMainPage> createState() => _VendorMainPageState();
}

class _VendorMainPageState extends State<VendorMainPage> {
  int tabIndex = 0;
  String searchQuery = '';
  late List<Vendor> filteredVendors;
  List<Vendor> allVendors = List<Vendor>.from(vendorData);

  @override
  void initState() {
    super.initState();
    filteredVendors = List<Vendor>.from(allVendors);
  }

  void updateSearch(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
      filteredVendors = allVendors.where((vendor) {
        final name = vendor.name.toLowerCase();
        final code = vendor.code.toLowerCase();
        final email = vendor.email.toLowerCase();
        final status = vendor.status.toLowerCase();
        return name.contains(searchQuery) ||
            code.contains(searchQuery) ||
            email.contains(searchQuery) ||
            status.contains(searchQuery);
      }).toList();
    });
  }

  void onDeleteVendor(Vendor vendor) {
    setState(() {
      allVendors.removeWhere((v) => v.id == vendor.id);
      updateSearch(searchQuery);
    });
  }

  void onEditVendor(Vendor vendor) {
    final index = allVendors.indexWhere((v) => v.id == vendor.id);
    if (index != -1) {
      setState(() {
        allVendors[index] = vendor;
        updateSearch(searchQuery);
      });
    }
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  VendorHeader(tabIndex: tabIndex),
                  const SizedBox(height: 12),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: TabsBar(
                      tabs: const ['Vendor', 'Add Vendor'],
                      selectedIndex: tabIndex,
                      onChanged: (idx) => setState(() => tabIndex = idx),
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 250,
                    child: TextField(
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
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
                      onChanged: updateSearch,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: tabIndex == 0
                  ? VendorTableView(
                vendorData: filteredVendors,
                onDelete: onDeleteVendor,
                onEdit: onEditVendor,
              )
                  : const AddVendorPage(),
            ),
          ],
        ),
      ),
    );
  }
}
