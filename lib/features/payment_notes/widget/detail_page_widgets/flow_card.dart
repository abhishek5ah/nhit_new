import 'package:flutter/material.dart';
import 'package:ppv_components/common_widgets/badge.dart';

class FlowCard extends StatelessWidget {
  final List<dynamic> steps;

  const FlowCard({
    required this.steps,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.only(top: 24, left: 8, right: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon
          Row(
            children: [
              Icon(
                Icons.approval,
                color: colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Approval Flow',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Timeline steps
          ...steps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            final isLastStep = index == steps.length - 1;

            return _buildTimelineStep(
              context,
              step: step,
              isLastStep: isLastStep,
            );
          }).toList(),

          // Final approval complete indicator
          _buildApprovalComplete(context, steps.last),
        ],
      ),
    );
  }

  Widget _buildTimelineStep(
      BuildContext context, {
        required dynamic step,
        required bool isLastStep,
      }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline indicator
        Column(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(
                  color: colorScheme.surface,
                  width: 2,
                ),
              ),
            ),
            if (!isLastStep)
              Container(
                width: 3,
                height: 120,
                color: colorScheme.primary,
              ),
          ],
        ),
        const SizedBox(width: 16),

        // Step content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Step ${step.step}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Reviewer: ${step.makerName}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Date: ${step.dateTime}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Remarks: Approved',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),

              // Status badge using BadgeChip
              BadgeChip(
                label: step.status,
                type: ChipType.status,
                statusKey: step.status,
                backgroundColor: Colors.green,
                textColor: Colors.white,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildApprovalComplete(BuildContext context, dynamic lastStep) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline indicator - checkmark
        Column(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(
                  color: colorScheme.surface,
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 10,
              ),
            ),
          ],
        ),
        const SizedBox(width: 16),

        // Approval complete content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Approval Complete',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Final approval badge using BadgeChip (full width)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Center(
                  child: BadgeChip(
                    label: 'Fully Approved',
                    type: ChipType.status,
                    statusKey: 'Fully Approved',
                    backgroundColor: Colors.green,
                    textColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Final approval text
              Text(
                'Final approval by ${lastStep.makerName} on ${lastStep.dateTime}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
