import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Sidebar extends StatefulWidget {
  const Sidebar({super.key, required Null Function(dynamic route) onItemSelected});

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> with SingleTickerProviderStateMixin {
  bool isExpanded = true;
  bool isOrgExpanded = false; // Controls organization submenu expand/collapse
  int selectedOrgIndex = -1; // Track selected organization index (-1 means none selected)
  static const double expandedWidth = 200;
  static const double collapsedWidth = 64;
  late AnimationController _controller;
  late Animation<double> widthAnim;

  final List<_SidebarItem> items = [
    _SidebarItem(Icons.dashboard, "Role", "/roles"),
    _SidebarItem(Icons.assignment, "User", "/user"),
    _SidebarItem(Icons.attach_money, "Vendors", "/vendor"),
    _SidebarItem(Icons.group, "Activity", "/activity"),
    _SidebarItem(Icons.group, "Expense", "/expense"),
    _SidebarItem(Icons.account_balance, "Payment Notes", "/payment-notes"),
    _SidebarItem(Icons.travel_explore, "Travel", "/reimbursement"),
    _SidebarItem(Icons.account_balance, "Bank", "/bank"),
    _SidebarItem(Icons.inventory, "Designation", "/designation"),
    _SidebarItem(Icons.business, "Department", "/department"),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    widthAnim = Tween<double>(
      begin: expandedWidth,
      end: collapsedWidth,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  void toggleSidebar() {
    setState(() {
      isExpanded = !isExpanded;
      if (isExpanded) {
        _controller.reverse();
      } else {
        _controller.forward();
        isOrgExpanded = false; // Close org submenu when collapsed
      }
    });
  }

  void toggleOrgExpansion() {
    setState(() {
      isOrgExpanded = !isOrgExpanded;
    });
  }

  Widget _buildOrgOption(String label, int index) {
    final bool isSelected = index == selectedOrgIndex;
    return Padding(
      padding: const EdgeInsets.only(left: 40, top: 6, bottom: 6),
      child: InkWell(
        onTap: () {
          setState(() {
            selectedOrgIndex = index; // Update selected organization
          });
          // switch org in backend, navigation etc.
        },
        borderRadius: BorderRadius.circular(5),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? Theme.of(context).colorScheme.error
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final currentLocation = GoRouterState.of(context).uri.toString();

    final selectedIndex = items.indexWhere(
          (item) => currentLocation.startsWith(item.route),
    );
    final activeIndex = selectedIndex >= 0 ? selectedIndex : 0;

    return AnimatedBuilder(
      animation: widthAnim,
      builder: (context, child) {
        return Material(
          elevation: 4,
          color: colors.surfaceContainer,
          child: SizedBox(
            width: widthAnim.value,
            child: Column(
              children: [
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          isExpanded ? Icons.arrow_back_ios_new_rounded : Icons.menu,
                          color: colors.onSurface,
                          size: 22,
                        ),
                        onPressed: toggleSidebar,
                        splashRadius: 22,
                      ),
                      if (isExpanded) const SizedBox(width: 10),
                      if (isExpanded)
                        Flexible(
                          child: Text(
                            "NHIT",
                            style: TextStyle(
                              color: colors.onSurface,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                if (isExpanded) ...[
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: colors.surfaceContainerLow,
                    child: Icon(
                      Icons.person,
                      color: colors.onSurface,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                Expanded(
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, idx) {
                      final item = items[idx];
                      final isActive = idx == activeIndex;

                      return _SidebarTile(
                        icon: item.icon,
                        label: item.label,
                        route: item.route,
                        isActive: isActive,
                        collapsed: !isExpanded,
                        onTap: () {
                          context.go(item.route);
                        },
                        backgroundColor: isActive
                            ? colors.onSurface
                            : Colors.transparent,
                        iconColor: isActive ? colors.surface : colors.onSurfaceVariant,
                        textColor: isActive ? colors.surface : colors.onSurface,
                      );
                    },
                  ),
                ),
                Divider(height: 1),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isExpanded ? 18 : 10,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: toggleOrgExpansion,
                        borderRadius: BorderRadius.circular(5),
                        child: Row(
                          children: [
                            Icon(
                              Icons.swap_horiz,
                              color: colors.onSurfaceVariant,
                              size: 22,
                            ),
                            if (isExpanded) ...[
                              const SizedBox(width: 18, height: 36),
                              Expanded(
                                child: Text(
                                  "Switch Organization",
                                  style: TextStyle(
                                    color: colors.onSurface,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Icon(
                                isOrgExpanded ? Icons.expand_less : Icons.expand_more,
                                color: colors.onSurfaceVariant,
                                size: 20,
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (isOrgExpanded && isExpanded) ...[
                        const SizedBox(height: 18),
                        _buildOrgOption("Organization 1", 0),
                        _buildOrgOption("Organization 2", 1),
                        _buildOrgOption("Organization 3", 2),
                        _buildOrgOption("Organization 4", 3),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SidebarItem {
  final IconData icon;
  final String label;
  final String route;

  _SidebarItem(this.icon, this.label, this.route);
}

class _SidebarTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final bool collapsed;
  final VoidCallback onTap;
  final String route;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? iconColor;

  const _SidebarTile({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.collapsed,
    required this.onTap,
    required this.route,
    this.backgroundColor,
    this.textColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(5),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: collapsed ? 10 : 18,
            vertical: 12,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: iconColor,
                size: 22,
              ),
              if (!collapsed) ...[
                const SizedBox(width: 18),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
