import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class InviteUserScreen extends StatefulWidget {
  final String groupId;

  const InviteUserScreen({super.key, required this.groupId});

  @override
  State<InviteUserScreen> createState() => _InviteUserScreenState();
}

class _InviteUserScreenState extends State<InviteUserScreen> {
  final _emailController = TextEditingController();
  final uid = FirebaseAuth.instance.currentUser!.uid;

  Future<void> sendInvite() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Enter email")));
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .collection('invites')
          .add({
            'email': email,
            'invitedBy': uid,
            'status': 'pending',
            'createdAt': Timestamp.now(),
          });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Invite sent")));

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Invite User")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "User Email"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: sendInvite,
              child: const Text("Send Invite"),
            ),
          ],
        ),
      ),
    );
  }
}
