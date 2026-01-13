import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'add_expense_screen.dart';
import 'invite_screen.dart';

class GroupDetailsScreen extends StatefulWidget {
  final String groupId;
  final String groupName;

  const GroupDetailsScreen({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  State<GroupDetailsScreen> createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen> {
  late String groupName;

  String get uid => FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    groupName = widget.groupName;
  }

  /// Fetch group document
  Stream<DocumentSnapshot> getGroup() {
    return FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupId)
        .snapshots();
  }

  /// Fetch expenses
  Stream<QuerySnapshot> getExpenses() {
    return FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupId)
        .collection('expenses')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Get user name by uid
  Future<String> getUserName(String uid) async {
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (!doc.exists) return "Unknown";
    return doc.data()?['name'] ?? doc.data()?['email'] ?? "User";
  }

  /// 🔹 Convert paidBy map → "Paid by Rahul, You"
  Future<String> getPaidByNames(Map<String, dynamic> paidByMap) async {
    List<String> names = [];

    for (String id in paidByMap.keys) {
      final amount = (paidByMap[id] as num).toDouble();
      if (amount <= 0) continue;

      if (id == uid) {
        names.add("You");
      } else {
        final name = await getUserName(id);
        names.add(name);
      }
    }

    return names.join(", ");
  }

  /// 🔹 Get group member names
  Future<String> getMemberNames(List members) async {
    List<String> names = [];

    for (String id in members) {
      if (id == uid) {
        names.add("You");
      } else {
        final doc =
            await FirebaseFirestore.instance.collection('users').doc(id).get();
        names.add(doc.data()?['name'] ?? doc.data()?['email'] ?? "Member");
      }
    }

    return names.join(", ");
  }

  /// Delete Expense
  Future<void> deleteExpense(BuildContext context, String expenseId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Expense"),
        content: const Text("Are you sure you want to delete this expense?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .collection('expenses')
          .doc(expenseId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Expense deleted")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting expense: $e")),
      );
    }
  }

  /// Rename Group
  Future<void> editGroupName(BuildContext context) async {
    final controller = TextEditingController(text: groupName);

    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Rename Group"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: "Group Name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text("Save"),
          ),
        ],
      ),
    );

    if (newName == null || newName.isEmpty) return;

    await FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupId)
        .update({"name": newName});

    setState(() {
      groupName = newName;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Group renamed successfully")),
    );
  }

  /// Leave Group
  Future<void> leaveGroup(BuildContext context, List members) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Leave Group"),
        content: const Text("Are you sure you want to leave this group?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text("Leave"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final groupRef =
        FirebaseFirestore.instance.collection('groups').doc(widget.groupId);

    members.remove(uid);

    if (members.isEmpty) {
      await groupRef.delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Group deleted")),
      );
      Navigator.pop(context);
      return;
    }

    await groupRef.update({"members": members});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("You left the group")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: getGroup(),
      builder: (context, groupSnapshot) {
        if (!groupSnapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final groupData = groupSnapshot.data!.data() as Map<String, dynamic>;
        final groupName = groupData['name'] ?? 'Group';
        final List members = groupData['members'] ?? [];

        return Scaffold(
          appBar: AppBar(
            title: Text(groupName),
            actions: [
              /// Invite Members
              IconButton(
                icon: const Icon(Icons.person_add),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => InviteScreen(
                        groupId: widget.groupId,
                        groupName: groupName,
                      ),
                    ),
                  );
                },
              ),

              /// Rename Group
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => editGroupName(context),
              ),

              /// Leave Group
              IconButton(
                icon: const Icon(Icons.exit_to_app),
                onPressed: () => leaveGroup(context, List.from(members)),
              ),
            ],
          ),

          /// 📄 EXPENSE LIST
          body: Column(
            children: [
              /// 👥 Members Header
              Padding(
                padding: const EdgeInsets.all(12),
                child: FutureBuilder<String>(
                  future: getMemberNames(members),
                  builder: (context, snap) {
                    if (!snap.hasData) return const SizedBox();
                    return Text(
                      "Members: ${snap.data}",
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  },
                ),
              ),

              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: getExpenses(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    }

                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final expenses = snapshot.data!.docs;

                    if (expenses.isEmpty) {
                      return const Center(child: Text("No expenses yet"));
                    }

                    return ListView.builder(
                      itemCount: expenses.length,
                      itemBuilder: (context, index) {
                        final expense = expenses[index];
                        final data = expense.data() as Map<String, dynamic>;
                        final expenseId = expense.id;

                        return Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            title: Text(
                              data['title'],
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: FutureBuilder<String>(
                              future: getPaidByNames(
                                  Map<String, dynamic>.from(data['paidBy'])),
                              builder: (context, snap) {
                                if (!snap.hasData) {
                                  return const Text("Loading...");
                                }

                                return Text(
                                  "₹${data['amount']} • Paid by ${snap.data}",
                                  style: const TextStyle(fontSize: 13),
                                );
                              },
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete,
                                  color: Colors.redAccent),
                              onPressed: () =>
                                  deleteExpense(context, expenseId),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),

          /// ➕ ADD EXPENSE
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddExpenseScreen(
                    groupId: widget.groupId,
                    groupName: groupName,
                    members: members.cast<String>(),
                  ),
                ),
              );
            },
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}
