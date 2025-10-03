import 'package:flutter/material.dart';
class ProfileCard extends StatelessWidget {
  final String invoiceId;
  final Map<String, String> fields;
  final Color topBarColor;
  final double cardRadius;
  final double cardPadding;
  final double cardSpacing;

  const ProfileCard({
    super.key,
    required this.invoiceId,
    required this.fields,
    required this.topBarColor,
    this.cardRadius = 18,
    this.cardPadding = 20,
    this.cardSpacing = 14,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardBg = theme.colorScheme.surface;
    final labelColor = theme.colorScheme.onSurface.withValues(alpha:0.9);
    final fieldBg = theme.colorScheme.onSurface.withValues(alpha:0.18); // for clear contrast
    final fieldText = theme.colorScheme.onSurface;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate scale from width, then clamp it to a min and max scale for readability
          double scale = (constraints.maxWidth / 300).clamp(0.7, 1.0);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Card Header
              Container(
                decoration: BoxDecoration(
                  color: topBarColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(cardRadius - 2),
                    topRight: Radius.circular(cardRadius - 2),
                  ),
                ),
                padding: EdgeInsets.symmetric(vertical: cardPadding * 0.7),
                child: Center(
                  child: Text(
                    invoiceId,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 23 * scale,  // Responsive font size
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),

              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(cardPadding),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final entry in fields.entries)
                          Padding(
                            padding: EdgeInsets.only(bottom: cardSpacing),
                            child: _fieldRow(entry.key, entry.value, labelColor, fieldBg, fieldText, scale),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  static Widget _fieldRow(
      String label, String value, Color labelColor, Color fieldBg, Color fieldText, double scale) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 85 * scale,  // Responsive width
          child: Text(
            label,
            style: TextStyle(
              color: labelColor,
              fontWeight: FontWeight.w500,
              fontSize: 15 * scale, // responsive font size
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 8 * scale, horizontal: 12 * scale),
            decoration: BoxDecoration(
              color: fieldBg,
              borderRadius: BorderRadius.circular(9 * scale),
            ),
            child: Text(
              value,
              style: TextStyle(
                color: fieldText,
                fontSize: 15 * scale,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }
}
