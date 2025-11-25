import 'package:flutter/material.dart';
import 'package:ppv_components/features/payment_notes/data/payment_notes_mockdb.dart';
import 'package:ppv_components/features/payment_notes/model/payment_notes_model.dart';
import 'package:ppv_components/features/payment_notes/widget/payment_header.dart';
import 'package:ppv_components/features/payment_notes/widget/payment_table.dart';

class PaymentMainPage extends StatefulWidget {
  const PaymentMainPage({super.key});

  @override
  State<PaymentMainPage> createState() => _PaymentMainPageState();
}

class _PaymentMainPageState extends State<PaymentMainPage> {
  String searchQuery = '';
  late List<PaymentNote> filteredPayments;
  List<PaymentNote> allPayments = List<PaymentNote>.from(paymentNoteData);

  @override
  void initState() {
    super.initState();
    filteredPayments = List<PaymentNote>.from(allPayments);
  }

  void updateSearch(String query) {
    searchQuery = query.toLowerCase();
    _filterPayments();
  }

  void _filterPayments() {
    List<PaymentNote> filtered = allPayments.where((payment) {
      bool searchMatches =
          payment.projectName.toLowerCase().contains(searchQuery) ||
          payment.vendorName.toLowerCase().contains(searchQuery) ||
          payment.status.toLowerCase().contains(searchQuery);

      return searchMatches;
    }).toList();

    setState(() {
      filteredPayments = filtered;
    });
  }

  void onDeletePayment(PaymentNote payment) {
    setState(() {
      allPayments.removeWhere((p) => p.sno == payment.sno);
      _filterPayments();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 12, right: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  PaymentHeader(),
                  SizedBox(height: 12),
                ],
              ),
            ),

            // Search bar only (no tabs)
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
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 12,
                        ),
                        hintText: 'Search payments',
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

            // Only All Payments table
            Expanded(
              child: PaymentTableView(
                paymentData: filteredPayments,
                onDelete: onDeletePayment,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
