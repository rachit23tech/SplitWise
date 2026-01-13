import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/notification_service.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final NotificationService service = NotificationService();

    return Scaffold(
      appBar: AppBar(title: const Text("Notifications")),
      body: StreamBuilder(
        stream: service.getUserNotifications(userId),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text("No notifications yet"));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final data = docs[i];
              return ListTile(
                title: Text(data['title']),
                subtitle: Text(data['message']),
              );
            },
          );
        },
      ),
    );
  }
}
