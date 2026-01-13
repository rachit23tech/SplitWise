import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PersonalExpensesScreen extends StatelessWidget {
  const PersonalExpensesScreen({super.key});

  String get uid => FirebaseAuth.instance.currentUser!.uid;

  Stream<QuerySnapshot> getPersonalExpenses() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('personal_expenses')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Personal Expenses")),
      body: StreamBuilder<QuerySnapshot>(
        stream: getPersonalExpenses(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final expenses = snapshot.data!.docs;

          if (expenses.isEmpty) {
            return const Center(child: Text("No personal expenses yet"));
          }

          double total = 0;
          for (var doc in expenses) {
            total += (doc['amount'] as num).toDouble();
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  "Total: ₹${total.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: expenses.length,
                  itemBuilder: (context, index) {
                    final expense = expenses[index];
                    final title = expense['title'];
                    final amount = (expense['amount'] as num).toDouble();

                    return ListTile(
                      title: Text(title),
                      trailing: Text("₹${amount.toStringAsFixed(2)}"),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
