class TransactionRecord {
  final int? id;
  final double amount;
  final DateTime date;
  final int subCategoryId;
  final String? note;

  TransactionRecord({
    this.id,
    required this.amount,
    required this.date,
    required this.subCategoryId,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'amount': amount,
      'date': date.millisecondsSinceEpoch,
      'subcategory_id': subCategoryId,
      if (note != null) 'note': note,
    };
  }

  factory TransactionRecord.fromMap(Map<String, dynamic> map) {
    return TransactionRecord(
      id: map['id'],
      amount: map['amount'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      subCategoryId: map['subcategory_id'],
      note: map['note'],
    );
  }
}
