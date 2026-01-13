import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/expense.dart';
import 'notification_service.dart';

final NotificationService _notificationService = NotificationService();

class ExpenseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addExpense(Expense expense) async {
    await _db.collection('expenses').add(expense.toMap());
    for (String uid in expense.participants) {
      if (uid != expense.paidBy) {
        await _notificationService.sendNotification(
          userId: uid,
          title: "New Expense Added",
          message:
              "You owe ₹${expense.customSplits?[uid] ?? (expense.amount / expense.participants.length)}",
        );
      }
    }
  }

  Stream<List<Expense>> getExpensesForGroup(String groupId) {
    return _db
        .collection('expenses')
        .where('groupId', isEqualTo: groupId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Expense.fromDoc(doc)).toList(),
        );
  }

  Future<Map<String, double>> getUserSummary(String userId) async {
    final snapshot = await _db.collection('expenses').get();

    double youOwe = 0;
    double youAreOwed = 0;

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final paidBy = data['paidBy'];
      final amount = (data['amount'] as num).toDouble();
      final splitType = data['splitType'];
      final participants = List<String>.from(data['participants']);

      if (splitType == "equal") {
        final perPerson = amount / participants.length;

        if (userId == paidBy) {
          youAreOwed += amount - perPerson;
        } else if (participants.contains(userId)) {
          youOwe += perPerson;
        }
      } else {
        final custom = Map<String, dynamic>.from(data['customSplits']);

        if (userId == paidBy) {
          youAreOwed += amount - (custom[userId] ?? 0);
        } else if (custom.containsKey(userId)) {
          youOwe += (custom[userId] as num).toDouble();
        }
      }
    }

    return {"owe": youOwe, "owed": youAreOwed};
  }

  /// Calculates balance for a user
  Future<double> getUserBalance(String userId) async {
    final snapshot = await _db.collection('expenses').get();

    double balance = 0;

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final paidBy = data['paidBy'];
      final amount = (data['amount'] as num).toDouble();
      final splitType = data['splitType'];
      final participants = List<String>.from(data['participants']);

      if (splitType == "equal") {
        final perPerson = amount / participants.length;
        if (userId == paidBy) {
          balance += amount - perPerson;
        } else if (participants.contains(userId)) {
          balance -= perPerson;
        }
      } else {
        final custom = Map<String, dynamic>.from(data['customSplits']);
        if (userId == paidBy) {
          balance += amount - (custom[userId] ?? 0);
        } else if (custom.containsKey(userId)) {
          balance -= (custom[userId] as num).toDouble();
        }
      }
    }

    return balance;
  }
}
