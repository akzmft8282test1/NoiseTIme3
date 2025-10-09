
import 'package:cloud_firestore/cloud_firestore.dart';

class NoiseSample {
  final String id; // Firestore document ID
  final double decibel;
  final Timestamp timestamp;
  final String groupId;
  final String anonId;

  NoiseSample({
    required this.id,
    required this.decibel,
    required this.timestamp,
    required this.groupId,
    required this.anonId,
  });

  factory NoiseSample.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return NoiseSample(
      id: doc.id,
      decibel: (data['decibel'] ?? 0).toDouble(),
      timestamp: data['timestamp'] ?? Timestamp.now(),
      groupId: data['group_id'] ?? '',
      anonId: data['anon_id'] ?? 'anonymous',
    );
  }
}
