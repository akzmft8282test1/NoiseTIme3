
// import 'package:cloud_firestore/cloud_firestore.dart'; // 더 이상 필요 없음

class NoiseSample {
  final int id;         // Supabase의 Primary Key (int)
  final double dbLevel;   // 데시벨 값
  final DateTime timestamp; // 생성 시각
  final String profileId; // 작성자 UUID
  final int groupId;    // 그룹 ID

  // 좋아요, 댓글 수 등 추가 정보 (필요 시 확장)
  // final String authorName; 

  NoiseSample({
    required this.id,
    required this.dbLevel,
    required this.timestamp,
    required this.profileId,
    required this.groupId,
    // required this.authorName,
  });

  // Supabase에서 받은 Map 데이터로부터 NoiseSample 객체를 생성하는 팩토리 생성자
  factory NoiseSample.fromSupabase(Map<String, dynamic> data) {
    return NoiseSample(
      id: data['id'] ?? 0,
      dbLevel: (data['db_level'] ?? 0.0).toDouble(),
      // Supabase는 타임스탬프를 ISO 8601 형식의 문자열로 반환
      timestamp: DateTime.parse(data['created_at'] ?? DateTime.now().toIso8601String()),
      profileId: data['profile_id'] ?? '',
      groupId: data['group_id'] ?? 0,
      // authorName: data['profiles']?['name'] ?? 'Unknown', // JOIN 사용 시
    );
  }
}
