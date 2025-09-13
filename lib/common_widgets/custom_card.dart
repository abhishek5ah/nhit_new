import 'package:flutter/material.dart';

enum CardVariant { simple, clickable, withImage }

class CustomCard extends StatelessWidget {
  final Widget? header;
  final Widget? body;
  final Widget? footer;
  final CardVariant variant;
  final VoidCallback? onTap;
  final String? imageUrl;
  final double? elevation;
  final EdgeInsetsGeometry? padding;

  const CustomCard({
    super.key,
    this.header,
    this.body,
    this.footer,
    this.variant = CardVariant.simple,
    this.onTap,
    this.imageUrl,
    this.elevation = 2,
    this.padding,
  });

  bool get _isClickable => variant == CardVariant.clickable && onTap != null;
  bool get _hasImage => variant == CardVariant.withImage && imageUrl != null;

  @override
  Widget build(BuildContext context) {
    final cardContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_hasImage)
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              imageUrl!,
              width: double.infinity,
              height: 180,
              fit: BoxFit.cover,
            ),
          ),
        Padding(
          padding: padding ?? const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (header != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: DefaultTextStyle(
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge!
                        .copyWith(fontWeight: FontWeight.bold),
                    child: header!,
                  ),
                ),
              if (body != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: body!,
                ),
              if (footer != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: footer!,
                ),
            ],
          ),
        ),
      ],
    );

    return Card(
      elevation: elevation,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: _isClickable
          ? InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: cardContent,
      )
          : cardContent,
    );
  }
}
