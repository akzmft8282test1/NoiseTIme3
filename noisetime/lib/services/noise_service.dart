
import 'package:supabase_flutter/supabase_flutter.dart';

class NoiseService {
  final _supabase = Supabase.instance.client;

  // 측정된 소음 샘플을 데이터베이스에 추가하는 함수
  Future<void> addNoiseSample(double decibel) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      // 로그인한 사용자가 없으면 아무 작업도 하지 않음
      return;
    }

    try {
      // 먼저 현재 사용자의 프로필에서 group_id를 조회합니다.
      final profile = await _supabase
          .from('profiles')
          .select('group_id')
          .eq('id', user.id)
          .single();

      final groupId = profile['group_id'];

      // 사용자가 그룹에 속해 있지 않으면 소음 데이터를 저장하지 않습니다.
      if (groupId == null) {
        print("User is not in a group. Skipping noise sample saving.");
        return;
      }

      // noise_samples 테이블에 데이터를 삽입(insert)합니다.
      await _supabase.from('noise_samples').insert({
        'profile_id': user.id, // 소음을 측정한 사용자 ID
        'group_id': groupId,   // 사용자가 속한 그룹 ID
        'db_level': decibel,     // 측정된 데시벨 값
      });

    } catch (e) {
      // 오류가 발생하면 콘솔에 출력합니다.
      print('Error saving noise sample: $e');
    }
  }
}
