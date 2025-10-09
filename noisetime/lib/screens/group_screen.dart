
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GroupScreen extends StatefulWidget {
  const GroupScreen({super.key});

  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _groupNameController = TextEditingController();
  final _emailController = TextEditingController();

  Stream<DocumentSnapshot> _userStream() {
    final user = _auth.currentUser;
    return _firestore.collection('users').doc(user!.uid).snapshots();
  }

  Stream<DocumentSnapshot> _groupStream(String groupId) {
    return _firestore.collection('groups').doc(groupId).snapshots();
  }

  void _createGroup() async {
    if (_groupNameController.text.isEmpty) return;

    final user = _auth.currentUser!;
    final groupRef = await _firestore.collection('groups').add({
      'name': _groupNameController.text,
      'owner_id': user.uid,
      'members': [user.uid],
      'penalty_percentage': 10.0, // 기본 페널티 10%
    });

    await _firestore
        .collection('users')
        .doc(user.uid)
        .update({'group_id': groupRef.id});

    _groupNameController.clear();
    Navigator.of(context).pop();
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
            onPressed: _createGroup,
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showAddMemberDialog(String groupId) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Add Member'),
            content: TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'User Email'),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel')),
              ElevatedButton(
                  onPressed: () => _addMemberByEmail(groupId),
                  child: const Text('Add')),
            ],
          );
        });
  }

  void _addMemberByEmail(String groupId) async {
    if (_emailController.text.isEmpty) return;

    final querySnapshot = await _firestore
        .collection('users')
        .where('email', isEqualTo: _emailController.text)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      // 유저를 찾을 수 없음
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not found with that email.')));
      return;
    }

    final userToAdd = querySnapshot.docs.first;
    await _firestore
        .collection('groups')
        .doc(groupId)
        .update({'members': FieldValue.arrayUnion([userToAdd.id])});
        
    await _firestore
        .collection('users')
        .doc(userToAdd.id)
        .update({'group_id': groupId});

    _emailController.clear();
    Navigator.of(context).pop();
  }
  
  void _removeMember(String groupId, String memberId) async {
     await _firestore.collection('groups').doc(groupId).update({
        'members': FieldValue.arrayRemove([memberId])
    });
    await _firestore.collection('users').doc(memberId).update({
        'group_id': null
    });
  }

  void _updatePenalty(String groupId, double newPenalty) {
    _firestore
        .collection('groups')
        .doc(groupId)
        .update({'penalty_percentage': newPenalty});
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
        stream: _userStream(),
        builder: (context, userSnapshot) {
          if (!userSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final userData = userSnapshot.data!.data() as Map<String, dynamic>;
          final groupId = userData['group_id'];

          if (groupId == null) {
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
                  // TODO: 그룹 참여 기능
                ],
              ),
            );
          }

          return StreamBuilder<DocumentSnapshot>(
            stream: _groupStream(groupId),
            builder: (context, groupSnapshot) {
              if (!groupSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final groupData = groupSnapshot.data!.data() as Map<String, dynamic>;
              final isOwner = groupData['owner_id'] == _auth.currentUser!.uid;

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(groupData['name'],
                        style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Members',
                            style: Theme.of(context).textTheme.titleLarge),
                        if (isOwner)
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () => _showAddMemberDialog(groupId),
                          ),
                      ],
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: groupData['members'].length,
                        itemBuilder: (context, index) {
                            // This would be more robust if we fetch member details
                            final memberId = groupData['members'][index];
                            return ListTile(
                                title: Text(memberId), // Replace with user's name/email
                                trailing: (isOwner && memberId != _auth.currentUser!.uid)
                                    ? IconButton(
                                        icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                                        onPressed: () => _removeMember(groupId, memberId),
                                    )
                                    : null,
                            );
                        },
                      ),
                    ),
                     const SizedBox(height: 24),
                    if(isOwner) ...[
                        Text('Noise Penalty: ${groupData['penalty_percentage'].toStringAsFixed(0)}%', style: Theme.of(context).textTheme.titleLarge),
                        Slider(
                            value: groupData['penalty_percentage'],
                            min: 0,
                            max: 100,
                            divisions: 10,
                            label: groupData['penalty_percentage'].round().toString(),
                            onChanged: (double value) {
                                _updatePenalty(groupId, value);
                            },
                        )
                    ]
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

