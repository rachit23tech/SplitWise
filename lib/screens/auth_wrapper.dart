import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'welcome_screen.dart';
import 'home_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // 🔄 Still checking authentication state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // ✅ User logged in → Full app access
        if (snapshot.hasData) {
          return HomeScreen(isGuest: false);
        }

        // 👀 User not logged in → Guest mode via WelcomeScreen
        return const WelcomeScreen();
      },
    );
  }
}
