import 'package:ppv_components/features/finance/model/history_model.dart';


List<ExpenseHistory> mockExpenseHistory = [
  ExpenseHistory(
    title: 'Payment Processed',
    dateTime: DateTime.parse('2023-04-15 10:30:00'),
    details: 'Payment of \$350.00 processed via Credit Card',
    actor: '',
  ),
  ExpenseHistory(
    title: 'Expense Approved',
    dateTime: DateTime.parse('2023-04-10 09:15:00'),
    details: 'Approved by John Smith',
    actor: '',
  ),
  ExpenseHistory(
    title: 'Expense Created',
    dateTime: DateTime.parse('2023-04-02 15:45:00'),
    details: 'Created by Sarah Johnson',
    actor: '',
  ),
];
