
import 'package:supabase_flutter/supabase_flutter.dart';

class StatisticsService {
  final _supabase = Supabase.instance.client;

  // 일일 소음 통계 데이터를 가져오는 함수
  Future<List<Map<String, dynamic>>> getDailyNoiseStats() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('Authentication required');
    }

    // 1. 현재 사용자의 그룹 ID를 가져옵니다.
    final profile = await _supabase
        .from('profiles')
        .select('group_id')
        .eq('id', user.id)
        .single();

    final groupId = profile['group_id'];
    if (groupId == null) {
      // 사용자가 그룹에 속해있지 않으면 빈 리스트를 반환합니다.
      return [];
    }

    // 2. 위에서 SQL로 생성한 'daily_noise_stats' 뷰(View)를 일반 테이블처럼 조회합니다.
    //   - 그룹 ID가 일치하는 데이터만 가져옵니다.
    //   - 최근 7일간의 데이터만 가져오도록 필터링할 수 있습니다. (여기서는 최근 30일로)
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));

    final response = await _supabase
        .from('daily_noise_stats')
        .select()
        .eq('group_id', groupId)
        .gte('report_day', thirtyDaysAgo.toIso8601String()) // 30일 전보다 큰 날짜
        .order('report_day', ascending: true);
    
    // Supabase는 List<dynamic>을 반환할 수 있으므로, List<Map<String, dynamic>>으로 캐스팅합니다.
    return (response as List).map((item) => item as Map<String, dynamic>).toList();
  }
}
