import 'package:flutter/material.dart';

enum AvatarSize { small, medium, large }

class Avatar extends StatelessWidget {
  final String? imageUrl;
  final String initials;
  final AvatarSize size;

  static const Map<AvatarSize, double> _sizeRadius = {
    AvatarSize.small: 16,
    AvatarSize.medium: 24,
    AvatarSize.large: 32,
  };

  const Avatar({
    super.key,
    this.imageUrl,
    required this.initials,
    this.size = AvatarSize.medium,
  });

  @override
  Widget build(BuildContext context) {
    final radius = _sizeRadius[size] ?? 24;
    final diameter = radius * 2;

    return SizedBox(
      width: diameter,
      height: diameter,
      child: Center(
        child: Container(
          width: diameter,
          height: diameter,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: ClipOval(
            child: imageUrl != null && imageUrl!.isNotEmpty
                ? Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              width: diameter,
              height: diameter,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: progress.expectedTotalBytes != null
                        ? progress.cumulativeBytesLoaded /
                        progress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return _buildInitialsText(context, radius);
              },
            )
                : _buildInitialsText(context, radius),
          ),
        ),
      ),
    );
  }

  Widget _buildInitialsText(BuildContext context, double radius) {
    return Center(
      child: Text(
        initials.toUpperCase(),
        style: TextStyle(
          fontSize: _fontSizeForRadius(radius),
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }

  double _fontSizeForRadius(double radius) {
    if (radius <= 16) return 10;
    if (radius <= 24) return 14;
    return 18;
  }
}
