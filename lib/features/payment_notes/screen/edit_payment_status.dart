import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ppv_components/common_widgets/button/primary_button.dart';
import 'package:ppv_components/common_widgets/button/secondary_button.dart';
import 'package:ppv_components/features/payment_notes/model/payment_notes_model.dart';

class EditPaymentStatusScreen extends StatefulWidget {
  final PaymentNote payment;

  const EditPaymentStatusScreen({
    super.key,
    required this.payment,
  });

  @override
  State<EditPaymentStatusScreen> createState() => _EditPaymentStatusScreenState();
}

class _EditPaymentStatusScreenState extends State<EditPaymentStatusScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedStatus;

  final List<Map<String, dynamic>> _statusOptions = [
    {
      'value': 'Draft',
      'label': 'Draft - Work in progress',
      'icon': Icons.edit,
      'color': Colors.grey,
    },
    {
      'value': 'Pending',
      'label': 'Pending - Awaiting approval',
      'icon': Icons.schedule,
      'color': Colors.orange,
    },
    {
      'value': 'Submitted',
      'label': 'Submitted - Sent for review',
      'icon': Icons.send,
      'color': Colors.blue,
    },
    {
      'value': 'Approved',
      'label': 'Approved - Accepted',
      'icon': Icons.check_circle,
      'color': Colors.green,
    },
    {
      'value': 'Rejected',
      'label': 'Rejected - Declined',
      'icon': Icons.cancel,
      'color': Colors.red,
    },
    {
      'value': 'Paid',
      'label': 'Paid - Payment completed',
      'icon': Icons.payment,
      'color': Colors.teal,
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.payment.status;
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Use copyWith if available, otherwise create new PaymentNote
      final updatedPayment = PaymentNote(
        sno: widget.payment.sno,
        projectName: widget.payment.projectName,
        vendorName: widget.payment.vendorName,
        invoiceValue: widget.payment.invoiceValue,
        date: widget.payment.date,
        status: _selectedStatus!,
        nextApprover: widget.payment.nextApprover,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment status updated successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          Navigator.of(context).pop(updatedPayment);
        }
      });
    }
  }

  void _handleCancel() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Back Button - Full Width
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colorScheme.outline.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.edit_outlined,
                            color: colorScheme.onPrimary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Edit Payment Note Status',
                                style: textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Update the status of payment note: ${widget.payment.sno}',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        SecondaryButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: Icons.arrow_back,
                          label: 'Back to Details',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Admin Access Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.amber.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.security,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SuperAdmin Access',
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.amber[900],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'You have administrative privileges to update this payment note status.',
                          style: textTheme.bodySmall?.copyWith(
                            color: Colors.amber[900],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main Form Section
                Expanded(
                  flex: 2,
                  child: Form(
                    key: _formKey,
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        border: Border.all(
                          color: colorScheme.outline.withValues(alpha: 0.3),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Section Header
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.toggle_on,
                                  size: 20,
                                  color: colorScheme.onPrimaryContainer,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Update Status',
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Current Status Display
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  'Current Status',
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    widget.payment.status,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Note Number
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Note Number',
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  widget.payment.sno.toString(),
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurface,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // New Status Selection
                          RichText(
                            text: TextSpan(
                              text: 'New Status',
                              style: textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                              children: const [
                                TextSpan(
                                  text: ' *',
                                  style: TextStyle(color: Colors.red, fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Status Dropdown
                          DropdownButtonFormField<String>(
                            value: _selectedStatus,
                            decoration: InputDecoration(
                              hintText: 'Select new status',
                              filled: true,
                              fillColor: colorScheme.surface,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: colorScheme.outline.withValues(alpha: 0.5),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: colorScheme.outline.withValues(alpha: 0.5),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: colorScheme.primary),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                            items: _statusOptions.map((status) {
                              return DropdownMenuItem<String>(
                                value: status['value'],
                                child: Text(status['value']),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedStatus = value;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select a new status';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 12),

                          // Helper Text
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 16,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Select the new status for this payment note',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 32),

                          // Action Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton.icon(
                                onPressed: _handleCancel,
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 16,
                                  ),
                                  side: BorderSide(
                                    color: colorScheme.outline.withValues(alpha: 0.5),
                                  ),
                                  foregroundColor: colorScheme.onSurface,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                icon: const Icon(Icons.close, size: 18),
                                label: Text(
                                  'Cancel',
                                  style: textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton.icon(
                                onPressed: _submitForm,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
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
                                icon: const Icon(Icons.check_circle, size: 18),
                                label: Text(
                                  'Update Status',
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 24),

                // Sidebar - Payment Details & Status Guide
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      // Payment Note Details
                      Container(
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          border: Border.all(
                            color: colorScheme.outline.withValues(alpha: 0.3),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  size: 18,
                                  color: colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Payment Note Details',
                                  style: textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildDetailRow('Note No:', widget.payment.sno.toString(), colorScheme, textTheme),
                            _buildDetailRow('Subject:', 'Payment for ${widget.payment.projectName}', colorScheme, textTheme),
                            _buildDetailRow('Amount:', widget.payment.invoiceValue, colorScheme, textTheme),
                            _buildDetailRow('Green Note:', 'PO/FY25-26/0008', colorScheme, textTheme),
                            const SizedBox(height: 12),
                            PrimaryButton(
                              onPressed: () {},
                              icon: Icons.link,
                              label: 'View Details',
                              backgroundColor: Colors.green,
                            )

                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Status Guide
                      Container(
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          border: Border.all(
                            color: colorScheme.outline.withValues(alpha: 0.3),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.help_outline,
                                  size: 18,
                                  color: colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Status Guide',
                                  style: textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            ..._statusOptions.map((status) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: (status['color'] as Color).withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        status['icon'],
                                        size: 18,
                                        color: status['color'],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        status['label'],
                                        style: textTheme.bodySmall?.copyWith(
                                          color: colorScheme.onSurface,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, ColorScheme colorScheme, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
