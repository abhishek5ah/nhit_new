import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class BreadcrumbItem {
  final String label;
  final String route;

  const BreadcrumbItem({required this.label, required this.route});
}

// Map all routes to breadcrumb labels
const Map<String, String> routeLabels = {
  '/': 'Home',
  '/products': 'Products',
  '/products/details': 'Details',
};

class Breadcrumbs extends StatelessWidget {
  final String? currentLocation;

  const Breadcrumbs({super.key, this.currentLocation});

  List<BreadcrumbItem> _buildBreadcrumbs(BuildContext context) {
    final location =
        currentLocation ??
        GoRouterState.of(context).uri.toString().split('?')[0];

    final segments = <String>[];
    var pathAccumulator = '';

    // Split path into segments to build breadcrumb paths
    for (final part in location.split('/')) {
      if (part.isEmpty) continue;
      pathAccumulator += '/$part';
      segments.add(pathAccumulator);
    }

    //root
    final allPaths = ['/', ...segments];

    // Convert valid routes into breadcrumb items
    return allPaths
        .where(routeLabels.containsKey)
        .map((path) => BreadcrumbItem(label: routeLabels[path]!, route: path))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final items = _buildBreadcrumbs(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isLast = index == items.length - 1;

          return Row(
            children: [
              if (!isLast)
                InkWell(
                  onTap: () => context.go(item.route),
                  child: Text(
                    item.label,
                    style: GoogleFonts.lato(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                )
              else
                Text(
                  item.label,
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              if (!isLast)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(
                    Icons.chevron_right,
                    size: 16,
                    color: Colors.black54,
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }
}
