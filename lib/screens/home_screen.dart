import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'create_group_screen.dart';
import 'group_details_screen.dart';
import 'profile_screen.dart';
import 'join_group_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  final bool isGuest;

  HomeScreen({super.key, this.isGuest = false});

  /// 👤 Current user ID (null in guest mode)
  String? get uid => FirebaseAuth.instance.currentUser?.uid;

  /// 🔹 Fetch only groups where current user is a member
  Stream<QuerySnapshot> getGroups() {
    if (isGuest || uid == null) {
      return const Stream.empty(); // No Firestore calls in guest mode
    }

    return FirebaseFirestore.instance
        .collection('groups')
        .where('members', arrayContains: uid)
        .snapshots();
  }

  /// 🔹 Get user name by UID (creator)
  Future<String> getUserName(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (!doc.exists) return "Unknown";
      return doc.data()?['name'] ?? doc.data()?['email'] ?? "User";
    } catch (e) {
      return "Unknown";
    }
  }

  /// 🔐 Show login dialog for restricted actions
  void showLoginRequired(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Login Required"),
        content: const Text(
          "You must log in to create, join groups and manage expenses.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            child: const Text("Login"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),

      appBar: AppBar(
        title: const Text("SplitWise"),
        elevation: 0,
        actions: [
          /// 👤 Profile
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              if (isGuest) {
                showLoginRequired(context);
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              }
            },
          ),

          /// ➕ Join Group
          IconButton(
            icon: const Icon(Icons.group_add),
            onPressed: () {
              if (isGuest) {
                showLoginRequired(context);
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const JoinGroupScreen()),
                );
              }
            },
          ),
        ],
      ),

      /// ➕ Create Group
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.group_add),
        label: const Text("Create Group"),
        onPressed: () {
          if (isGuest) {
            showLoginRequired(context);
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CreateGroupScreen()),
            );
          }
        },
      ),

      /// 🧾 BODY
      body: isGuest
          ? const Center(
              child: Text(
                "You are in Guest Mode.\nLogin to create or join groups.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            )
          : StreamBuilder<QuerySnapshot>(
              stream: getGroups(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "No groups yet",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  );
                }

                final groups = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: groups.length,
                  itemBuilder: (context, index) {
                    final group = groups[index];
                    final groupId = group.id;
                    final groupName = group['name'];
                    final creatorId = group['createdBy'];
                    final List members = group['members'] ?? [];

                    return Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
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
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),

                        /// 📛 GROUP NAME
                        title: Text(
                          groupName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        /// 👥 Creator + Member Count
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /// 👤 Creator
                              FutureBuilder<String>(
                                future: getUserName(creatorId),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return const Text(
                                      "Loading creator...",
                                      style: TextStyle(fontSize: 12),
                                    );
                                  }

                                  final isYou = creatorId == uid;

                                  return Text(
                                    isYou
                                        ? "Created by You"
                                        : "Created by ${snapshot.data}",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              ),

                              const SizedBox(height: 4),

                              /// 👥 MEMBER COUNT
                              Text(
                                "Members: ${members.length}",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),

                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.grey,
                        ),

                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => GroupDetailsScreen(
                                groupId: groupId,
                                groupName: groupName,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
