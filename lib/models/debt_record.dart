class DebtRecord {
  final int? id;
  final String type; // 'Lent' or 'Borrowed'
  final double amount;
  final String personName;
  final DateTime date;
  final String status; // 'Pending' or 'Settled'
  final String? note;

  DebtRecord({
    this.id,
    required this.type,
    required this.amount,
    required this.personName,
    required this.date,
    required this.status,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'type': type,
      'amount': amount,
      'person_name': personName,
      'date': date.millisecondsSinceEpoch,
      'status': status,
      if (note != null) 'note': note,
    };
  }

  factory DebtRecord.fromMap(Map<String, dynamic> map) {
    return DebtRecord(
      id: map['id'],
      type: map['type'],
      amount: map['amount'],
      personName: map['person_name'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      status: map['status'],
      note: map['note'],
    );
  }
}
