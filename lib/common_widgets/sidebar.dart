import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Sidebar extends StatefulWidget {
  const Sidebar({super.key, required Null Function(dynamic route) onItemSelected});

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> with SingleTickerProviderStateMixin {
  bool isExpanded = true;
  bool isOrgExpanded = false;
  int selectedOrgIndex = -1;
  Set<int> expandedMenuIndices = {};
  String? selectedSubRoute;

  static const double expandedWidth = 280;
  static const double collapsedWidth = 64;
  late AnimationController _controller;
  late Animation<double> widthAnim;

  final List<_SidebarCategory> categories = [
    _SidebarCategory(
      heading: "EXPENSE MANAGEMENT",
      items: [
        _SidebarItem(Icons.receipt_long, "Expense Approval Notes", "", subItems: [
          _SubItem("All Notes", "/expense-notes/note"),
          _SubItem("Create Note", "/expense-note/create"),
        ]),
        _SidebarItem(Icons.money, "Payment Notes", "", subItems: [
          _SubItem("Create Payment Note", "/payment-notes/create"),
          _SubItem("All Payment Notes", "/payment-notes"),
          _SubItem("Draft Notes", "/drafts"),
        ]),
      ],
    ),
    _SidebarCategory(
      heading: "APPROVAL RULES",
      items: [
        _SidebarItem(Icons.rule, "Approval Rules Management", "", subItems: [
          _SubItem("Rules Dashboard", "/approval-rules"),
          _SubItem("Expense Note Rules", "/approval-rules/green_note"),
          _SubItem("Create Expense Rules", "/approval-rules/green_note/create"),
          _SubItem("Payment Note Rules", "/approval-rules/payment_note"),
          _SubItem("Create Payment Rules", "/approval-rules/payment_note/create"),
          _SubItem("Reimbursement Rules", "/approval-rules/reimbursement_note"),
          _SubItem("Create Reimbursement Rules", "/approval-rules/reimbursement_note/create"),
          _SubItem("Bank Letter", "/approval-rules/bank_letter"),
          _SubItem("Create Bank Letter Rule", "/approval-rules/bank_letter/create"),
        ]),
        _SidebarItem(Icons.account_balance, "Escrow Banking System", "", subItems: [
          _SubItem("Escrow Accounts", "/escrow-accounts"),
          _SubItem("Create Account", "/escrow-accounts/create"),
          _SubItem("Fund Transfers", "/escrow/account-transfers"),
          _SubItem("New Transfer", "/escrow/create"),
          _SubItem("Bank Letter", "/escrow/bank-letter"),
          _SubItem("Create Letter", "/escrow/bank-letter/create"),
        ]),
        _SidebarItem(Icons.receipt, "Travel & Reimbursement", "", subItems: [
          _SubItem("Create Request", "/reimbursement-note/create"),
          _SubItem("All Reimbursements", "/reimbursement-note"),
        ]),
      ],
    ),
    _SidebarCategory(
      heading: "MANAGEMENT",
      items: [
        _SidebarItem(Icons.people, "User Management", "", subItems: [
          _SubItem("All Users", "/users"),
          _SubItem("Add New User", "/users/create"),

        ]),
        _SidebarItem(Icons.shield, "Role Management", "", subItems: [
          _SubItem("All Roles", "/roles"),
          _SubItem("Create Role", "/roles/create"),
        ]),
        _SidebarItem(Icons.account_tree, "Departments", "", subItems: [
          _SubItem("All Department", "/department"),
          _SubItem("Create Department", "/department/create"),

        ]),
        _SidebarItem(Icons.badge, "Designations", "", subItems: [
          _SubItem("All Designation", "/designations"),
          _SubItem("Create Designation", "/designations/create"),
        ]),
        _SidebarItem(Icons.store, "Vendor Management", "", subItems: [
          _SubItem("All Vendors", "/vendors"),
          _SubItem("Add Vendors", "/vendors/create"),
        ]),
        _SidebarItem(Icons.store, "Organization Management", "", subItems: [
          _SubItem("All Organizations", "/organizations"),
          _SubItem("Create Organization", "/organization/create"),
        ]),
      ],
    ),
    _SidebarCategory(
      heading: "ACTIVITY & REPORTS",
      items: [
        _SidebarItem(Icons.people, "Activity", "", subItems: [
          _SubItem("Activity Logs", "/activity"),
          _SubItem("Login History", "/login-history"),
        ]),
      ]
    ),
  ];



  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    widthAnim = Tween<double>(begin: expandedWidth, end: collapsedWidth).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  void toggleSidebar() {
    setState(() {
      isExpanded = !isExpanded;
      if (isExpanded) {
        _controller.reverse();
      } else {
        _controller.forward();
        isOrgExpanded = false;
        expandedMenuIndices.clear();
      }
    });
  }

  void toggleOrgExpansion() {
    setState(() {
      isOrgExpanded = !isOrgExpanded;
    });
  }

  void toggleMenuExpansion(int index) {
    if (!isExpanded) return;
    setState(() {
      if (expandedMenuIndices.contains(index)) {
        expandedMenuIndices.remove(index);
      } else {
        expandedMenuIndices.add(index);
      }
    });
  }

  void _navigate(String route) {
    setState(() {
      selectedSubRoute = route;
    });
    GoRouter.of(context).go(route);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildOrgOption(String label, int index) {
    final bool isSelected = index == selectedOrgIndex;
    if (!isExpanded) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.only(left: 40, top: 6, bottom: 6),
      child: InkWell(
        onTap: () {
          setState(() {
            selectedOrgIndex = index;
          });
          // Add org switch navigation here if needed
        },
        borderRadius: BorderRadius.circular(5),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: widthAnim,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            border: Border(right: BorderSide(width: 0.5, color: colors.outline)),
          ),
          child: Material(
            elevation: 4,
            color: colors.surface,
            child: SizedBox(
              width: widthAnim.value,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      children: [
                        for (int i = 0; i < categories.length; i++) ...[
                          if (isExpanded)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(18, 18, 18, 6),
                              child: Text(
                                categories[i].heading,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ),
                          for (int j = 0; j < categories[i].items.length; j++)
                            _buildSidebarItem(
                              categories[i].items[j],
                              i * 100 + j,
                              colors,
                            ),
                        ],
                      ],
                    ),
                  ),
                  Divider(height: 1),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: isExpanded ? 18 : 10, vertical: 8),
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
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSidebarItem(_SidebarItem item, int index, ColorScheme colors) {
    final bool isExpandedItem = expandedMenuIndices.contains(index);
    final bool isActive = selectedSubRoute == item.route || item.subItems.any((si) => si.route == selectedSubRoute);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? colors.surfaceContainerHighest.withAlpha(80) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ExpansionTile(
        onExpansionChanged: (expanded) => toggleMenuExpansion(index),
        trailing: isExpanded && item.subItems.isNotEmpty
            ? Icon(
          isExpandedItem ? Icons.expand_less : Icons.expand_more,
          color: colors.onSurfaceVariant,
          size: 20,
        )
            : null,
        initiallyExpanded: isExpandedItem,
        leading: Icon(item.icon, color: colors.onSurfaceVariant),
        textColor: isExpanded ? colors.onSurface : Colors.transparent,
        iconColor: isExpanded ? colors.onSurfaceVariant : Colors.transparent,
        title: isExpanded
            ? Text(
          item.label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isActive ? colors.primary : colors.onSurface,
            fontSize: 16,
          ),
        )
            : const SizedBox.shrink(),
        childrenPadding: const EdgeInsets.only(left: 56, bottom: 8),
        children: isExpanded && item.subItems.isNotEmpty
            ? item.subItems
            .map((_SubItem subItem) => ListTile(
          contentPadding: EdgeInsets.zero,
          horizontalTitleGap: 0,
          minLeadingWidth: 20,
          leading: Icon(Icons.circle, size: 8, color: subItem.route == selectedSubRoute ? colors.primary : colors.onSurfaceVariant),
          title: InkWell(
            onTap: () {
              _navigate(subItem.route);
            },
            child: Text(
              subItem.label,
              style: TextStyle(
                color: subItem.route == selectedSubRoute ? colors.primary : colors.onSurface,
                fontSize: 14,
                fontWeight: subItem.route == selectedSubRoute ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ))
            .toList()
            : [],
      ),
    );
  }
}

class _SidebarCategory {
  final String heading;
  final List<_SidebarItem> items;
  _SidebarCategory({required this.heading, required this.items});
}

class _SidebarItem {
  final IconData icon;
  final String label;
  final String route;
  final List<_SubItem> subItems;
  _SidebarItem(this.icon, this.label, this.route, {this.subItems = const []});
}

class _SubItem {
  final String label;
  final String route;
  _SubItem(this.label, this.route);
}
