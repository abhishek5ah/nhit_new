import 'package:flutter/material.dart';

class ProfileInfoCard extends StatelessWidget {
  final String title;
  final String company;
  final String email;
  final String phone;
  final String source;
  final Color? topBarColor;
  final double contentPadding;

  const ProfileInfoCard({
    super.key,
    required this.title,
    required this.company,
    required this.email,
    required this.phone,
    required this.source,
    this.topBarColor,
    this.contentPadding = 16,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardBg = theme.colorScheme.surfaceContainer;
    final labelColor = theme.colorScheme.onSurface;
    final topColor = topBarColor ?? theme.colorScheme.primary;
    final fieldBg = theme.colorScheme.onSurface.withValues(alpha:0.09);
    final fieldText = theme.colorScheme.onSurface;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.04),
            blurRadius: 4,
            offset: const Offset(1, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            // Adjust vertical padding for smaller screens if contentPadding is very small
            padding: EdgeInsets.symmetric(vertical: contentPadding / 1.5),
            decoration: BoxDecoration(
              color: topColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: contentPadding / 2),
                child: Text(
                  title,
                  style: TextStyle( // Use TextStyle for more control
                    fontSize: 19, // You might want to make this responsive too
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1, // Ensure title also truncates
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: contentPadding, vertical: contentPadding / 1.5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _infoRow('Company', company, labelColor, fieldBg, fieldText),
                  const SizedBox(height: 12),
                  _infoRow('Email', email, labelColor, fieldBg, fieldText),
                  const SizedBox(height: 12),
                  _infoRow('Phone', phone, labelColor, fieldBg, fieldText),
                  const SizedBox(height: 12),
                  _infoRow('Source', source, labelColor, fieldBg, fieldText),
                ],
              ),

            ),
          ),
        ],
      ),
    );
  }

  static Widget _infoRow(
      String label,
      String value,
      Color labelColor,
      Color fieldBg,
      Color fieldText,
      ) {
    return Expanded( // Make each info row take equal space if possible
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 72, // we need to adjust this for small screen
            child: Text(
              label,
              style: TextStyle(
                color: labelColor,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          const SizedBox(width: 12), // Added a small fixed space
          Expanded( // This Expanded is crucial for the value field
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              decoration: BoxDecoration(
                color: fieldBg,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: TextStyle(color: fieldText, fontSize: 14),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}