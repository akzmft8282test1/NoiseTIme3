
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Supabase를 이용한 이메일/비밀번호 회원가입
  Future<User?> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      // Supabase Auth에 사용자를 생성합니다.
      final AuthResponse res = await _supabase.auth.signUp(
        email: email,
        password: password,
        // data 필드를 사용하여 부가 정보를 함께 전달할 수 있습니다.
        // 이 정보는 나중에 profiles 테이블 업데이트 등에 활용될 수 있습니다.
        data: {'display_name': displayName},
      );
      
      // 회원가입 성공 시 사용자 정보를 반환합니다.
      return res.user;

    } on AuthException catch (e) {
      // 오류 처리
      debugPrint(e.toString());
      return null;
    }
  }

  // Supabase를 이용한 이메일/비밀번호 로그인
  Future<User?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      // Supabase Auth를 통해 로그인을 시도합니다.
      final AuthResponse res = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      // 로그인 성공 시 사용자 정보를 반환합니다.
      return res.user;

    } on AuthException catch (e) {
      // 오류 처리
      debugPrint(e.toString());
      return null;
    }
  }

  // Supabase를 이용한 로그아웃
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // Supabase의 사용자 인증 상태 스트림
  // 이 스트림을 통해 로그인/로그아웃 상태 변화를 감지할 수 있습니다.
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // 현재 로그인된 사용자 정보를 가져오는 getter
  User? get currentUser => _supabase.auth.currentUser;
}
