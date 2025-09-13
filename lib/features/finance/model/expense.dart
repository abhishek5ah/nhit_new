import 'package:ppv_components/features/finance/model/history_model.dart';

class Expense {
  final String id;
  final String vendor;
  final String category;
  final double amount;
  final String paymentMethod;
  final String status;
  final String description;
  final DateTime date;
  final List<Attachment> attachments;
  final dynamic accountingDetail;
  final List<ExpenseHistory> history; 

  Expense({
    required this.id,
    required this.vendor,
    required this.category,
    required this.amount,
    required this.paymentMethod,
    required this.status,
    required this.description,
    required this.date,
    required this.attachments,
    required this.accountingDetail,
    required this.history, // Add this line for history
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      vendor: json['vendor'],
      category: json['category'],
      amount: json['amount'],
      paymentMethod: json['paymentMethod'],
      status: json['status'],
      description: json['description'],
      date: DateTime.parse(json['date']),
      attachments: (json['attachments'] as List<dynamic>)
          .map((a) => Attachment.fromJson(a))
          .toList(),
      accountingDetail: json['accountingDetail'],
      history: (json['history'] as List<dynamic>?)
          ?.map((h) => ExpenseHistory.fromJson(h))
          .toList() ?? [],
    );
  }
}

class Attachment {
  final String filename;
  final DateTime addedOn;

  Attachment({required this.filename, required this.addedOn});

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      filename: json['filename'],
      addedOn: DateTime.parse(json['addedOn']),
    );
  }
}
