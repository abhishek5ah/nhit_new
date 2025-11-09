import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ViewVendorScreen extends StatelessWidget {
  final dynamic vendor;

  const ViewVendorScreen({
    super.key,
    required this.vendor,
  });

  void _handleClose(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      context.go('/vendor');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header with Border
            Padding(
              padding: const EdgeInsets.all(24),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.5),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.blue[600],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.visibility_outlined,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Vendor Details',
                              style: textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: colorScheme.onSurface,
                                fontSize: 22,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Complete vendor information and banking details',
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurface.withValues(alpha: 0.6),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _handleClose(context),
                      icon: const Icon(Icons.arrow_back, size: 18),
                      label: const Text('Back to List'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        side: BorderSide(
                          color: colorScheme.outline.withValues(alpha: 0.5),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Vendor Name and Code Section with Border
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.5),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vendor.name ?? 'N/A',
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                            fontSize: 28,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          vendor.code ?? 'N/A',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        border: Border.all(
                          color: Colors.green,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        vendor.status ?? 'N/A',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Main Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Basic Information
                  _buildSectionCard(
                    context: context,
                    icon: Icons.info_outline,
                    title: 'Basic Information',
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildDetailRow(
                              context,
                              'Vendor Type',
                              vendor.vendorType ?? 'N/A',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDetailRow(
                              context,
                              'From Account Type',
                              vendor.fromAccountType ?? 'N/A',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDetailRow(
                              context,
                              'Project',
                              vendor.project ?? 'N/A',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDetailRow(
                              context,
                              'Activity Type',
                              vendor.activityType ?? 'N/A',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDetailRow(
                              context,
                              'Vendor Nick Name',
                              vendor.vendorNickName ?? 'N/A',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDetailRow(
                              context,
                              'Short Name',
                              vendor.shortName ?? 'N/A',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Contact Information
                  _buildSectionCard(
                    context: context,
                    icon: Icons.phone_outlined,
                    title: 'Contact Information',
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildDetailRow(
                              context,
                              'Vendor Email',
                              vendor.email,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDetailRow(
                              context,
                              'Vendor Mobile',
                              vendor.mobile,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Tax & Compliance Information
                  _buildSectionCard(
                    context: context,
                    icon: Icons.receipt_long_outlined,
                    title: 'Tax & Compliance Information',
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildDetailRow(
                              context,
                              'GSTIN',
                              vendor.taxInfo.gstin ?? 'N/A',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDetailRow(
                              context,
                              'PAN',
                              vendor.taxInfo.pan ?? 'N/A',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDetailRow(
                              context,
                              'GST Defaulted',
                              vendor.taxInfo.isGstDefaulted ? 'Yes' : 'No',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDetailRow(
                              context,
                              'Section 206AB Verified',
                              vendor.taxInfo.section206abVerified ?? 'N/A',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDetailRow(
                              context,
                              'Income Tax Type',
                              vendor.taxInfo.incomeTaxType ?? 'N/A',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDetailRow(
                              context,
                              'Material Nature',
                              vendor.taxInfo.materialNature ?? 'N/A',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // MSME Information
                  if (vendor.msmeInfo != null)
                    Column(
                      children: [
                        _buildSectionCard(
                          context: context,
                          icon: Icons.business_center_outlined,
                          title: 'MSME Information',
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _buildDetailRow(
                                    context,
                                    'MSME Classification',
                                    vendor.msmeInfo!.classification ?? 'N/A',
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildDetailRow(
                                    context,
                                    'Is MSME',
                                    vendor.msmeInfo!.isMsme ? 'Yes' : 'No',
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildDetailRow(
                                    context,
                                    'Registration Number',
                                    vendor.msmeInfo!.registrationNumber ?? 'N/A',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildDetailRow(
                                    context,
                                    'MSME Start Date',
                                    vendor.msmeInfo!.startDate ?? 'N/A',
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildDetailRow(
                                    context,
                                    'MSME End Date',
                                    vendor.msmeInfo!.endDate ?? 'N/A',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),

                  // Banking Information
                  if (vendor.bankAccounts.isNotEmpty)
                    Column(
                      children: [
                        _buildSectionCard(
                          context: context,
                          icon: Icons.account_balance_outlined,
                          title: 'Banking Information',
                          children: [
                            ...List.generate(vendor.bankAccounts.length, (index) {
                              final account = vendor.bankAccounts[index];
                              return Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: account.isPrimary
                                          ? colorScheme.surface
                                          : colorScheme.surfaceContainer
                                          .withValues(alpha: 0.5),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: account.isPrimary
                                            ? Colors.green
                                            : colorScheme.outline
                                            .withValues(alpha: 0.3),
                                        width: account.isPrimary ? 2 : 1,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              account.isPrimary
                                                  ? 'Primary Bank Account'
                                                  : 'Bank Account ${index + 1}',
                                              style:
                                              textTheme.titleSmall?.copyWith(
                                                fontWeight: FontWeight.w600,
                                                color: colorScheme.onSurface,
                                              ),
                                            ),
                                            if (account.isPrimary)
                                              Container(
                                                padding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.green,
                                                  borderRadius:
                                                  BorderRadius.circular(12),
                                                ),
                                                child: const Text(
                                                  'Primary',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: _buildDetailRowCompact(
                                                context,
                                                'Account Name',
                                                account.accountName ?? 'N/A',
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: _buildDetailRowCompact(
                                                context,
                                                'Account Number',
                                                account.accountNumber,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: _buildDetailRowCompact(
                                                context,
                                                'Bank Name',
                                                account.bankName,
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: _buildDetailRowCompact(
                                                context,
                                                'IFSC Code',
                                                account.ifscCode,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: _buildDetailRowCompact(
                                                context,
                                                'Branch Name',
                                                account.branchName ?? 'N/A',
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: _buildDetailRowCompact(
                                                context,
                                                'Beneficiary Name',
                                                account.beneficiaryName,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (index < vendor.bankAccounts.length - 1)
                                    const SizedBox(height: 16),
                                ],
                              );
                            }),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),

                  // Location Information
                  _buildSectionCard(
                    context: context,
                    icon: Icons.location_on_outlined,
                    title: 'Location Information',
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildDetailRow(
                              context,
                              'Country',
                              vendor.locationInfo.country,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDetailRow(
                              context,
                              'State',
                              vendor.locationInfo.state,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDetailRow(
                              context,
                              'City',
                              vendor.locationInfo.city,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildDetailRow(
                        context,
                        'Address',
                        vendor.locationInfo.address,
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _handleClose(context),
                        icon: const Icon(Icons.close, size: 18),
                        label: const Text('Close'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.5),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
      BuildContext context,
      String label,
      String value,
      ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface.withValues(alpha: 0.6),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRowCompact(
      BuildContext context,
      String label,
      String value,
      ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface.withValues(alpha: 0.6),
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
