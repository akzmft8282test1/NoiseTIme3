
import 'package:flutter/material.dart';
import 'package:noisetime/services/auth_service.dart';
import 'package:noisetime/services/group_service.dart'; // 새로 만든 GroupService를 가져옵니다.
import 'package:supabase_flutter/supabase_flutter.dart'; // Supabase Client 접근을 위해 추가

class GroupScreen extends StatefulWidget {
  const GroupScreen({super.key});

  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  // 서비스들을 초기화합니다.
  final _groupService = GroupService();
  final _authService = AuthService(); // 로그아웃을 위해 필요
  
  // 다이얼로그에서 사용할 컨트롤러
  final _groupNameController = TextEditingController();
  final _groupIdController = TextEditingController();

  // 그룹 생성 다이얼로그를 보여주는 함수
  void _showCreateGroupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Group'),
        content: TextField(
          controller: _groupNameController,
          decoration: const InputDecoration(labelText: 'Group Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_groupNameController.text.isEmpty) return;
              
              final messenger = ScaffoldMessenger.of(context);
              final navigator = Navigator.of(context);

              try {
                await _groupService.createGroup(_groupNameController.text);
                _groupNameController.clear();
                navigator.pop(); // 성공 시 다이얼로그 닫기
              } catch (e) {
                messenger.showSnackBar(SnackBar(
                  content: Text('Failed to create group: ${e.toString()}'),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ));
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  // 그룹 가입 다이얼로그 (아직 기능 구현 안됨)
  void _showJoinGroupDialog() {
     showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Join Group'),
        content: TextField(
          controller: _groupIdController,
          decoration: const InputDecoration(labelText: 'Group ID'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
               // TODO: 그룹 가입 로직 구현
               ScaffoldMessenger.of(context).showSnackBar(
                 const SnackBar(content: Text('This feature is not yet implemented.')),
               );
            },
            child: const Text('Join'),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Group'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.signOut();
              // AuthGate가 상태를 감지하여 자동으로 로그인 화면으로 보냅니다.
            },
          )
        ],
      ),
      body: StreamBuilder<Map<String, dynamic>?>(
        // 1. GroupService를 통해 현재 유저의 프로필 정보를 실시간으로 받습니다.
        stream: _groupService.getProfileStream(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!userSnapshot.hasData || userSnapshot.data == null) {
            return const Center(child: Text('Could not load profile.'));
          }

          final userData = userSnapshot.data!;
          final groupId = userData['group_id'];

          // 2. 프로필에 group_id가 없는 경우, 그룹 생성/참여 화면을 보여줍니다.
          if (groupId == null) {
            return _buildNoGroupView();
          }

          // 3. group_id가 있는 경우, 해당 그룹 정보를 스트림으로 받아와 화면을 구성합니다.
          return StreamBuilder<Map<String, dynamic>?>(
            stream: _groupService.getGroupStream(groupId as String),
            builder: (context, groupSnapshot) {
              if (groupSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!groupSnapshot.hasData || groupSnapshot.data == null) {
                return const Center(child: Text('Group not found.'));
              }
              
              final groupData = groupSnapshot.data!;
              return _buildGroupDetailsView(groupData);
            },
          );
        },
      ),
    );
  }

  // 그룹이 없을 때 보여줄 위젯
  Widget _buildNoGroupView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('You are not in a group.'),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _showCreateGroupDialog,
            child: const Text('Create a Group'),
          ),
          const SizedBox(height: 8),
          const Text('or'),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _showJoinGroupDialog, // 가입 기능은 아직 미구현
            child: const Text('Join a Group'),
          ),
        ],
      ),
    );
  }

  // 그룹 상세 정보를 보여줄 위젯
  Widget _buildGroupDetailsView(Map<String, dynamic> groupData) {
    final isOwner = groupData['owner_id'] == Supabase.instance.client.auth.currentUser!.id;
    
    // TODO: 멤버 목록을 별도의 쿼리로 가져와야 합니다.
    // 현재는 임시로 그룹 이름과 소유자 여부만 표시합니다.
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(groupData['name'] as String, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 24),
          Text('Group ID: ${groupData['id']}', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 24),
          Text('Members', style: Theme.of(context).textTheme.titleLarge),
          const Expanded(
            child: Center(
              child: Text('(Member list will be shown here)'), // 임시 텍스트
            )
          ),
          if(isOwner) ...[
              Text('Noise Penalty: ...%', style: Theme.of(context).textTheme.titleLarge),
              // TODO: 페널티 설정 슬라이더 구현
          ]
        ],
      ),
    );
  }
}
