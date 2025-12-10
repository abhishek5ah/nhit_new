class BankLetter {
  final String id;
  final String reference;
  final String type;
  final String subject;
  final String bank;
  final String status;
  final String createdBy;
  final String date;
  final String content;

  BankLetter({
    required this.id,
    required this.reference,
    required this.type,
    required this.subject,
    required this.bank,
    required this.status,
    required this.createdBy,
    required this.date,
    required this.content,
  });

  factory BankLetter.fromMap(Map<String, dynamic> map) {
    return BankLetter(
      id: map['id']?.toString() ?? '',
      reference: map['reference']?.toString() ?? '',
      type: map['type']?.toString() ?? '',
      subject: map['subject']?.toString() ?? '',
      bank: map['bank']?.toString() ?? '',
      status: map['status']?.toString() ?? '',
      createdBy: map['createdBy']?.toString() ?? '',
      date: map['date']?.toString() ?? '',
      content: map['content']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reference': reference,
      'type': type,
      'subject': subject,
      'bank': bank,
      'status': status,
      'createdBy': createdBy,
      'date': date,
      'content': content,
    };
  }

  BankLetter copyWith({
    String? id,
    String? reference,
    String? type,
    String? subject,
    String? bank,
    String? status,
    String? createdBy,
    String? date,
    String? content,
  }) {
    return BankLetter(
      id: id ?? this.id,
      reference: reference ?? this.reference,
      type: type ?? this.type,
      subject: subject ?? this.subject,
      bank: bank ?? this.bank,
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
      date: date ?? this.date,
      content: content ?? this.content,
    );
  }
}
