import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddExpenseScreen extends StatefulWidget {
  final String groupId;
  final String groupName;
  final List<String> members;

  const AddExpenseScreen({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.members,
  });

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  final uid = FirebaseAuth.instance.currentUser!.uid;

  bool isLoading = false;
  bool isEqualSplit = true;

  /// 👤 Member details with names
  List<Map<String, dynamic>> memberDetails = [];

  /// 💰 Maps for Firestore
  final Map<String, double> paidBy = {};
  final Map<String, double> splits = {};

  @override
  void initState() {
    super.initState();
    fetchMembers();
  }

  /// 🔹 Load member names from Firestore
  Future<void> fetchMembers() async {
    List<Map<String, dynamic>> loaded = [];

    for (String id in widget.members) {
      try {
        final doc =
            await FirebaseFirestore.instance.collection('users').doc(id).get();

        final String name = doc.exists
            ? (doc.data()?['name'] ?? doc.data()?['email'] ?? "Member")
            : "Member";

        loaded.add({
          "uid": id,
          "name": id == uid ? "You" : name,
        });

        paidBy[id] = 0;
        splits[id] = 0;
      } catch (e) {
        debugPrint("Error fetching user $id: $e");
      }
    }

    if (mounted) {
      setState(() {
        memberDetails = loaded;
      });
    }
  }

  /// 🔹 Apply equal split logic
  void applyEqualSplit() {
    final double amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0 || memberDetails.isEmpty) return;

    final double splitAmount = amount / memberDetails.length;

    setState(() {
      for (var m in memberDetails) {
        splits[m['uid']] = double.parse(splitAmount.toStringAsFixed(2));
      }
    });
  }

  /// 🔹 Validate and save expense
  Future<void> saveExpense() async {
    final title = _titleController.text.trim();
    final amount = double.tryParse(_amountController.text) ?? 0;

    if (title.isEmpty || amount <= 0) {
      show("Enter valid title and amount");
      return;
    }

    final double totalPaid = paidBy.values.fold(0.0, (p, e) => p + e);
    final double totalSplit = splits.values.fold(0.0, (p, e) => p + e);

    if (totalPaid.toStringAsFixed(2) != amount.toStringAsFixed(2)) {
      show("Total paid must equal total amount");
      return;
    }

    if (totalSplit.toStringAsFixed(2) != amount.toStringAsFixed(2)) {
      show("Total split must equal total amount");
      return;
    }

    setState(() => isLoading = true);

    try {
      await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .collection('expenses')
          .add({
        'title': title,
        'amount': amount,
        'paidBy': paidBy, // 💰 Multi-payer support
        'splits': splits, // 📊 Equal / Custom splits
        'createdAt': FieldValue.serverTimestamp(),
      });

      Navigator.pop(context);
    } catch (e) {
      show("Error: $e");
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  void show(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Expense - ${widget.groupName}"),
      ),
      body: memberDetails.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// 📝 TITLE
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: "Title",
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 12),

                    /// 💰 AMOUNT
                    TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Amount",
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (_) {
                        if (isEqualSplit) applyEqualSplit();
                      },
                    ),

                    const SizedBox(height: 20),

                    /// 🔀 SPLIT TOGGLE
                    Row(
                      children: [
                        const Text(
                          "Split Type:",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 10),
                        ChoiceChip(
                          label: const Text("Equal"),
                          selected: isEqualSplit,
                          onSelected: (_) {
                            setState(() {
                              isEqualSplit = true;
                              applyEqualSplit();
                            });
                          },
                        ),
                        const SizedBox(width: 10),
                        ChoiceChip(
                          label: const Text("Custom"),
                          selected: !isEqualSplit,
                          onSelected: (_) {
                            setState(() {
                              isEqualSplit = false;
                            });
                          },
                        ),
                      ],
                    ),

                    const Divider(height: 30),

                    /// 💳 PAID BY
                    const Text(
                      "Paid By",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),

                    ...memberDetails.map((m) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Expanded(child: Text(m['name'])),
                            SizedBox(
                              width: 100,
                              child: TextField(
                                keyboardType: TextInputType.number,
                                decoration:
                                    const InputDecoration(hintText: "0"),
                                onChanged: (val) {
                                  setState(() {
                                    paidBy[m['uid']] =
                                        double.tryParse(val) ?? 0;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                    const Divider(height: 30),

                    /// 📊 SPLIT BETWEEN
                    const Text(
                      "Split Between",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),

                    ...memberDetails.map((m) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Expanded(child: Text(m['name'])),
                            SizedBox(
                              width: 100,
                              child: TextField(
                                enabled: !isEqualSplit,
                                keyboardType: TextInputType.number,
                                decoration:
                                    const InputDecoration(hintText: "0"),
                                controller: TextEditingController(
                                  text: splits[m['uid']] == 0
                                      ? ""
                                      : splits[m['uid']]!.toStringAsFixed(2),
                                ),
                                onChanged: (val) {
                                  setState(() {
                                    splits[m['uid']] =
                                        double.tryParse(val) ?? 0;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 30),

                    /// 💾 SAVE BUTTON
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : saveExpense,
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text("Save Expense"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
