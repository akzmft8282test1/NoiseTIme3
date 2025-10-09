
import 'package:flutter/material.dart';
import 'package:noisetime/screens/signup_screen.dart';
import 'package:noisetime/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('로그인'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: '이메일',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: '비밀번호',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                final user = await _authService.signInWithEmailAndPassword(
                  email: _emailController.text,
                  password: _passwordController.text,
                );
                if (user != null) {
                  // 로그인이 성공하면 홈 화면으로 이동합니다.
                  // 이 부분은 나중에 AuthGate에서 자동으로 처리됩니다.
                } else {
                  // 로그인 실패 시 사용자에게 알림
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('로그인에 실패했습니다.')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('로그인'),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignupScreen()),
                );
              },
              child: const Text('아직 계정이 없으신가요? 회원가입'),
            ),
          ],
        ),
      ),
    );
  }
}
