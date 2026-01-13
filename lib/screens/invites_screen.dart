import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart';

class InviteScreen extends StatelessWidget {
  final String groupId;

  const InviteScreen({super.key, required this.groupId});

  String get uid => FirebaseAuth.instance.currentUser!.uid;

  /// Generate Invite Link (simple deep link style)
  String generateInviteLink() {
    return "https://splitwise.app/invite?groupId=$groupId";
  }

  /// Copy link
  void copyLink(BuildContext context) {
    final link = generateInviteLink();
    Share.share(link);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Invite link copied / ready to share")),
    );
  }

  /// Share via apps (WhatsApp, Email, Messages, etc.)
  void shareLink() {
    final link = generateInviteLink();
    Share.share(
      "Join my expense group on SplitWise 👇\n$link",
      subject: "SplitWise Group Invite",
    );
  }

  /// List group members
  Stream<QuerySnapshot> getMembers() {
    return FirebaseFirestore.instance
        .collection('groups')
        .doc(groupId)
        .collection('members')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final inviteLink = generateInviteLink();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Invite Members"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Invite Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Invite Link",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    inviteLink,
                    style: const TextStyle(color: Colors.blue),
                  ),
                  const SizedBox(height: 12),

                  /// Buttons Row
                  Row(
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.share),
                        label: const Text("Share"),
                        onPressed: shareLink,
                      ),
                      const SizedBox(width: 10),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.copy),
                        label: const Text("Copy"),
                        onPressed: () => copyLink(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            /// Members Title
            const Text(
              "Group Members",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            /// Members List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: getMembers(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final members = snapshot.data!.docs;

                  if (members.isEmpty) {
                    return const Center(child: Text("No members yet"));
                  }

                  return ListView.builder(
                    itemCount: members.length,
                    itemBuilder: (context, index) {
                      final data =
                          members[index].data() as Map<String, dynamic>;
                      final name = data['name'] ?? "User";
                      final email = data['email'] ?? "";

                      return ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.person)),
                        title: Text(name),
                        subtitle: Text(email),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
