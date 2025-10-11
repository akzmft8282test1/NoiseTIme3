
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

class CommunityService {
  final _supabase = Supabase.instance.client;

  // 현재 유저가 속한 그룹의 모든 소음 샘플을 실시간으로 가져오는 스트림
  Stream<List<Map<String, dynamic>>> getNoiseSamplesStream() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return Stream.value([]);

    // 1. 먼저 현재 유저의 group_id를 찾습니다.
    // 2. 해당 group_id를 가진 모든 noise_samples를 구독(stream)합니다.
    // 이 로직은 실제로는 복잡하므로, 먼저 프로필을 조회한 후 스트림을 시작합니다.
    final controller = StreamController<List<Map<String, dynamic>>>();

    Future<void> fetchSamples() async {
      try {
        final profile = await _supabase
            .from('profiles')
            .select('group_id')
            .eq('id', userId)
            .single();
        
        final groupId = profile['group_id'];

        if (groupId != null) {
          // group_id가 일치하는 noise_samples를 실시간으로 구독하고, 작성자의 이름(profiles.name)도 함께 가져옵니다.
          _supabase
              .from('noise_samples')
              .stream(primaryKey: ['id'])
              .eq('group_id', groupId)
              .order('created_at', ascending: false) // 최신 순으로 정렬
              .listen((data) {
                // 각 샘플에 대해 프로필 정보를 가져오는 로직이 필요하지만, 여기서는 단순화합니다.
                // 실제 앱에서는 Future.wait 등을 사용하여 성능을 최적화해야 합니다.
                controller.add(data);
              });
        } else {
          controller.add([]);
        }
      } catch (e) {
        controller.addError(e);
      }
    }

    fetchSamples();
    return controller.stream;
  }
  
  // 특정 소음 샘플에 대한 댓글 목록을 실시간으로 가져오는 스트림
  Stream<List<Map<String, dynamic>>> getCommentsStream(int noiseSampleId) {
      // comments 테이블에서 noise_sample_id가 일치하는 데이터를 구독합니다.
      // 추가로, 댓글 작성자의 정보(profiles)를 join해서 함께 가져옵니다.
      return _supabase
        .from('comments')
        .stream(primaryKey: ['id'])
        .eq('noise_sample_id', noiseSampleId)
        .order('created_at', ascending: true)
        .map((commentData) {
           // Supabase는 아직 스트림에서 직접 join을 지원하지 않으므로, 수동으로 프로필 정보를 가져와야 합니다.
           // 여기서는 설명을 위해 개념적인 코드를 표현합니다. 실제 구현은 더 복잡할 수 있습니다.
           return commentData; // 우선 댓글 데이터만 반환
        });
  }

  // 새로운 댓글을 추가하는 함수
  Future<void> addComment(int noiseSampleId, String content) async {
    final user = _supabase.auth.currentUser;
    if (user == null || content.trim().isEmpty) return;

    await _supabase.from('comments').insert({
      'noise_sample_id': noiseSampleId,
      'profile_id': user.id,
      'content': content.trim(),
    });
  }

  // TODO: 좋아요 관련 기능 추가 (toggleLike, getLikesStream)
}
