import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ppv_components/common_widgets/button/primary_button.dart';
import 'package:ppv_components/common_widgets/button/secondary_button.dart';

class BankLetterSuccessModal extends StatelessWidget {
  final String letterId;
  final String letterType;

  const BankLetterSuccessModal({
    super.key,
    required this.letterId,
    required this.letterType,
  });

  static Future<void> show(
    BuildContext context, {
    required String letterId,
    required String letterType,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => BankLetterSuccessModal(
        letterId: letterId,
        letterType: letterType,
      ),
    );
  }

  String _getLetterTypeDisplay() {
    switch (letterType) {
      case 'GENERAL_LETTER':
        return 'General Letter';
      case 'TRANSFER_LETTER':
        return 'Transfer Letter';
      case 'PAYMENT_LETTER':
        return 'Payment Letter';
      default:
        return 'Bank Letter';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success Icon
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                size: 64,
                color: Colors.green.shade600,
              ),
            ),
            const SizedBox(height: 24),

            // Success Title
            Text(
              'Letter Created Successfully!',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Success Message
            Text(
              'Your ${_getLetterTypeDisplay()} has been created and saved.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Letter ID
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.tag,
                    size: 16,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'ID: ${letterId.substring(0, 8).toUpperCase()}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Action Message
            Text(
              'What would you like to do next?',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    label: 'Preview Letter',
                    icon: Icons.preview,
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.go('/escrow/bank-letter/preview/$letterId');
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PrimaryButton(
                    label: 'Send Letter',
                    icon: Icons.send,
                    onPressed: () async {
                      Navigator.of(context).pop();
                      
                      // Show sending progress
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => Center(
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(
                                  color: colorScheme.primary,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Sending letter...',
                                  style: theme.textTheme.bodyLarge,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );

                      // TODO: Implement actual send letter API call
                      await Future.delayed(const Duration(seconds: 2));

                      if (context.mounted) {
                        Navigator.of(context).pop(); // Close progress dialog
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Letter sent successfully!'),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );

                        context.go('/escrow/bank-letter');
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Close Button
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.go('/escrow/bank-letter');
              },
              child: Text(
                'Close and Return to List',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
