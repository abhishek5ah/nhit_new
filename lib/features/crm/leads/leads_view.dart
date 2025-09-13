import 'package:flutter/material.dart';
import 'lead_name.dart';
import 'lead_name_tasks.dart';
import 'lead_name_emails.dart';

class LeadsView extends StatefulWidget {
  final Map<String, dynamic> lead;
  const LeadsView({super.key, required this.lead});

  @override
  State<LeadsView> createState() => _LeadsViewState();
}

class _LeadsViewState extends State<LeadsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lead["name"]),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white, // ✅ active tab indicator
          labelColor: Colors.white, // ✅ active text color
          unselectedLabelColor: Colors.grey[300], // ✅ inactive tab text
          overlayColor: WidgetStateProperty.resolveWith<Color?>(
                (Set<WidgetState> states) {
              if (states.contains(WidgetState.hovered)) {
                return Colors.white.withValues(alpha: 0.2); // ✅ hover effect
              }
              if (states.contains(WidgetState.pressed)) {
                return Colors.white.withValues(alpha: 0.3); // ✅ pressed effect
              }
              return null;
            },
          ),
          tabs: const [
            Tab(text: "Summary"),
            Tab(text: "Tasks"),
            Tab(text: "Emails"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          LeadName(lead: widget.lead),
          LeadNameTasks(lead: widget.lead),
          LeadNameEmails(lead: widget.lead),
        ],
      ),
    );
  }
}
