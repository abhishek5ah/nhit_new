import 'package:flutter/material.dart';
import 'package:ppv_components/common_widgets/button/primary_button.dart';
import 'package:ppv_components/common_widgets/button/secondary_button.dart';

class ActionCard extends StatelessWidget {
  final VoidCallback? onAddReceipt;
  final VoidCallback? onExportPdf;
  const ActionCard({super.key, this.onAddReceipt, this.onExportPdf});

  @override
  Widget build(BuildContext context) {

    return Card(
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).colorScheme.outline, width: 0.25),
        ),
        padding: const EdgeInsets.all(20),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Actions', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: SecondaryButton(
                icon: Icons.receipt_long,
                label: 'Add Receipt',
                onPressed: onAddReceipt,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                icon: Icons.download,
                label: 'Export as PDF',
                onPressed: onExportPdf,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
