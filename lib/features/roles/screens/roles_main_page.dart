import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  @override
  void initState() {
    super.initState();
    _loadData();
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

    return Scaffold(
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
                Padding(
                  padding: const EdgeInsets.only(left: 12, bottom: 12, right: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RoleHeader(),
                      const SizedBox(height: 12),
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
                        child: TextField(
                          decoration: InputDecoration(
                            contentPadding:
                            const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                            hintText: 'Search roles',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(
                                color: colorScheme.outline,
                                width: 0.25,
                              ),
                            ),
                            isDense: true,
                          ),
                          onChanged: updateSearch,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: RoleTableView(
                    roleData: filteredRoles,
                    onDelete: onDeleteRole,
                    onRefresh: onRefresh,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
