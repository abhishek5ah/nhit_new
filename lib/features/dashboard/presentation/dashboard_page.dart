import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: colorScheme.surface,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome to ERP Dashboard",
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            // Info Cards Row
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _DashboardCard(
                  title: "Total Projects",
                  value: "18",
                  icon: Icons.assignment,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 24),
                _DashboardCard(
                  title: "Pending Tasks",
                  value: "35",
                  icon: Icons.pending,
                  color: colorScheme.secondary,
                ),
                const SizedBox(width: 24),
                _DashboardCard(
                  title: "Finance Updates",
                  value: "\$25,400",
                  icon: Icons.attach_money,
                  color: colorScheme.tertiary,
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Recent Activities Table Example
            Expanded(
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Recent Activities",
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const Divider(height: 16, thickness: 1),
                      Expanded(
                        child: ListView(
                          children: const [
                            _ActivityTile(
                              title: "Invoice #0021 created",
                              date: "2025-09-01",
                            ),
                            _ActivityTile(
                              title: "Added new vendor: TechSource",
                              date: "2025-09-02",
                            ),
                            _ActivityTile(
                              title: "Finance report exported",
                              date: "2025-09-03",
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _DashboardCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          color: color.withOpacity(0.09),
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: color.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(10),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(value,
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5)),
                const SizedBox(height: 4),
                Text(title,
                    style:
                    TextStyle(fontSize: 15, color: color.withValues(alpha:0.7))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final String title;
  final String date;

  const _ActivityTile({required this.title, required this.date});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(Icons.task, color: colorScheme.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title,
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface)),
          ),
          Text(date,
              style: TextStyle(
                  color: colorScheme.onSurface.withOpacity(0.43),
                  fontSize: 13)),
        ],
      ),
    );
  }
}
