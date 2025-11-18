import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ppv_components/core/services/auth_service.dart';
import 'package:provider/provider.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        final user = authService.currentUser;
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        final screenWidth = MediaQuery.of(context).size.width;
        final isDesktop = screenWidth > 900;

        return Scaffold(
          backgroundColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isDesktop ? 24.0 : 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Section with Border - updated to match reference style
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      border: Border.all(
                        color: colorScheme.outline.withValues(alpha: 0.2),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        // Icon Container - matching reference style
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.account_balance_wallet_outlined,
                            color: colorScheme.onPrimary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome back, ${user?.name ?? 'User'}!',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Here's what's happening with your expense management today",
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Export Report Button
                        ElevatedButton.icon(
                          onPressed: () => _showComingSoon(context),
                          icon: const Icon(Icons.download, size: 18),
                          label: const Text('Export Report'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Stats Cards Row
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (isDesktop) {
                        return Row(
                          children: [
                            Expanded(
                              child: _buildStatCardWithBadge(
                                context,
                                'Total Notes',
                                '0',
                                Icons.description,
                                Colors.blue,
                                '+0%',
                                '+0% from last month',
                                true,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildStatCardWithBadge(
                                context,
                                'Pending Approvals',
                                '0',
                                Icons.schedule,
                                Colors.amber,
                                '0',
                                'Require your attention',
                                false,
                                isAlert: true,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildStatCardWithBadge(
                                context,
                                'Completed This Month',
                                '0',
                                Icons.check_circle,
                                Colors.green,
                                '+0%',
                                '+0% vs last month',
                                true,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildStatCardWithBadge(
                                context,
                                'Active Users',
                                '0',
                                Icons.people,
                                Colors.teal,
                                '+3',
                                '+3 new this week',
                                true,
                              ),
                            ),
                          ],
                        );
                      } else {
                        return Column(
                          children: [
                            _buildStatCardWithBadge(
                              context,
                              'Total Notes',
                              '0',
                              Icons.description,
                              Colors.blue,
                              '+0%',
                              '+0% from last month',
                              true,
                            ),
                            const SizedBox(height: 12),
                            _buildStatCardWithBadge(
                              context,
                              'Pending Approvals',
                              '0',
                              Icons.schedule,
                              Colors.amber,
                              '0',
                              'Require your attention',
                              false,
                              isAlert: true,
                            ),
                            const SizedBox(height: 12),
                            _buildStatCardWithBadge(
                              context,
                              'Completed This Month',
                              '0',
                              Icons.check_circle,
                              Colors.green,
                              '+0%',
                              '+0% vs last month',
                              true,
                            ),
                            const SizedBox(height: 12),
                            _buildStatCardWithBadge(
                              context,
                              'Active Users',
                              '0',
                              Icons.people,
                              Colors.teal,
                              '+3',
                              '+3 new this week',
                              true,
                            ),
                          ],
                        );
                      }
                    },
                  ),

                  const SizedBox(height: 32),

                  // Quick Actions and Recent Activity Row
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (isDesktop) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: _buildQuickActionsSection(context),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              flex: 3,
                              child: _buildRecentActivitySection(context, user),
                            ),
                          ],
                        );
                      } else {
                        return Column(
                          children: [
                            _buildQuickActionsSection(context),
                            const SizedBox(height: 24),
                            _buildRecentActivitySection(context, user),
                          ],
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCardWithBadge(
      BuildContext context,
      String title,
      String value,
      IconData icon,
      Color color,
      String badgeText,
      String subtitle,
      bool isPositive, {
        bool isAlert = false,
      }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isAlert
                        ? Colors.red.withValues(alpha: 0.1)
                        : Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    badgeText,
                    style: TextStyle(
                      color: isAlert ? Colors.red : Colors.green,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  isPositive ? Icons.arrow_upward : Icons.info_outline,
                  size: 14,
                  color: isAlert
                      ? Colors.red
                      : (isPositive ? Colors.green : Colors.grey),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.bolt,
                  color: Colors.amber,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Quick Actions',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildActionButton(
              context,
              'New Note',
              Icons.add_circle_outline,
              Colors.green,
                  () => _showComingSoon(context),
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              context,
              'Reimbursement',
              Icons.receipt_long,
              Colors.blue,
                  () => _showComingSoon(context),
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              context,
              'Payment',
              Icons.payment,
              Colors.purple,
                  () => _showComingSoon(context),
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              context,
              'View Activity',
              Icons.trending_up,
              Colors.grey,
                  () => context.go('/activity'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivitySection(BuildContext context, user) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.history,
                  color: Colors.grey[600],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Recent Activity',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildActivityItem(
              context,
              '${user?.name ?? 'Super Admin'} logged in',
              '${user?.name ?? 'Super Admin'} • 0 seconds ago',
            ),
            const Divider(height: 24),
            _buildActivityItem(
              context,
              '${user?.name ?? 'Super Admin'} logged in',
              '${user?.name ?? 'Super Admin'} • 10 minutes ago',
            ),
            const Divider(height: 24),
            _buildActivityItem(
              context,
              '${user?.name ?? 'Super Admin'} logged in',
              '${user?.name ?? 'Super Admin'} • 9 hours ago',
            ),
            const Divider(height: 24),
            _buildActivityItem(
              context,
              '${user?.name ?? 'Super Admin'} logged in',
              '${user?.name ?? 'Super Admin'} • 9 hours ago',
            ),
            const Divider(height: 24),
            _buildActivityItem(
              context,
              '${user?.name ?? 'Super Admin'} logged in',
              '${user?.name ?? 'Super Admin'} • 15 hours ago',
            ),
            const Divider(height: 24),
            _buildActivityItem(
              context,
              '${user?.name ?? 'Super Admin'} logged in',
              '${user?.name ?? 'Super Admin'} • 16 hours ago',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
      BuildContext context,
      String label,
      IconData icon,
      Color color,
      VoidCallback onPressed,
      ) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(
      BuildContext context,
      String title,
      String subtitle,
      ) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Feature coming soon!'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
