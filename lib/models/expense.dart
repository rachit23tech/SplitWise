import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  final String id;
  final String description;
  final double amount;
  final String paidBy;
  final List<String> participants;
  final String splitType; // "equal" or "custom"
  final Map<String, double>? customSplits;
  final String groupId;
  final DateTime createdAt;

  Expense({
    required this.id,
    required this.description,
    required this.amount,
    required this.paidBy,
    required this.participants,
    required this.splitType,
    this.customSplits,
    required this.groupId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'description': description,
      'amount': amount,
      'paidBy': paidBy,
      'participants': participants,
      'splitType': splitType,
      'customSplits': customSplits,
      'groupId': groupId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory Expense.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Expense(
      id: doc.id,
      description: data['description'],
      amount: (data['amount'] as num).toDouble(),
      paidBy: data['paidBy'],
      participants: List<String>.from(data['participants']),
      splitType: data['splitType'],
      customSplits: data['customSplits'] != null
          ? Map<String, double>.from(
              data['customSplits'].map(
                (k, v) => MapEntry(k, (v as num).toDouble()),
              ),
            )
          : null,
      groupId: data['groupId'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}
