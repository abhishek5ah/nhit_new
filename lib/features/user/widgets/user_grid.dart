import 'package:flutter/material.dart';
import 'package:ppv_components/common_widgets/profile_card.dart';
import 'package:ppv_components/core/utils/status_utils.dart';
import 'package:ppv_components/features/user/model/user_model.dart';
import 'package:ppv_components/core/utils/responsive.dart';



class UserGridView extends StatefulWidget {
  final List<User> userList;
  final int rowsPerPage;
  final int currentPage;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int?> onRowsPerPageChanged;

  const UserGridView({
    super.key,
    required this.userList,
    required this.rowsPerPage,
    required this.currentPage,
    required this.onPageChanged,
    required this.onRowsPerPageChanged, required List<User> userData,
  });

  @override
  State<UserGridView> createState() => _UserGridViewState();
}

class _UserGridViewState extends State<UserGridView> {
  int? _hoveredCardIndex;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = getResponsiveCrossAxisCount(screenWidth);

    int start = widget.currentPage * widget.rowsPerPage;
    int end = (start + widget.rowsPerPage).clamp(0, widget.userList.length);
    final paginatedUsers = widget.userList.sublist(start, end);

    int totalPages = (widget.userList.length / widget.rowsPerPage).ceil();

    // Pagination show only 3 icons in bottom
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
              itemCount: paginatedUsers.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: 1.2,
              ),
              itemBuilder: (context, index) {
                final user = paginatedUsers[index];
                final globalIndex = start + index;
                final isHovered = _hoveredCardIndex == globalIndex;

                final Color roleColor =
                gridStatusColors[globalIndex % gridStatusColors.length];

                return MouseRegion(
                  onEnter: (_) => setState(() => _hoveredCardIndex = globalIndex),
                  onExit: (_) => setState(() => _hoveredCardIndex = null),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
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
                      invoiceId: '#User-${user.id.toString().padLeft(3, '0')}',
                      topBarColor: roleColor,
                      fields: {
                        'Name': user.name,
                        'Email': user.email,
                        'Username': user.username,
                        'Roles': user.roles.join(', '),
                      },
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
                "Showing ${widget.userList.isEmpty ? 0 : start + 1} to $end of ${widget.userList.length} entries",
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: widget.currentPage > 0
                        ? () => widget.onPageChanged(widget.currentPage - 1)
                        : null,
                  ),
                  for (int i = startWindow; i < endWindow; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: i == widget.currentPage
                              ? colorScheme.primary
                              : colorScheme.surfaceContainerLow,
                          foregroundColor: i == widget.currentPage
                              ? Colors.white
                              : colorScheme.onSurface,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          minimumSize: const Size(0, 36),
                        ),
                        child: Text("${i + 1}"),
                        onPressed: () => widget.onPageChanged(i),
                      ),
                    ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: widget.currentPage < totalPages - 1
                        ? () => widget.onPageChanged(widget.currentPage + 1)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  DropdownButton<int>(
                    value: widget.rowsPerPage,
                    items: [5, 10, 20, 50]
                        .map((count) => DropdownMenuItem<int>(
                      value: count,
                      child: Text('$count'),
                    ))
                        .toList(),
                    onChanged: widget.onRowsPerPageChanged,
                    style: Theme.of(context).textTheme.bodyLarge,
                    underline: const SizedBox(),
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
