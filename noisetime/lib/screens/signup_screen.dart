import 'package:flutter/material.dart';
import 'package:noisetime/services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('회원가입'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '이름 (닉네임)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
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
                // await 호출 전에 BuildContext를 사용하는 객체들을 변수에 저장
                final navigator = Navigator.of(context);
                final scaffoldMessenger = ScaffoldMessenger.of(context);

                final user = await _authService.createUserWithEmailAndPassword(
                  email: _emailController.text,
                  password: _passwordController.text,
                  displayName: _nameController.text,
                );
                
                // await 이후에 위젯이 화면에 있는지 확인
                if (!mounted) return;

                if (user != null) {
                  // 회원가입 성공 시 미리 저장해둔 navigator를 사용하여 화면을 닫음
                  navigator.pop();
                } else {
                  // 회원가입 실패 시 미리 저장해둔 scaffoldMessenger를 사용하여 SnackBar 표시
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(content: Text('회원가입에 실패했습니다.')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('회원가입'),
            ),
          ],
        ),
      ),
    );
  }
}
