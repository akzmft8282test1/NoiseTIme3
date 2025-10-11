
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Firebase 대신 Supabase 패키지를 가져옵니다.
import 'package:noisetime/screens/auth_gate.dart';
import 'package:noisetime/services/notification_service.dart'; // NotificationService는 그대로 사용합니다.

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화 코드를 제거하고 아래 Supabase 초기화 코드로 대체합니다.
  await Supabase.initialize(
    url: 'https://ntooyuilabwqjeuymnkl.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im50b295dWlsYWJ3cWpldXltbmtsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjAwODMyNTQsImV4cCI6MjA3NTY1OTI1NH0.Khzt1gFjbTy58ysfTN75sclwTFOQih8XP3VdtXf8RHs',
  );

  // NotificationService 초기화는 그대로 둡니다.
  await NotificationService().initialize();

  runApp(const MyApp());
}

// MyApp 위젯의 내용은 변경할 필요가 없습니다.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NoiseTime',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        splashFactory: InkRipple.splashFactory,
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          bodyMedium: TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.indigo,
          elevation: 0,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: Colors.indigo,
          unselectedItemColor: Colors.grey,
        ),
      ),
      home: const AuthGate(),
    );
  }
}
