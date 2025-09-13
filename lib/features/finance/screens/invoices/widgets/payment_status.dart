import 'package:flutter/material.dart';

class PaymentStatusWidget extends StatelessWidget {
  const PaymentStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final text = theme.textTheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainer, // uses theme card color
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha:0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Payment Status",
            style: text.titleLarge?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Track payment information",
            style: text.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.normal,
            ),
          ),
          const SizedBox(height: 24),
          // Status Row
          Row(
            children: [
              Text("Status", style: text.bodyMedium?.copyWith(
                color: cs.onSurface,
                fontWeight: FontWeight.w500,
              )),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
                decoration: BoxDecoration(
                  color: cs.secondaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  "Paid",
                  style: TextStyle(
                    color: cs.secondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _KVRow(
            label: "Amount",
            value: "₹1,20,000.00",
            valueStyle: text.titleMedium?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
          _KVRow(
            label: "Payment Date",
            value: "2023-04-15",
            valueStyle: text.bodyMedium?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
          _KVRow(
            label: "Payment Method",
            value: "Bank Transfer",
            valueStyle: text.bodyMedium?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
          _KVRow(
            label: "Transaction ID",
            value: "TXN123456789",
            valueStyle: text.bodyMedium?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// Key-Value Row aligned right for values
class _KVRow extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? valueStyle;

  const _KVRow({
    required this.label,
    required this.value,
    this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final text = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: text.bodyMedium?.copyWith(
                color: cs.onSurface,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          Text(
            value,
            style: valueStyle ?? text.bodyMedium?.copyWith(color: cs.onSurface),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }
}
