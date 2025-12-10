import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ppv_components/features/reimbursement/models/reimbursement_models/travel_detail_model.dart';
import 'package:ppv_components/common_widgets/button/secondary_button.dart';

class ViewReimbursementDetail extends StatelessWidget {
  final ReimbursementNote note;

  const ViewReimbursementDetail({
    super.key,
    required this.note,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, colorScheme, theme),
              const SizedBox(height: 16),
              _buildReimbursementInfoSection(context, colorScheme, theme),
              const SizedBox(height: 24),
              _buildActionButtons(context, colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme colorScheme, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.5),
          width: 0.5,
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
            child: Icon(
              Icons.visibility,
              size: 24,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'View Reimbursement Note',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Reimbursement note details and information',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          SecondaryButton(
            label: 'Back to Notes',
            icon: Icons.arrow_back,
            onPressed: () => context.go('/reimbursement-note'),
          ),
        ],
      ),
    );
  }

  Widget _buildReimbursementInfoSection(BuildContext context, ColorScheme colorScheme, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.5),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.receipt_long,
                color: colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Reimbursement Information',
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
              Expanded(
                child: _buildDetailField(context, "S.No", note.sNo, theme),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDetailField(context, "Project Name", note.projectName, theme),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDetailField(context, "Employee Name", note.employeeName, theme),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDetailField(context, "Amount", '₹${note.amount}', theme),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDetailField(context, "Date", note.date, theme),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDetailField(context, "Status", note.status, theme),
              ),
            ],
          ),
          if (note.nextApprover.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildDetailField(context, "Next Approver", note.nextApprover, theme),
          ],
          if (note.utrNumber.isNotEmpty) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildDetailField(context, "UTR Number", note.utrNumber, theme),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDetailField(context, "UTR Date", note.utrDate, theme),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailField(
    BuildContext context,
    String label,
    String value,
    ThemeData theme, {
    int maxLines = 1,
  }) {
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
          padding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: maxLines > 1 ? 14 : 14,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.5),
            ),
          ),
          child: Text(
            value.isEmpty ? 'N/A' : value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
            maxLines: maxLines,
            overflow: maxLines > 1 ? TextOverflow.visible : TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SecondaryButton(
          label: 'Close',
          icon: Icons.close,
          onPressed: () => context.go('/reimbursement-note'),
        ),
      ],
    );
  }
}
