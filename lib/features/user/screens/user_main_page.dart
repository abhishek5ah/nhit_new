import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:ppv_components/features/user/model/user_model.dart';
import 'package:ppv_components/features/user/widgets/user_header.dart';
import 'package:ppv_components/features/user/widgets/user_table.dart';
import 'package:ppv_components/features/user/services/user_api_service.dart';
import 'package:ppv_components/features/user/utils/user_mapper.dart';
import 'package:ppv_components/core/accessibility/accessibility_constants.dart';
import 'package:ppv_components/core/accessibility/accessibility_utils.dart';

class UserMainPage extends StatefulWidget {
  const UserMainPage({super.key});

  @override
  State<UserMainPage> createState() => _UserMainPageState();
}

class _UserMainPageState extends State<UserMainPage> {
  String searchQuery = '';
  int _currentPage = 1;
  int _rowsPerPage = 10;
  final FocusNode _skipToMainFocusNode = FocusNode();
  final FocusNode _searchFocusNode = FocusNode();
  final GlobalKey _mainContentKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUsers();
    });
  }

  Future<void> _loadUsers() async {
    final service = context.read<UserApiService>();
    await service.loadUsers(
      page: _currentPage,
      pageSize: _rowsPerPage,
    );
  }

  @override
  void dispose() {
    _skipToMainFocusNode.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _skipToMainContent() {
    // Scroll to main content and announce to screen reader
    Scrollable.ensureVisible(
      _mainContentKey.currentContext!,
      duration: const Duration(milliseconds: 300),
    );
    AccessibilityUtils.announceToScreenReader(
      context,
      'Navigated to main content',
    );
  }

  void updateSearch(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
    });
    
    // Announce search to screen reader
    if (query.isNotEmpty) {
      AccessibilityUtils.announceToScreenReader(
        context,
        'Searching for users matching "$query"',
      );
    }
  }

  Future<void> onDeleteUser(User user) async {
    // TODO: Implement delete user API call
    // For now, just refresh the list
    await _loadUsers();
    if (mounted) {
      AccessibilityUtils.announceToScreenReader(
        context,
        'User ${user.name} deleted',
      );
    }
  }

  void onEditUser(User user) {
    // Navigation to edit screen is handled by UserTableView
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    _loadUsers();
  }

  void _onRowsPerPageChanged(int rowsPerPage) {
    setState(() {
      _rowsPerPage = rowsPerPage;
      _currentPage = 1; // Reset to first page
    });
    _loadUsers();
  }

  Future<void> _onRefresh() async {
    await _loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;

    return Consumer<UserApiService>(
      builder: (context, userService, _) {
        // Map API models to UI models
        final allUsers = userService.users.map(mapUserApiToUi).toList();
        
        // Apply search filter
        final filteredUsers = searchQuery.isEmpty
            ? allUsers
            : userService.searchUsers(searchQuery).map(mapUserApiToUi).toList();
        
        final totalItems = userService.pagination?.totalItems ?? filteredUsers.length;

        return Semantics(
      label: 'User Management Page',
      container: true,
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        body: Column(
          children: [
            // Skip Navigation Link (WCAG 2.4.1)
            Focus(
              focusNode: _skipToMainFocusNode,
              onKeyEvent: (node, event) {
                if (event is KeyDownEvent &&
                    event.logicalKey == LogicalKeyboardKey.enter) {
                  _skipToMainContent();
                  return KeyEventResult.handled;
                }
                return KeyEventResult.ignored;
              },
              child: Semantics(
                button: true,
                label: AccessibilityConstants.skipToMainContent,
                child: Container(
                  height: 0,
                  width: 0,
                  child: ElevatedButton(
                    onPressed: _skipToMainContent,
                    child: Text(AccessibilityConstants.skipToMainContent),
                  ),
                ),
              ),
            ),
            // Main Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with Semantic Region
                    Semantics(
                      header: true,
                      label: 'User Management Header',
                      child: Padding(
                        padding: const EdgeInsets.only(left: 12, bottom: 12, right: 12),
                        child: const UserHeader(),
                      ),
                    ),
                    // Search Bar with Accessibility Features
                    Semantics(
                      container: true,
                      label: 'Search Section',
                      child: Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: SizedBox(
                            width: 250,
                            child: Semantics(
                              textField: true,
                              label: 'Search users by name, username, or email',
                              hint: 'Type to filter user list',
                              child: Focus(
                                focusNode: _searchFocusNode,
                                child: TextField(
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                      horizontal: 12,
                                    ),
                                    hintText: 'Search users',
                                    labelText: 'Search',
                                    prefixIcon: Semantics(
                                      label: 'Search icon',
                                      excludeSemantics: true,
                                      child: const Icon(Icons.search),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      borderSide: BorderSide(
                                        color: colorScheme.outline,
                                        width: 0.25,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      borderSide: BorderSide(
                                        color: colorScheme.outline,
                                        width: 0.25,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      borderSide: BorderSide(
                                        color: colorScheme.primary,
                                        width: AccessibilityConstants.focusIndicatorWidth,
                                      ),
                                    ),
                                    isDense: true,
                                  ),
                                  style: TextStyle(
                                    fontSize: AccessibilityUtils.getScaledFontSize(
                                      context,
                                      AccessibilityConstants.baseFontSize,
                                    ),
                                  ),
                                  onChanged: updateSearch,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // User Table - Main Content Region
                    Expanded(
                      child: Semantics(
                        label: 'Main content: User list table with ${filteredUsers.length} users',
                        container: true,
                        child: Container(
                          key: _mainContentKey,
                          child: UserTableView(
                            userData: filteredUsers,
                            onDelete: onDeleteUser,
                            onEdit: onEditUser,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
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
