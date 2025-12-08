import 'package:flutter/material.dart';
import 'package:ppv_components/common_widgets/profile_card.dart';
import 'package:ppv_components/core/accessibility/accessibility_utils.dart';
import 'package:ppv_components/features/roles/data/models/role_models.dart';
import 'package:ppv_components/core/utils/responsive.dart';
import 'package:ppv_components/core/utils/status_utils.dart'; // import your status colors here

class RolesGridView extends StatefulWidget {
  final List<RoleModel> roleList;
  final int rowsPerPage;
  final int currentPage;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int?> onRowsPerPageChanged;

  const RolesGridView({
    super.key,
    required this.roleList,
    required this.rowsPerPage,
    required this.currentPage,
    required this.onPageChanged,
    required this.onRowsPerPageChanged,
  });

  @override
  State<RolesGridView> createState() => _RolesGridViewState();
}

String _resolveRoleId(RoleModel role) {
  final id = role.roleId;
  if (id == null || id.isEmpty) {
    return '#Role-N/A';
  }
  final trimmed = id.length > 6 ? id.substring(0, 6) : id;
  return '#Role-$trimmed';
}

class _RolesGridViewState extends State<RolesGridView> {
  int? _hoveredCardIndex;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = getResponsiveCrossAxisCount(screenWidth);

    int start = widget.currentPage * widget.rowsPerPage;
    int end = (start + widget.rowsPerPage).clamp(0, widget.roleList.length);
    final paginatedRoles = widget.roleList.sublist(start, end);

    int totalPages = (widget.roleList.length / widget.rowsPerPage).ceil();

    // Pagination show exactly 3 page buttons sliding:
    int windowSize = 3;
    int startWindow = 0;
    int endWindow = totalPages;
    if (totalPages > windowSize) {
      if (widget.currentPage == 0) {
        startWindow = 0;
        endWindow = 3;
      } else if (widget.currentPage == totalPages - 1) {
        startWindow = totalPages - 3;
        endWindow = totalPages;
      } else {
        startWindow = widget.currentPage - 1;
        endWindow = widget.currentPage + 2;
      }
    }

    return Column(
      children: [
        Expanded(
          child: Container(
            color: colorScheme.surfaceContainerHigh,
            padding: const EdgeInsets.all(12),
            child: GridView.builder(
              itemCount: paginatedRoles.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: 1.2,
              ),
              itemBuilder: (context, index) {
                final role = paginatedRoles[index];
                final globalIndex = start + index;
                final isHovered = _hoveredCardIndex == globalIndex;

                final Color roleColor = gridStatusColors[globalIndex % gridStatusColors.length];

                final roleLabel = 'Role ${role.name}, ${role.permissions.length} permissions';
                return MouseRegion(
                  onEnter: (_) => setState(() => _hoveredCardIndex = globalIndex),
                  onExit: (_) => setState(() => _hoveredCardIndex = null),
                  child: FocusableActionDetector(
                    autofocus: index == 0 && widget.currentPage == 0,
                    actions: {},
                    onShowFocusHighlight: (_) {},
                    child: Semantics(
                      label: roleLabel,
                      container: true,
                      child: AnimatedContainer(
                        duration: AccessibilityUtils.getAnimationDuration(context),
                        decoration: BoxDecoration(
                          border: isHovered
                              ? Border(
                                  top: BorderSide(color: roleColor, width: 6),
                                  left: BorderSide(color: roleColor, width: 6),
                                )
                              : null,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(24),
                            topRight: Radius.circular(22),
                            bottomLeft: Radius.circular(18),
                            bottomRight: Radius.circular(18),
                          ),
                          color: colorScheme.surface,
                        ),
                        child: ProfileCard(
                          invoiceId: _resolveRoleId(role),
                          topBarColor: roleColor,
                          fields: {
                            'Role Name': role.name,
                            'Permissions':
                                role.permissions.isEmpty ? 'No permissions assigned' : role.permissions.join(', '),
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Showing ${widget.roleList.isEmpty ? 0 : start + 1} to $end of ${widget.roleList.length} entries",
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    tooltip: 'Previous page',
                    onPressed: widget.currentPage > 0
                        ? () => widget.onPageChanged(widget.currentPage - 1)
                        : null,
                  ),
                  for (int i = startWindow; i < endWindow; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                      child: ElevatedButton(
                        onFocusChange: (hasFocus) {
                          if (hasFocus) {
                            AccessibilityUtils.announceToScreenReader(
                              context,
                              'Page ${i + 1} of $totalPages',
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: i == widget.currentPage
                              ? colorScheme.primary
                              : colorScheme.surfaceContainerLow,
                          foregroundColor: i == widget.currentPage
                              ? Colors.white
                              : colorScheme.onSurface,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          minimumSize: const Size(0, 36),
                        ),
                        child: Semantics(
                          button: true,
                          label: 'Go to page ${i + 1}',
                          selected: i == widget.currentPage,
                          child: Text('${i + 1}'),
                        ),
                        onPressed: () => widget.onPageChanged(i),
                      ),
                    ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    tooltip: 'Next page',
                    onPressed: widget.currentPage < totalPages - 1
                        ? () => widget.onPageChanged(widget.currentPage + 1)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  DropdownButton<int>(
                    value: widget.rowsPerPage,
                    underline: const SizedBox(),
                    dropdownColor: colorScheme.surface,
                    items: [5, 10, 20, 50]
                        .map((count) => DropdownMenuItem<int>(
                      value: count,
                      child: Text('$count rows per page',
                          style: Theme.of(context).textTheme.bodyLarge),
                    ))
                        .toList(),
                    onChanged: widget.onRowsPerPageChanged,
                    style: Theme.of(context).textTheme.bodyLarge,
                    hint: const Text('Rows per page'),
                  ),
                  Text("page", style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
