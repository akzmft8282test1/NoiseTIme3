
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:noisetime/models/noise_sample.dart';
import 'package:noisetime/services/community_service.dart'; // 서비스 임포트

class NoiseDetailScreen extends StatefulWidget {
  final NoiseSample noiseSample;

  const NoiseDetailScreen({super.key, required this.noiseSample});

  @override
  NoiseDetailScreenState createState() => NoiseDetailScreenState();
}

class NoiseDetailScreenState extends State<NoiseDetailScreen> {
  final _commentController = TextEditingController();
  final _communityService = CommunityService(); // 서비스 인스턴스 생성

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('소음 상세 정보'), // 제목 변경
      ),
      body: Column(
        children: [
          // 소음 정보 표시 영역
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('소음 레벨: ${widget.noiseSample.dbLevel.toStringAsFixed(1)} dB',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text('측정 시각: ${DateFormat('yyyy-MM-dd HH:mm').format(widget.noiseSample.timestamp)}'),
                 const SizedBox(height: 20),
                const Divider(),
              ],
            ),
          ),
          // 댓글 목록
          Expanded(
            child: _buildCommentsList(),
          ),
          // 댓글 입력 필드
          _buildCommentInputField(),
        ],
      ),
    );
  }

  // 댓글 목록을 빌드하는 위젯
  Widget _buildCommentsList() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      // 1. CommunityService를 통해 댓글 스트림을 가져옵니다.
      stream: _communityService.getCommentsStream(widget.noiseSample.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
           return Center(child: Text("댓글을 불러오는데 실패했습니다: ${snapshot.error}"));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("가장 먼저 댓글을 남겨보세요!"));
        }

        final comments = snapshot.data!;

        return ListView.builder(
          itemCount: comments.length,
          itemBuilder: (context, index) {
            final comment = comments[index];
            final createdAt = DateTime.parse(comment['created_at']);

            // TODO: 댓글 작성자의 이름을 표시하려면 profiles 테이블과 JOIN해야 합니다.
            // 지금은 임시로 profile_id를 표시합니다.
            return ListTile(
              title: Text(comment['content'] ?? 'Empty comment'),
              subtitle: Text('by: ${comment['profile_id'].toString().substring(0, 8)}...'),
              trailing: Text(
                DateFormat('MM-dd HH:mm').format(createdAt),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            );
          },
        );
      },
    );
  }

  // 댓글 입력 필드를 빌드하는 위젯
  Widget _buildCommentInputField() {
    return Padding(
      padding: EdgeInsets.fromLTRB(8, 8, 8, MediaQuery.of(context).padding.bottom + 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: const InputDecoration(
                hintText: '댓글 남기기...',
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _postComment,
          ),
        ],
      ),
    );
  }

  // 댓글을 게시하는 함수
  void _postComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      // 2. CommunityService를 통해 댓글을 추가합니다.
      await _communityService.addComment(widget.noiseSample.id, content);
      _commentController.clear(); // 입력 필드 초기화
      // 키보드를 내립니다.
      FocusScope.of(context).unfocus(); 
    } catch (e) {
      messenger.showSnackBar(SnackBar(
        content: Text('댓글 작성 실패: ${e.toString()}'),
        backgroundColor: Theme.of(context).colorScheme.error,
      ));
    }
  }
}
