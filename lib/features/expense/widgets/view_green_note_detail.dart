import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ppv_components/common_widgets/button/secondary_button.dart';
import 'package:ppv_components/common_widgets/badge.dart';
import '../models/green_note_model.dart';

class ViewGreenNoteDetail extends StatelessWidget {
  final GreenNote note;
  final VoidCallback onClose;

  const ViewGreenNoteDetail({
    super.key,
    required this.note,
    required this.onClose,
  });

  String _formatDate(String? date) {
    if (date == null || date.isEmpty) return 'N/A';
    try {
      final parsedDate = DateTime.parse(date);
      return DateFormat('dd/MM/yyyy').format(parsedDate);
    } catch (e) {
      return date;
    }
  }

  String _formatCurrency(double value) {
    return '₹${value.toStringAsFixed(2)}';
  }

  String _formatYesNo(String value) {
    if (value.toUpperCase() == 'YES') return 'Yes';
    if (value.toUpperCase() == 'NO') return 'No';
    return value.isEmpty ? 'N/A' : value;
  }

  String _formatEnum(String value) {
    if (value.isEmpty) return 'N/A';
    // Convert EXPENSE_CATEGORY_CAPITAL to "Capital"
    return value
        .replaceAll('EXPENSE_CATEGORY_', '')
        .replaceAll('APPROVAL_FOR_', '')
        .replaceAll('NATURE_OHC_001_', '')
        .replaceAll('NATURE_OHC_002_', '')
        .replaceAll('NATURE_OHC_003_', '')
        .replaceAll('STATUS_', '')
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'status_approved':
      case 'approved':
        return Colors.green;
      case 'status_pending':
      case 'pending':
        return Colors.orange;
      case 'status_rejected':
      case 'rejected':
        return Colors.red;
      case 'status_draft':
      case 'draft':
        return Colors.grey;
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(colorScheme, theme),
            const SizedBox(height: 16),
            _buildBasicInfoCard(colorScheme, theme),
            const SizedBox(height: 16),
            _buildFinancialDetailsCard(colorScheme, theme),
            const SizedBox(height: 16),
            _buildContractDetailsCard(colorScheme, theme),
            const SizedBox(height: 16),
            _buildInvoicesCard(colorScheme, theme),
            const SizedBox(height: 16),
            _buildComplianceCard(colorScheme, theme),
            const SizedBox(height: 16),
            _buildBudgetCard(colorScheme, theme),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SecondaryButton(
                  label: 'Back to All Notes',
                  icon: Icons.arrow_back,
                  onPressed: onClose,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.5), width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.visibility, size: 24, color: colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'View Expense Note',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Expense note details and information',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          BadgeChip(
            label: _formatEnum(note.status),
            type: ChipType.status,
            statusKey: note.status,
            statusColorFunc: _getStatusColor,
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoCard(ColorScheme colorScheme, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.5), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Basic Information',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildDetailField('Project Name', note.projectName, theme)),
              const SizedBox(width: 16),
              Expanded(child: _buildDetailField('Supplier Name', note.supplierName, theme)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildDetailField('Department', note.departmentName, theme)),
              const SizedBox(width: 16),
              Expanded(child: _buildDetailField('Approval For', _formatEnum(note.approvalFor), theme)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildDetailField('Work Order No', note.workOrderNo, theme)),
              const SizedBox(width: 16),
              Expanded(child: _buildDetailField('PO Number', note.poNumber, theme)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildDetailField('Work Order Date', _formatDate(note.workOrderDate), theme)),
              const SizedBox(width: 16),
              Expanded(child: _buildDetailField('Expense Category', _formatEnum(note.expenseCategoryType), theme)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildDetailField('MSME Classification', note.msmeClassification, theme)),
              const SizedBox(width: 16),
              Expanded(child: _buildDetailField('Activity Type', note.activityType, theme)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildDetailField('Nature of Expenses', _formatEnum(note.natureOfExpenses), theme)),
              const SizedBox(width: 16),
              Expanded(child: _buildDetailField('Created At', _formatDate(note.createdAt), theme)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialDetailsCard(ColorScheme colorScheme, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.5), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance_wallet, color: colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Financial Details',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildDetailField('Base Value', _formatCurrency(note.baseValue), theme)),
              const SizedBox(width: 16),
              Expanded(child: _buildDetailField('GST', _formatCurrency(note.gst), theme)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildDetailField('Other Charges', _formatCurrency(note.otherCharges), theme)),
              const SizedBox(width: 16),
              Expanded(child: _buildDetailField('Total Amount', _formatCurrency(note.totalAmount), theme, highlight: true)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContractDetailsCard(ColorScheme colorScheme, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.5), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.description, color: colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Contract Details',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildDetailField('Whether Contract', _formatYesNo(note.whetherContract), theme)),
              const SizedBox(width: 16),
              Expanded(child: _buildDetailField('Contract Period Completed', _formatYesNo(note.contractPeriodCompleted), theme)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildDetailField('Contract Start Date', _formatDate(note.contractStartDate), theme)),
              const SizedBox(width: 16),
              Expanded(child: _buildDetailField('Contract End Date', _formatDate(note.contractEndDate), theme)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildDetailField('Appointed Start Date', _formatDate(note.appointedStartDate), theme)),
              const SizedBox(width: 16),
              Expanded(child: _buildDetailField('Supply Period Start', _formatDate(note.supplyPeriodStart), theme)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildDetailField('Supply Period End', _formatDate(note.supplyPeriodEnd), theme)),
              const SizedBox(width: 16),
              Expanded(child: _buildDetailField('Brief of Goods/Services', note.briefOfGoodsServices, theme)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInvoicesCard(ColorScheme colorScheme, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.5), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.receipt_long, color: colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Invoices (${note.invoices.length})',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (note.invoices.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'No invoices available',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ),
            )
          else
            ...note.invoices.asMap().entries.map((entry) {
              final index = entry.key;
              final invoice = entry.value;
              return Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Invoice ${index + 1}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Invoice Number', style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.6))),
                              const SizedBox(height: 4),
                              Text(invoice.invoiceNumber, style: theme.textTheme.bodyMedium),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Invoice Date', style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.6))),
                              const SizedBox(height: 4),
                              Text(_formatDate(invoice.invoiceDate), style: theme.textTheme.bodyMedium),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Taxable Value', style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.6))),
                              const SizedBox(height: 4),
                              Text(_formatCurrency(invoice.taxableValue), style: theme.textTheme.bodyMedium),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Invoice Value', style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.6))),
                              const SizedBox(height: 4),
                              Text(
                                _formatCurrency(invoice.invoiceValue),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildComplianceCard(ColorScheme colorScheme, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.5), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.fact_check, color: colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Compliance & Verification',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildDetailField('Protest Note Raised', _formatYesNo(note.protestNoteRaised), theme)),
              const SizedBox(width: 16),
              Expanded(child: _buildDetailField('Contract Extension', _formatYesNo(note.extensionOfContractPeriodExecuted), theme)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildDetailField('Milestone Achieved', _formatYesNo(note.milestoneAchieved), theme)),
              const SizedBox(width: 16),
              Expanded(child: _buildDetailField('Expense Within Contract', _formatYesNo(note.expenseAmountWithinContract), theme)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildDetailField('Payment With Deviation', _formatYesNo(note.paymentApprovedWithDeviation), theme)),
              const SizedBox(width: 16),
              Expanded(child: _buildDetailField('Documents Submitted', _formatYesNo(note.requiredDocumentsSubmitted), theme)),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailField('Documents Verified', note.documentsVerified, theme),
          const SizedBox(height: 16),
          _buildDetailField('Milestone Remarks', note.milestoneRemarks, theme, maxLines: 3),
          const SizedBox(height: 16),
          _buildDetailField('Specify Deviation', note.specifyDeviation, theme, maxLines: 3),
          const SizedBox(height: 16),
          _buildDetailField('Documents Discrepancy', note.documentsDiscrepancy, theme, maxLines: 3),
          const SizedBox(height: 16),
          _buildDetailField('Delayed Damages', note.delayedDamages, theme),
        ],
      ),
    );
  }

  Widget _buildBudgetCard(ColorScheme colorScheme, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.5), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.pie_chart, color: colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Budget Information',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildDetailField('Budget Expenditure', _formatCurrency(note.budgetExpenditure), theme)),
              const SizedBox(width: 16),
              Expanded(child: _buildDetailField('Actual Expenditure', _formatCurrency(note.actualExpenditure), theme)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildDetailField('Expenditure Over Budget', _formatCurrency(note.expenditureOverBudget), theme)),
              const SizedBox(width: 16),
              Expanded(child: _buildDetailField('Amount Retained', _formatCurrency(note.amountRetainedForNonSubmission), theme)),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailField('Remarks', note.remarks, theme, maxLines: 3),
          const SizedBox(height: 16),
          _buildDetailField('Auditor Remarks', note.auditorRemarks, theme, maxLines: 3),
        ],
      ),
    );
  }

  Widget _buildDetailField(String label, String value, ThemeData theme, {int maxLines = 1, bool highlight = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: highlight ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3) : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.5)),
          ),
          child: Text(
            value.isEmpty ? 'N/A' : value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: highlight ? theme.colorScheme.primary : theme.colorScheme.onSurface,
              fontWeight: highlight ? FontWeight.w600 : FontWeight.normal,
            ),
            maxLines: maxLines,
            overflow: maxLines > 1 ? TextOverflow.visible : TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
