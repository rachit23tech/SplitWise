import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class JoinGroupScreen extends StatefulWidget {
  const JoinGroupScreen({super.key});

  @override
  State<JoinGroupScreen> createState() => _JoinGroupScreenState();
}

class _JoinGroupScreenState extends State<JoinGroupScreen> {
  final _groupIdController = TextEditingController();
  bool isLoading = false;

  Future<void> joinGroup() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final groupId = _groupIdController.text.trim();
    print("USER UID: ${FirebaseAuth.instance.currentUser?.uid}");

    if (groupId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter Group ID")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final groupRef =
          FirebaseFirestore.instance.collection('groups').doc(groupId);

      // 🔑 Just try to add user to members
      await groupRef.update({
        'members': FieldValue.arrayUnion([uid]),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Joined group successfully")),
      );

      Navigator.pop(context); // Back to home
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Unable to join group: $e")),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Join Group")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _groupIdController,
              decoration: const InputDecoration(
                labelText: "Enter Group ID",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : joinGroup,
              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text("Join Group"),
            ),
          ],
        ),
      ),
    );
  }
}
