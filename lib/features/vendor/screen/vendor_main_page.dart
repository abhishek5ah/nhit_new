import 'package:flutter/material.dart';
import 'package:ppv_components/features/vendor/data/vendor_mockdb.dart';
import 'package:ppv_components/features/vendor/models/vendor_model.dart';
import 'package:ppv_components/features/vendor/widgets/vendor_header.dart';
import 'package:ppv_components/features/vendor/widgets/vendor_table.dart';

class VendorMainPage extends StatefulWidget {
  const VendorMainPage({super.key});

  @override
  State<VendorMainPage> createState() => _VendorMainPageState();
}

class _VendorMainPageState extends State<VendorMainPage> {
  String searchQuery = '';
  late List<Vendor> filteredVendors;
  final List<Vendor> allVendors = List<Vendor>.from(vendorData);

  @override
  void initState() {
    super.initState();
    filteredVendors = List<Vendor>.from(allVendors);
  }

  void updateSearch(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
      if (searchQuery.isEmpty) {
        filteredVendors = List<Vendor>.from(allVendors);
      } else {
        filteredVendors = allVendors.where((vendor) {
          return vendor.name.toLowerCase().contains(searchQuery) ||
              vendor.code.toLowerCase().contains(searchQuery) ||
              vendor.email.toLowerCase().contains(searchQuery) ||
              vendor.status.toLowerCase().contains(searchQuery);
        }).toList();
      }
    });
  }

  void onDeleteVendor(Vendor vendor) {
    setState(() {
      allVendors.removeWhere((v) => v.id == vendor.id);
      updateSearch(searchQuery);
    });
  }

  void onEditVendor(Vendor updatedVendor) {
    final index = allVendors.indexWhere((v) => v.id == updatedVendor.id);
    if (index != -1) {
      setState(() {
        allVendors[index] = updatedVendor;
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
            const Padding(
              padding: EdgeInsets.only(left: 12, bottom: 12, right: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  VendorHeader(tabIndex: 0),
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
            const SizedBox(height: 12),
            Expanded(
              child: VendorTableView(
                vendorData: filteredVendors,
                onDelete: onDeleteVendor,
                onEdit: onEditVendor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
