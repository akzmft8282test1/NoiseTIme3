
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

class GroupService {
  final _supabase = Supabase.instance.client;

  // 현재 사용자의 프로필 정보를 실시간으로 가져오는 스트림
  Stream<Map<String, dynamic>?> getProfileStream() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      return Stream.value(null);
    }
    return _supabase
        .from('profiles')
        .stream(primaryKey: ['id'])
        .eq('id', userId)
        .map((data) => data.isNotEmpty ? data[0] : null);
  }

  // 특정 그룹의 정보를 실시간으로 가져오는 스트림
  Stream<Map<String, dynamic>?> getGroupStream(String groupId) {
    return _supabase
        .from('groups')
        .stream(primaryKey: ['id'])
        .eq('id', groupId)
        .map((data) => data.isNotEmpty ? data[0] : null);
  }

  // 새로운 그룹을 생성하는 함수
  Future<void> createGroup(String name) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception("Not authenticated");
    }

    final newGroup = await _supabase.from('groups').insert({
      'name': name,
      'owner_id': user.id,
    }).select('id').single();

    final newGroupId = newGroup['id'];

    // group_members 테이블은 사용하지 않으므로 관련 로직 제거

    await _supabase
        .from('profiles')
        .update({'group_id': newGroupId})
        .eq('id', user.id);
  }

  // 그룹에서 나가는 함수
  Future<void> leaveGroup() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }
    // 사용자의 group_id를 null로 업데이트합니다.
    await _supabase
        .from('profiles')
        .update({'group_id': null})
        .eq('id', user.id);
  }

  // 소음 샘플을 데이터베이스에 저장하는 함수
  Future<void> saveNoiseSample(String groupId, String userId, double decibel) async {
    await _supabase.from('noise_samples').insert({
      'group_id': groupId,
      'profile_id': userId,
      'db_level': decibel, // 컬럼명 db_level로 수정
    });
  }

  // 다른 여러 그룹 관리 함수들을 이곳에 추가할 수 있습니다.
  // (멤버 추가/삭제, 페널티 설정 등)
}
