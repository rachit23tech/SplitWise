import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class InviteScreen extends StatelessWidget {
  final String groupId;
  final String groupName;

  const InviteScreen({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Invite Members")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Invite others to join \"$groupName\"",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            /// 🔑 GROUP ID
            const Text("Share this Group ID:"),
            const SizedBox(height: 8),
            SelectableText(
              groupId,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            /// 📤 SHARE BUTTON
            ElevatedButton.icon(
              icon: const Icon(Icons.share),
              label: const Text("Share Group ID"),
              onPressed: () {
                Share.share(
                  "Join my group \"$groupName\" on SplitWise.\n"
                  "Use this Group ID to join:\n\n$groupId",
                  subject: "Group Invitation",
                );
              },
            ),

            const SizedBox(height: 30),

            /// 📱 INVITE TO APP
            const Text(
              "Invite to App",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            ElevatedButton.icon(
              icon: const Icon(Icons.person_add),
              label: const Text("Invite to Install App"),
              onPressed: () {
                Share.share(
                  "Hey! I'm using SplitWise to manage expenses.\n"
                  "Install the app and join my group using this Group ID:\n\n$groupId",
                  subject: "Join Me on SplitWise",
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
