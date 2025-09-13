import 'package:flutter/material.dart';
import 'package:ppv_components/common_widgets/button/primary_button.dart';
import 'package:ppv_components/features/finance/data/mock_vendors.dart';

class VendorInformationCard extends StatelessWidget {
  final String vendorName;
  const VendorInformationCard({super.key, required this.vendorName});

  @override
  Widget build(BuildContext context) {
    final vendor = mockVendors.firstWhere(
      (v) => v.name == vendorName,
      orElse: () => throw Exception('Vendor not found'),
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 1,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vendor Information',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Expense vendor details',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              vendor.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 2),
            Text(vendor.address),
            Text('Suite 456'), // If suite is a separate field, use vendor.suite
            Text('${vendor.city}, ${vendor.state}'),
            Text(vendor.country),
            const SizedBox(height: 16),
            PrimaryButton(label: 'View Vendor', onPressed: () {}),
          ],
        ),
      ),
    );
  }
}
