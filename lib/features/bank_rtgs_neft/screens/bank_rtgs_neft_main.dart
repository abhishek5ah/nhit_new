import 'package:flutter/material.dart';
import 'package:ppv_components/features/bank_rtgs_neft/models/escrow_account_response.dart' show EscrowAccount;
import 'package:ppv_components/features/bank_rtgs_neft/widget/escrow_accounts_page.dart';

class BankMainPage extends StatefulWidget {
  const BankMainPage({super.key});

  @override
  State<BankMainPage> createState() => _BankMainPageState();
}

class _BankMainPageState extends State<BankMainPage> {
  // Escrow accounts list - now loaded from API via router
  List<EscrowAccount> escrowAccounts = [];

  @override
  Widget build(BuildContext context) {
    return const EscrowAccountsPage();
  }
}
