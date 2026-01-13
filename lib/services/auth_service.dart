import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Login
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return result.user;
    } catch (e) {
      throw e.toString();
    }
  }

  // Register
  Future<User?> registerWithEmail(
    String name,
    String email,
    String password,
  ) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      User? user = result.user;

      // Save user data to Firestore
      await _firestore.collection('users').doc(user!.uid).set({
        'uid': user.uid,
        'name': name,
        'email': email,
        'createdAt': Timestamp.now(),
      });

      return user;
    } catch (e) {
      throw e.toString();
    }
  }

  // Logout
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
