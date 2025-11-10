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

  // Updated categories list with icons for each sub-item
  final List<_SidebarCategory> categories = [
    _SidebarCategory(
      heading: "EXPENSE MANAGEMENT",
      items: [
        _SidebarItem(Icons.receipt_long, "Expense Approval Notes", "", subItems: [
          _SubItem("All Notes", "/expense-notes/note", Icons.list_alt),
          _SubItem("Create Note", "/expense-note/create", Icons.add_box_outlined),
        ]),
        _SidebarItem(Icons.money, "Payment Notes", "", subItems: [
          _SubItem("Create Payment Note", "/payment-notes/create", Icons.post_add),
          _SubItem("All Payment Notes", "/payment-notes", Icons.credit_card),
          _SubItem("Draft Notes", "/drafts", Icons.drafts_outlined),
        ]),
      ],
    ),
    _SidebarCategory(
      heading: "APPROVAL RULES",
      items: [
        _SidebarItem(Icons.rule, "Approval Rules Management", "", subItems: [
          _SubItem("Rules Dashboard", "/approval-rules", Icons.dashboard_outlined),
          _SubItem("Expense Note Rules", "/approval-rules/green_note", Icons.receipt_outlined),
          _SubItem("Create Expense Rules", "/approval-rules/green_note/create", Icons.add_task),
          _SubItem("Payment Note Rules", "/approval-rules/payment_note", Icons.payment_outlined),
          _SubItem("Create Payment Rules", "/approval-rules/payment_note/create", Icons.playlist_add_check),
          _SubItem("Reimbursement Rules", "/approval-rules/reimbursement_note", Icons.card_travel),
          _SubItem("Create Reimbursement Rules", "/approval-rules/reimbursement_note/create", Icons.luggage),
          _SubItem("Bank Letter", "/approval-rules/bank_letter", Icons.mark_as_unread),
          _SubItem("Create Bank Letter Rule", "/approval-rules/bank_letter/create", Icons.note_add),
        ]),
        _SidebarItem(Icons.account_balance, "Escrow Banking System", "", subItems: [
          _SubItem("Escrow Accounts", "/escrow-accounts", Icons.account_balance_wallet_outlined),
          _SubItem("Create Account", "/escrow-accounts/create", Icons.add_card),
          _SubItem("Fund Transfers", "/escrow/account-transfers", Icons.swap_horiz),
          _SubItem("New Transfer", "/escrow/create", Icons.add_road),
          _SubItem("Bank Letter", "/escrow/bank-letter", Icons.mail_outline),
          _SubItem("Create Letter", "/escrow/bank-letter/create", Icons.create_outlined),
        ]),
        _SidebarItem(Icons.receipt, "Travel & Reimbursement", "", subItems: [
          _SubItem("Create Request", "/reimbursement-note/create", Icons.add_location_alt_outlined),
          _SubItem("All Reimbursements", "/reimbursement-note", Icons.flight_takeoff),
        ]),
      ],
    ),
    _SidebarCategory(
      heading: "MANAGEMENT",
      items: [
        _SidebarItem(Icons.people, "User Management", "", subItems: [
          _SubItem("All Users", "/users", Icons.people_outline),
          _SubItem("Add New User", "/users/create", Icons.person_add_alt),
        ]),
        _SidebarItem(Icons.shield, "Role Management", "", subItems: [
          _SubItem("All Roles", "/roles", Icons.security),
          _SubItem("Create Role", "/roles/create", Icons.add_moderator),
        ]),
        _SidebarItem(Icons.account_tree, "Departments", "", subItems: [
          _SubItem("All Departments", "/department", Icons.corporate_fare),
          _SubItem("Create Department", "/department/create", Icons.add_business_outlined),
        ]),
        _SidebarItem(Icons.badge, "Designations", "", subItems: [
          _SubItem("All Designations", "/designations", Icons.badge_outlined),
          _SubItem("Create Designation", "/designations/create", Icons.library_add),
        ]),
        _SidebarItem(Icons.store, "Vendor Management", "", subItems: [
          _SubItem("All Vendors", "/vendors", Icons.store_mall_directory_outlined),
          _SubItem("Add Vendors", "/vendors/create", Icons.add_shopping_cart),
        ]),
        _SidebarItem(Icons.store, "Organization Management", "", subItems: [
          _SubItem("All Organizations", "/organizations", Icons.domain),
          _SubItem("Create Organization", "/organizations/create", Icons.location_city),
        ]),
      ],
    ),
    _SidebarCategory(
      heading: "ACTIVITY & REPORTS",
      items: [
        _SidebarItem(Icons.history, "Activity", "", subItems: [
          _SubItem("Activity Logs", "/activity", Icons.plagiarism_outlined),
          _SubItem("Login History", "/login-history", Icons.login),
        ]),
      ],
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
        color: isActive ? colors.surfaceContainerHighest.withValues(alpha: 0.5) : Colors.transparent,
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
            : const SizedBox.shrink(),
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
        childrenPadding: const EdgeInsets.only(left: 30, bottom: 8, right: 16),
        children: isExpanded && item.subItems.isNotEmpty
            ? item.subItems
            .map((_SubItem subItem) => ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          horizontalTitleGap: 8,
          dense: true,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          tileColor: subItem.route == selectedSubRoute ? colors.primary.withValues(alpha: 0.1) : Colors.transparent,
          leading: Icon(subItem.icon, // Use the icon from the subItem
              size: 18,
              color: subItem.route == selectedSubRoute ? colors.primary : colors.onSurfaceVariant),
          title: Text(
            subItem.label,
            style: TextStyle(
              color: subItem.route == selectedSubRoute ? colors.primary : colors.onSurface,
              fontSize: 14,
              fontWeight: subItem.route == selectedSubRoute ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          onTap: () {
            _navigate(subItem.route);
          },
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

// Updated _SubItem class to include an icon
class _SubItem {
  final String label;
  final String route;
  final IconData icon;
  _SubItem(this.label, this.route, this.icon);
}
