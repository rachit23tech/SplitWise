import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/group.dart';

class GroupService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createGroup(Group group) async {
    await _db.collection('groups').add(group.toMap());
  }

  Stream<List<Group>> getUserGroups(String userId) {
    return _db
        .collection('groups')
        .where('members', arrayContains: userId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            return Group(
              id: doc.id,
              name: data['name'],
              members: List<String>.from(data['members']),
            );
          }).toList(),
        );
  }
}
