
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:noisetime/screens/admin_screen.dart';
import 'package:noisetime/screens/profile_screen.dart';
import 'package:noisetime/services/auth_service.dart';
import 'package:noisetime/services/group_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GroupScreen extends StatefulWidget {
  const GroupScreen({super.key});

  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  final _groupService = GroupService();
  final _authService = AuthService();
  final _supabase = Supabase.instance.client;

  final _groupNameController = TextEditingController();
  final _groupIdController = TextEditingController();

  // 소음 측정 관련 상태 변수 추가
  bool _isRecording = false;
  NoiseReading? _latestReading;
  StreamSubscription<NoiseReading>? _noiseSubscription;
  NoiseMeter? _noiseMeter;

  @override
  void initState() {
    super.initState();
    // 생성자에서 onError를 제거합니다.
    _noiseMeter = NoiseMeter();
  }

  @override
  void dispose() {
    _noiseSubscription?.cancel();
    super.dispose();
  }

  // onData 콜백 함수
  void onData(NoiseReading noiseReading) {
    if (mounted) {
      setState(() {
        _latestReading = noiseReading;
      });
    }
  }
  
  void onError(Object error) {
    print(error.toString());
    _isRecording = false;
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _requestPermission() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw 'Microphone permission not granted';
    }
  }

  void start() async {
    try {
      await _requestPermission();
      // listen 메소드에 onData와 onError 콜백을 전달합니다.
      _noiseSubscription = _noiseMeter?.noise.listen(onData, onError: onError);
      if (mounted) {
        setState(() => _isRecording = true);
      }
    } catch (err) {
      print(err);
    }
  }

  void stop() async {
    try {
      if (_noiseSubscription != null) {
        _noiseSubscription!.cancel();
        _noiseSubscription = null;
      }
      if (mounted) {
        setState(() => _isRecording = false);
      }
    } catch (err) {
      print('stopRecorder error: $err');
    }
  }

  // 데이터 저장 로직 (수정됨)
  Future<void> _saveNoiseData() async {
    if (_latestReading == null) return;

    final meanDecibel = _latestReading!.meanDecibel;
    final messenger = ScaffoldMessenger.of(context);
    
    try {
      final userId = _authService.currentUser?.id;
      if (userId == null) {
        throw Exception('User not logged in.');
      }

      final profileResponse = await _supabase
          .from('profiles')
          .select('group_id')
          .eq('id', userId)
          .single();
      
      final groupId = profileResponse['group_id'] as String?;

      if (groupId == null) {
        throw Exception('User is not in a group.');
      }
      
      // 컬럼명을 db_level로 수정
      await _groupService.saveNoiseSample(groupId, userId, meanDecibel);

      messenger.showSnackBar(
        SnackBar(
          content: Text('Saved noise level: ${meanDecibel.toStringAsFixed(2)} dB'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Failed to save noise data: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }


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
                if (mounted) navigator.pop();
              } catch (e) {
                if (mounted) {
                  messenger.showSnackBar(SnackBar(
                    content: Text('Failed to create group: ${e.toString()}'),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ));
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

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
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.admin_panel_settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AdminScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.signOut();
            },
          )
        ],
      ),
      body: StreamBuilder<Map<String, dynamic>?>(
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

          if (groupId == null) {
            return _buildNoGroupView();
          }

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
       // 측정/저장 플로팅 버튼 추가
      floatingActionButton: _isRecording
        ? FloatingActionButton.extended(
            onPressed: () {
              stop();
              _saveNoiseData();
            },
            label: const Text('Stop & Save'),
            icon: const Icon(Icons.stop),
            backgroundColor: Colors.red,
          )
        : FloatingActionButton(
            onPressed: start,
            child: const Icon(Icons.mic),
        ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

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
            onPressed: _showJoinGroupDialog,
            child: const Text('Join a Group'),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupDetailsView(Map<String, dynamic> groupData) {
    final isOwner = groupData['owner_id'] == Supabase.instance.client.auth.currentUser!.id;
    final noiseLevel = _latestReading?.meanDecibel ?? 0.0;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(groupData['name'] as String, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 24),
          Text('Group ID: ${groupData['id']}', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 32),
          
          // 소음 측정 UI
          Expanded(
            child: Center(
              child: NoiseGraph(noiseLevel: noiseLevel),
            ),
          ),
          
          const SizedBox(height: 32),
          if(isOwner) ...[
              Text('Noise Penalty: ...%', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 80), // 여백 추가
          ]
        ],
      ),
    );
  }
}


// 소음 레벨을 보여주는 원형 그래프 위젯
class NoiseGraph extends StatelessWidget {
  final double noiseLevel;
  const NoiseGraph({super.key, required this.noiseLevel});

  @override
  Widget build(BuildContext context) {
    // 0-120 dB 범위를 0-100으로 정규화
    final normalizedValue = (noiseLevel.clamp(0, 120) / 120) * 100;
    
    return SizedBox(
      width: 250,
      height: 250,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 배경 원
          SizedBox(
            width: 250,
            height: 250,
            child: CircularProgressIndicator(
              value: 1,
              strokeWidth: 20,
              color: Colors.grey.shade300,
            ),
          ),
          // 소음 레벨 원
          SizedBox(
            width: 250,
            height: 250,
            child: CircularProgressIndicator(
              value: normalizedValue / 100,
              strokeWidth: 20,
              valueColor: AlwaysStoppedAnimation<Color>(
                // 소음 레벨에 따라 색상 변경
                normalizedValue > 70 ? Colors.red :
                normalizedValue > 40 ? Colors.orange :
                Colors.green
              ),
            ),
          ),
          // 데시벨 텍스트
          Text(
            '${noiseLevel.toStringAsFixed(1)} dB',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
        ],
      ),
    );
  }
}
