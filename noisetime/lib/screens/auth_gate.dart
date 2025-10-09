
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:noisetime/screens/home_screen.dart';
import 'package:noisetime/screens/login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          // 사용자가 로그인 되어 있으면 HomeScreen을 보여줍니다.
          return const HomeScreen();
        } else {
          // 사용자가 로그인 되어 있지 않으면 LoginScreen을 보여줍니다.
          return const LoginScreen();
        }
      },
    );
  }
}
