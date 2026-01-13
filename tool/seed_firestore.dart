import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../lib/firebase_options.dart';

/// Seed script to populate Firestore with sample users, expenses, and payments.
///
/// This script requires the Firebase emulator to be running or a valid Firebase project configured.
/// Run with: dart tool/seed_firestore.dart
Future<void> main() async {
  // Initialize Firebase with options from firebase_options.dart
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final db = FirebaseFirestore.instance;

  print('Seeding Firestore...');

  // Create sample users
  final users = [
    {'uid': 'user1', 'email': 'alice@example.com', 'displayName': 'Alice'},
    {'uid': 'user2', 'email': 'bob@example.com', 'displayName': 'Bob'},
    {'uid': 'user3', 'email': 'charlie@example.com', 'displayName': 'Charlie'},
  ];

  for (final u in users) {
    await db.collection('users').doc(u['uid'] as String).set(u);
    print('Created user: ${u['displayName']}');
  }

  // Create sample expenses
  final now = DateTime.now();
  await db.collection('expenses').add({
    'description': 'Dinner',
    'amount': 60.0,
    'paidBy': 'user1',
    'participants': ['user1', 'user2', 'user3'],
    'splitType': 'equal',
    'groupId': 'group1',
    'createdAt': Timestamp.fromDate(now.subtract(Duration(days: 1))),
  });
  print('Created expense: Dinner');

  await db.collection('expenses').add({
    'description': 'Movie',
    'amount': 30.0,
    'paidBy': 'user2',
    'participants': ['user2', 'user3'],
    'splitType': 'equal',
    'groupId': 'group1',
    'createdAt': Timestamp.fromDate(now),
  });
  print('Created expense: Movie');

  // Create sample payment
  await db.collection('payments').add({
    'from': 'user1',
    'to': 'user2',
    'amount': 10.0,
    'date': Timestamp.fromDate(now),
  });
  print('Created payment: user1 -> user2');

  print('✓ Seeding complete!');
}
