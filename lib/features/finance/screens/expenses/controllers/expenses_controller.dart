import 'package:ppv_components/features/finance/data/mock_expense.dart';
import 'package:ppv_components/features/finance/model/expense.dart';


class ExpensesController {
  List<Expense> getExpenses() => mockExpenses;

  Expense? getExpenseById(String id) {
    try {
      return mockExpenses.firstWhere((e) => e.id == id);
    } catch (e) {
      return null;
    }
  }
}
