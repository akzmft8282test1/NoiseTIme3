
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:noisetime/screens/auth_gate.dart';
import 'package:noisetime/services/notification_service.dart'; // NotificationService import
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize NotificationService
  await NotificationService().initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NoiseTime',
      theme: ThemeData(
        // 전체적인 색상 톤을 부드럽게 설정
        primarySwatch: Colors.indigo,
        // 시각적 피드백을 부드럽게 변경
        splashFactory: InkRipple.splashFactory,
        // 전체적인 폰트 스타일 설정
        textTheme: const TextTheme(
          // AppBar 제목 스타일
          titleLarge: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          // 본문 텍스트 스타일
          bodyMedium: TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        // AppBar 테마 설정
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.indigo,
          elevation: 0,
        ),
        // 하단 네비게이션 바 테마 설정
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: Colors.indigo,
          unselectedItemColor: Colors.grey,
        ),
      ),
      home: const AuthGate(),
    );
  }
}
