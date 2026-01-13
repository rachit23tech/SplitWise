class Payment {
  final String from;
  final String to;
  final double amount;
  final DateTime date;

  Payment({
    required this.from,
    required this.to,
    required this.amount,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {'from': from, 'to': to, 'amount': amount, 'date': date};
  }
}
