class ExpenseHistory {
  final String title;
  final DateTime dateTime;
  final String details;
  final String actor;

  ExpenseHistory({
    required this.title,
    required this.dateTime,
    required this.details,
    required this.actor,
  });

  factory ExpenseHistory.fromJson(Map<String, dynamic> json) {
    return ExpenseHistory(
      title: json['title'],
      dateTime: DateTime.parse(json['dateTime']),
      details: json['details'],
      actor: json['actor'],
    );
  }
}