class AccountTransfer {
  final String id;
  final String reference;
  final String fromAccount;
  final String toAccount;
  final String amount;
  final String status;
  final String requestedBy;
  final String date;
  final String type;

  AccountTransfer({
    required this.id,
    required this.reference,
    required this.fromAccount,
    required this.toAccount,
    required this.amount,
    required this.status,
    required this.requestedBy,
    required this.date,
    required this.type,
  });

  factory AccountTransfer.fromMap(Map<String, dynamic> map) {
    return AccountTransfer(
      id: map['id']?.toString() ?? '',
      reference: map['reference']?.toString() ?? '',
      fromAccount: map['fromAccount']?.toString() ?? '',
      toAccount: map['toAccount']?.toString() ?? '',
      amount: map['amount']?.toString() ?? '',
      status: map['status']?.toString() ?? '',
      requestedBy: map['requestedBy']?.toString() ?? '',
      date: map['date']?.toString() ?? '',
      type: map['type']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reference': reference,
      'fromAccount': fromAccount,
      'toAccount': toAccount,
      'amount': amount,
      'status': status,
      'requestedBy': requestedBy,
      'date': date,
      'type': type,
    };
  }

  AccountTransfer copyWith({
    String? id,
    String? reference,
    String? fromAccount,
    String? toAccount,
    String? amount,
    String? status,
    String? requestedBy,
    String? date,
    String? type,
  }) {
    return AccountTransfer(
      id: id ?? this.id,
      reference: reference ?? this.reference,
      fromAccount: fromAccount ?? this.fromAccount,
      toAccount: toAccount ?? this.toAccount,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      requestedBy: requestedBy ?? this.requestedBy,
      date: date ?? this.date,
      type: type ?? this.type,
    );
  }
}
