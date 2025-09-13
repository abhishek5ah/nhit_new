import 'package:flutter/material.dart';
import 'package:ppv_components/features/crm/companies/companies_page.dart';
import 'package:ppv_components/features/crm/contacts/contacts_page.dart';
import 'package:ppv_components/features/crm/deals/deals_page.dart';
import 'package:ppv_components/features/crm/leads/leads_page.dart';

class CRMPage extends StatefulWidget {
  const CRMPage({super.key});

  @override
  State<CRMPage> createState() => _CRMPageState();
}

class _CRMPageState extends State<CRMPage> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("CRM"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Leads"),
            Tab(text: "Contacts"),
            Tab(text: "Companies"),
            Tab(text: "Deals"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          LeadsPage(),
          ContactsPage(),
          CompaniesPage(),
          DealsPage(),
        ],
      ),
    );
  }
}
