import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:ppv_components/core/accessibility/accessibility_constants.dart';
import 'package:ppv_components/core/accessibility/accessibility_utils.dart';
import 'package:ppv_components/features/roles/data/models/role_models.dart';
import 'package:ppv_components/features/roles/services/roles_api_service.dart';
import 'package:ppv_components/features/roles/widgets/roles_header.dart';
import 'package:ppv_components/features/roles/widgets/roles_table.dart';

class RoleMainPage extends StatefulWidget {
  const RoleMainPage({super.key});

  @override
  State<RoleMainPage> createState() => _RoleMainPageState();
}

class _RoleMainPageState extends State<RoleMainPage> {
  String searchQuery = '';
  bool _isInitialized = false;
  final FocusNode _skipToMainFocusNode = FocusNode();
  final FocusNode _searchFocusNode = FocusNode();
  final GlobalKey _mainContentKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _skipToMainFocusNode.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _skipToMainContent() {
    if (_mainContentKey.currentContext != null) {
      Scrollable.ensureVisible(
        _mainContentKey.currentContext!,
        duration: const Duration(milliseconds: 300),
      );
      AccessibilityUtils.announceToScreenReader(
        context,
        'Navigated to roles list',
      );
    }
  }

  Future<void> _loadData() async {
    if (_isInitialized) return;
    
    final rolesService = context.read<RolesApiService>();
    await rolesService.loadRoles();
    await rolesService.loadPermissions();
    
    setState(() {
      _isInitialized = true;
    });
  }

  void updateSearch(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
    });
  }

  Future<void> onDeleteRole(RoleModel role) async {
    if (role.roleId == null) return;
    
    final rolesService = context.read<RolesApiService>();
    final result = await rolesService.deleteRole(role.roleId!);
    
    if (result.success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Role deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message ?? 'Failed to delete role'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> onRefresh() async {
    final rolesService = context.read<RolesApiService>();
    await rolesService.loadRoles();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      label: 'Roles management page',
      container: true,
      explicitChildNodes: true,
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        body: Consumer<RolesApiService>(
        builder: (context, rolesService, child) {
          // Filter roles based on search query
          final filteredRoles = searchQuery.isEmpty
              ? rolesService.roles
              : rolesService.searchRoles(searchQuery);

          if (rolesService.isLoading && !_isInitialized) {
            return Center(child: CircularProgressIndicator());
          }

          if (rolesService.error != null && !_isInitialized) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: colorScheme.error),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load roles',
                    style: TextStyle(color: colorScheme.error, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(rolesService.error ?? ''),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                    child: Offstage(
                      child: ElevatedButton(
                        onPressed: _skipToMainContent,
                        child: Text(AccessibilityConstants.skipToMainContent),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 12, bottom: 12, right: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      RoleHeader(),
                      SizedBox(height: 12),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Spacer(),
                      SizedBox(
                        width: 250,
                        child: Semantics(
                          textField: true,
                          label: 'Search roles by name or permission',
                          hint: 'Type to filter roles list',
                          child: Focus(
                            focusNode: _searchFocusNode,
                            child: TextField(
                              decoration: InputDecoration(
                                contentPadding:
                                const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                                hintText: 'Search roles',
                                labelText: 'Search',
                                prefixIcon: const Icon(Icons.search),
                                border: OutlineInputBorder(
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
                              onChanged: (value) {
                                updateSearch(value);
                                AccessibilityUtils.announceToScreenReader(
                                  context,
                                  filteredRoles.isEmpty
                                      ? 'No roles found matching $value'
                                      : 'Found ${filteredRoles.length} roles matching $value',
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Semantics(
                    label: 'Roles data table',
                    container: true,
                    child: Container(
                      key: _mainContentKey,
                      child: RoleTableView(
                        roleData: filteredRoles,
                        onDelete: onDeleteRole,
                        onRefresh: onRefresh,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      ),
    );
  }
}
