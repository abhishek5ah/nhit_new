import 'package:flutter/material.dart';

class ProfileInfoCard extends StatelessWidget {
  final String title;
  final String company;
  final String email;
  final String phone;
  final String source;
  final Color? topBarColor;


  const ProfileInfoCard({
    super.key,
    required this.title,
    required this.company,
    required this.email,
    required this.phone,
    required this.source,
    this.topBarColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardBg = theme.colorScheme.surfaceContainer; // Card background
    final labelColor = theme.colorScheme.onSurface; // Label text
    final topColor = topBarColor ?? theme.colorScheme.primary; //
    final fieldBg = theme.colorScheme.onSurface.withValues(
      alpha: 0.09,
    ); // Input field background
    final fieldText = theme.colorScheme.onSurface; // Input text

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(1, 2),
          ),
        ],
      ),
      constraints: const BoxConstraints(maxWidth: 20, minWidth: 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: topColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Center(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Always white title for contrast
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 52, vertical: 18),
            child: Column(
              children: [
                _infoRow('Company', company, labelColor, fieldBg, fieldText),
                const SizedBox(height: 10),
                _infoRow('Email', email, labelColor, fieldBg, fieldText),
                const SizedBox(height: 10),
                _infoRow('Phone', phone, labelColor, fieldBg, fieldText),
                const SizedBox(height: 10),
                _infoRow('Source', source, labelColor, fieldBg, fieldText),
              ],
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 75,
          child: Text(
            label,
            style: TextStyle(
              color: labelColor,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: fieldBg,
              borderRadius: BorderRadius.circular(18),
            ),
            alignment: Alignment.center,
            child: Text(
              value,
              style: TextStyle(color: fieldText, fontSize: 15),
            ),
          ),
        ),
      ],
    );
  }
}
