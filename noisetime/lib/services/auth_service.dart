
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 이메일/비밀번호로 회원가입
  Future<User?> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = userCredential.user;

      if (user != null) {
        // Firestore에 사용자 정보 저장
        await _firestore.collection('users').doc(user.uid).set({
          'email': email,
          'displayName': displayName,
          'createdAt': Timestamp.now(),
          'group_id': null,
        });
      }

      return user;
    } on FirebaseAuthException catch (e) {
      // 오류 처리
      print(e);
      return null;
    }
  }

  // 이메일/비밀번호로 로그인
  Future<User?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      // 오류 처리
      print(e);
      return null;
    }
  }

  // 로그아웃
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // 사용자 인증 상태 스트림
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
