import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  final user = FirebaseAuth.instance.currentUser!;
  final firestore = FirebaseFirestore.instance;

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 🔹 Get total personal expenses
  Stream<double> getPersonalTotal() {
    return firestore
        .collection('users')
        .doc(user.uid)
        .collection('personal_expenses')
        .snapshots()
        .map((snapshot) {
      double total = 0;
      for (var doc in snapshot.docs) {
        total += (doc['amount'] as num).toDouble();
      }
      return total;
    });
  }

  /// 🔹 Get total spent in groups (only what YOU paid)
  Stream<double> getGroupTotal() {
    return firestore
        .collection('groups')
        .where('members', arrayContains: user.uid)
        .snapshots()
        .asyncMap((groupsSnapshot) async {
      double total = 0;

      for (var group in groupsSnapshot.docs) {
        final expensesSnapshot = await firestore
            .collection('groups')
            .doc(group.id)
            .collection('expenses')
            .get();

        for (var expense in expensesSnapshot.docs) {
          final data = expense.data();
          if (data['paidBy'] == user.uid) {
            total += (data['amount'] as num).toDouble();
          }
        }
      }
      return total;
    });
  }

  /// ✏️ Edit Display Name
  Future<void> editName() async {
    final controller = TextEditingController(text: user.displayName ?? "");

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Name"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: "Your Name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Save"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final newName = controller.text.trim();
      if (newName.isNotEmpty) {
        await user.updateDisplayName(newName);
        await firestore.collection('users').doc(user.uid).set({
          'name': newName,
          'email': user.email,
        }, SetOptions(merge: true));

        setState(() {});
      }
    }
  }

  /// 📩 Invite Others
  void inviteOthers() {
    Share.share(
      "Hey! I'm using SplitWise app to track expenses. Join me 🚀",
      subject: "Join me on SplitWise",
    );
  }

  /// ➕ Add Personal Expense
  Future<void> addPersonalExpense() async {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    final categoryController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Personal Expense"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Title"),
              ),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(labelText: "Amount"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(labelText: "Category"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final title = titleController.text.trim();
                final amount =
                    double.tryParse(amountController.text.trim()) ?? 0;
                final category = categoryController.text.trim();

                if (title.isEmpty || amount <= 0) return;

                await firestore
                    .collection('users')
                    .doc(user.uid)
                    .collection('personal_expenses')
                    .add({
                  'title': title,
                  'amount': amount,
                  'category': category.isEmpty ? "General" : category,
                  'createdAt': FieldValue.serverTimestamp(),
                });

                Navigator.pop(context);
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  /// 🗑 Delete single personal expense
  Future<void> deletePersonalExpense(String expenseId) async {
    await firestore
        .collection('users')
        .doc(user.uid)
        .collection('personal_expenses')
        .doc(expenseId)
        .delete();
  }

  /// 🔄 Reset all personal expenses
  Future<void> resetPersonalExpenses() async {
    final snapshot = await firestore
        .collection('users')
        .doc(user.uid)
        .collection('personal_expenses')
        .get();

    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  /// 🔐 Logout
  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pop(context);
  }

  /// ❌ Delete account
  Future<void> deleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Account"),
        content: const Text(
            "This will permanently delete your account and all your data."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final expensesSnapshot = await firestore
          .collection('users')
          .doc(user.uid)
          .collection('personal_expenses')
          .get();

      for (var doc in expensesSnapshot.docs) {
        await doc.reference.delete();
      }

      await firestore.collection('users').doc(user.uid).delete();
      await user.delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Scaffold(
        backgroundColor: Colors.white70,
        appBar: AppBar(
          backgroundColor: Colors.white70,
          title: const Text("Profile"),
          actions: [
            IconButton(
              icon: const Icon(Icons.person_add),
              onPressed: inviteOthers,
            ),
          ],
        ),
        body: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 👤 USER INFO
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.displayName ?? "User",
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(user.email ?? ""),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: editName,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// 💰 TOTALS
              StreamBuilder<double>(
                stream: getPersonalTotal(),
                builder: (context, personalSnapshot) {
                  return StreamBuilder<double>(
                    stream: getGroupTotal(),
                    builder: (context, groupSnapshot) {
                      if (!personalSnapshot.hasData || !groupSnapshot.hasData) {
                        return const Text(
                          "Calculating totals...",
                          style: TextStyle(color: Colors.white70),
                        );
                      }

                      final personalTotal = personalSnapshot.data!;
                      final groupTotal = groupSnapshot.data!;
                      final totalSpent = personalTotal + groupTotal;

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                "Personal Spent: ₹${personalTotal.toStringAsFixed(2)}"),
                            Text(
                                "Group Spent (paid by you): ₹${groupTotal.toStringAsFixed(2)}"),
                            const Divider(),
                            Text(
                              "Total Spent: ₹${totalSpent.toStringAsFixed(2)}",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: 20),

              /// 📄 PERSONAL EXPENSES HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Your Personal Expenses",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.white),
                    onPressed: addPersonalExpense,
                  ),
                ],
              ),

              const SizedBox(height: 10),

              /// 📄 PERSONAL EXPENSE LIST
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: firestore
                      .collection('users')
                      .doc(user.uid)
                      .collection('personal_expenses')
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final expenses = snapshot.data!.docs;

                    if (expenses.isEmpty) {
                      return const Center(
                          child: Text("No personal expenses yet",
                              style: TextStyle(color: Colors.white)));
                    }

                    return ListView.builder(
                      itemCount: expenses.length,
                      itemBuilder: (context, index) {
                        final data =
                            expenses[index].data() as Map<String, dynamic>;

                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: ListTile(
                            title: Text(data['title']),
                            subtitle: Text(data['category'] ?? "General"),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                    "₹${(data['amount'] as num).toDouble().toStringAsFixed(2)}"),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () =>
                                      deletePersonalExpense(expenses[index].id),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              /// 🔄 RESET BUTTON
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text("Reset Personal Expenses"),
                onPressed: resetPersonalExpenses,
              ),

              const SizedBox(height: 10),

              /// 🔐 LOGOUT
              ElevatedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text("Logout"),
                onPressed: logout,
              ),

              /// ❌ DELETE ACCOUNT
              TextButton.icon(
                icon: const Icon(Icons.delete, color: Colors.red),
                label: const Text("Delete Account",
                    style: TextStyle(color: Colors.red)),
                onPressed: deleteAccount,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
