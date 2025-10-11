
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:noisetime/screens/group_screen.dart'; // HomeScreen 대신 GroupScreen을 가져옵니다.
import 'package:noisetime/screens/login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data?.session != null) {
          // 로그인된 사용자를 GroupScreen으로 안내합니다.
          return const GroupScreen(); 
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
