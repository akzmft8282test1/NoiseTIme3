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
                // await 호출 전에 BuildContext를 사용하는 객체를 변수에 저장
                final scaffoldMessenger = ScaffoldMessenger.of(context);

                final user = await _authService.signInWithEmailAndPassword(
                  email: _emailController.text,
                  password: _passwordController.text,
                );
                
                if (user == null) {
                  // await 이후에 위젯이 화면에 있는지 확인
                  if (!mounted) return;
                  // 미리 저장해둔 변수를 사용하여 SnackBar 표시
                  scaffoldMessenger.showSnackBar(
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
