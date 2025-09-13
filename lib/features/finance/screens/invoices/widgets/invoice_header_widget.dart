import 'package:flutter/material.dart';
import 'package:ppv_components/common_widgets/button/primary_button.dart';
import 'package:ppv_components/common_widgets/button/secondary_button.dart';

class InvoiceHeaderWidget extends StatelessWidget {
  final String invoiceNumber;

  const InvoiceHeaderWidget({required this.invoiceNumber, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final text = theme.textTheme;
    final width = MediaQuery.of(context).size.width;
    final isTablet = width < 1150;

    return Padding(
      padding: const EdgeInsets.only(left: 12, top: 6),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Back Arrow
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(Icons.arrow_back, color: cs.onSurface, size: 26),
                tooltip: 'Back',
                style: IconButton.styleFrom(
                  minimumSize: const Size(40, 40),
                  padding: EdgeInsets.zero,
                ),
              ),
              const SizedBox(width: 2),
              // Main Title and Subtitle
              Expanded(
                flex: isTablet ? 3 : 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: text.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: cs.onSurface,
                        ),
                        children: [
                          const TextSpan(text: 'Invoice '),
                          TextSpan(
                            text: '#$invoiceNumber',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      "View invoice details and manage payments",
                      style: text.bodySmall?.copyWith(color: cs.onSurface),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Spacer(),

              Flexible(
                flex: isTablet ? 4 : 5,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final maxWidth = constraints.maxWidth;
                    final buttonCount = 4;
                    final spacing = 8 * (buttonCount - 1);
                    final availableWidth = maxWidth - spacing;
                    final buttonWidth = availableWidth / buttonCount;

                    Widget flexibleButton(Widget button) {
                      return ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: buttonWidth),
                        child: FractionallySizedBox(
                          widthFactor: 1,
                          child: button,
                        ),
                      );
                    }

                    return Wrap(
                      alignment: WrapAlignment.end,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        flexibleButton(
                          PrimaryButton(
                            icon: Icons.edit,
                            label: 'Edit',
                            onPressed: () {},
                          ),
                        ),
                        flexibleButton(
                          SecondaryButton(
                            icon: Icons.download,
                            label: 'Export',
                            onPressed: () {},
                          ),
                        ),
                        flexibleButton(
                          SecondaryButton(
                            icon: Icons.send,
                            label: 'Send',
                            onPressed: () {},
                          ),
                        ),
                        flexibleButton(
                          SecondaryButton(
                            icon: Icons.print,
                            label: 'Print',
                            onPressed: () {},
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
