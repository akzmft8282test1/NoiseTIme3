
import 'package:flutter/material.dart';
import 'package:noisetime/services/auth_service.dart';
import 'package:noisetime/services/group_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _groupService = GroupService();
  final _authService = AuthService();

  Future<void> _leaveGroup(String groupId) async {
    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Group?'),
        content: const Text('Are you sure you want to leave this group?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Leave')),
        ],
      ),
    );

    if (shouldLeave == true) {
      try {
        await _groupService.leaveGroup(groupId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Successfully left the group.'), backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to leave group: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: StreamBuilder<Map<String, dynamic>?>(
        stream: _groupService.getProfileStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Could not load profile.'));
          }

          final profile = snapshot.data!;
          final user = Supabase.instance.client.auth.currentUser;
          final groupId = profile['group_id'];

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              ListTile(
                leading: const Icon(Icons.email),
                title: const Text('Email'),
                subtitle: Text(user?.email ?? 'Not logged in'),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.group),
                title: const Text('Group ID'),
                subtitle: Text(groupId ?? 'Not in a group'),
                trailing: groupId != null
                    ? ElevatedButton(
                        onPressed: () => _leaveGroup(groupId),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        child: const Text('Leave'),
                      )
                    : null,
              ),
              const Divider(),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text('Sign Out'),
                onPressed: () async {
                  await _authService.signOut();
                  // AuthGate will handle navigation
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
