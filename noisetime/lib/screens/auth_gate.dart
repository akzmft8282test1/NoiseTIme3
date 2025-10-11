
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Firebase 대신 Supabase를 가져옵니다.
import 'package:noisetime/screens/home_screen.dart';
import 'package:noisetime/screens/login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // Supabase의 인증 상태 변경 스트림을 사용합니다.
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        // 첫 인증 상태를 기다리는 동안 로딩 인디케이터를 보여줍니다.
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 세션(session)이 있는지 확인합니다.
        if (snapshot.data?.session != null) {
          // 세션이 있다면 사용자가 로그인된 것이므로 HomeScreen을 보여줍니다.
          return const HomeScreen();
        } else {
          // 세션이 없다면 로그인되지 않은 것이므로 LoginScreen을 보여줍니다.
          return const LoginScreen();
        }
      },
    );
  }
}
