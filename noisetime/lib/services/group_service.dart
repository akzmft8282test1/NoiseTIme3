
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
    // profiles 테이블에서 현재 사용자의 데이터를 실시간으로 구독합니다.
    return _supabase
        .from('profiles')
        .stream(primaryKey: ['id'])
        .eq('id', userId)
        .map((data) => data.isNotEmpty ? data[0] : null);
  }

  // 특정 그룹의 정보를 실시간으로 가져오는 스트림
  Stream<Map<String, dynamic>?> getGroupStream(String groupId) {
    // groups 테이블에서 특정 groupId를 가진 데이터를 실시간으로 구독합니다.
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

    // groups 테이블에 새로운 그룹을 삽입하고, 생성된 그룹의 id를 반환받습니다.
    final newGroup = await _supabase.from('groups').insert({
      'name': name,
      'owner_id': user.id,
    }).select('id').single();

    final newGroupId = newGroup['id'];

    // group_members 테이블에 그룹 생성자와 그룹의 관계를 추가합니다.
    await _supabase.from('group_members').insert({
      'group_id': newGroupId,
      'profile_id': user.id,
    });
    
    // profiles 테이블의 현재 사용자 정보에 group_id를 업데이트합니다.
    // (참고: 이 부분은 PostgreSQL의 트리거로 자동화할 수도 있습니다.)
    await _supabase
        .from('profiles')
        .update({'group_id': newGroupId})
        .eq('id', user.id);
  }

  // 다른 여러 그룹 관리 함수들을 이곳에 추가할 수 있습니다.
  // (멤버 추가/삭제, 페널티 설정 등)
}
