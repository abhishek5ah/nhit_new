import 'package:flutter/material.dart';

class AppLoader extends StatelessWidget {
  final bool isLoading;
  final bool isFullScreen;
  final bool showSkeleton;
  final double? width;
  final double? height;
  final BorderRadius? skeletonBorderRadius;

  static const _inlineSize = 18.0;

  const AppLoader({
    super.key,
    required this.isLoading,
    this.isFullScreen = false,
    this.showSkeleton = false,
    this.width,
    this.height,
    this.skeletonBorderRadius,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoading) return const SizedBox.shrink();

    if (showSkeleton) {
      return SkeletonLoader(
        width: width ?? double.infinity,
        height: height ?? 16,
        borderRadius: skeletonBorderRadius ?? BorderRadius.circular(6),
      );
    }

    if (isFullScreen) {
      return Stack(
        children: [
          Opacity(
            opacity: 0.3,
            child: const ModalBarrier(dismissible: false, color: Colors.black),
          ),
          Center(child: CircularProgressIndicator()),
        ],
      );
    }

    // Inline small loader by default
    return SizedBox(
      width: _inlineSize,
      height: _inlineSize,
      child: CircularProgressIndicator(strokeWidth: 2),
    );
  }
}

//Skeleton loading placeholder
class SkeletonLoader extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius borderRadius;

  const SkeletonLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(6)),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: borderRadius,
      ),
    );
  }
}
