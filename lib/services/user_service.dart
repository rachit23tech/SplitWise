import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get _users => _db.collection('users');

  Future<void> createUserIfNotExists(AppUser u) async {
    try {
      final doc = _users.doc(u.uid);
      final snap = await doc.get();
      if (!snap.exists) {
        print('Creating user document for ${u.uid}');
        await doc.set(u.toMap());
        print('User document created successfully');
      }
    } catch (e) {
      print('Error creating user: $e');
      rethrow;
    }
  }

  Stream<List<AppUser>> streamUsers() {
    return _users.snapshots().map(
      (s) => s.docs
          .map((d) => AppUser.fromMap(d.data() as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<List<AppUser>> getAllUsers() async {
    final s = await _users.get();
    return s.docs
        .map((d) => AppUser.fromMap(d.data() as Map<String, dynamic>))
        .toList();
  }
}
