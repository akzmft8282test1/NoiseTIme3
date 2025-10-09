
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:noisetime/models/noise_sample.dart';

class NoiseDetailScreen extends StatefulWidget {
  final NoiseSample noiseSample;

  const NoiseDetailScreen({super.key, required this.noiseSample});

  @override
  _NoiseDetailScreenState createState() => _NoiseDetailScreenState();
}

class _NoiseDetailScreenState extends State<NoiseDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  final User? currentUser = FirebaseAuth.instance.currentUser;
  late final DocumentReference _sampleRef;

  @override
  void initState() {
    super.initState();
    _sampleRef = FirebaseFirestore.instance.collection('noise_samples').doc(widget.noiseSample.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Details for ${widget.noiseSample.anonId}'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Noise Level: ${widget.noiseSample.decibel.toStringAsFixed(1)} dB', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text('Recorded at: ${widget.noiseSample.timestamp.toDate()}'),
              ],
            ),
          ),
          const Divider(),
          _buildLikesSection(),
          const Divider(),
          Expanded(
            child: _buildCommentsList(),
          ),
          _buildCommentInputField(),
        ],
      ),
    );
  }

  Widget _buildLikesSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: _sampleRef.collection('likes').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || currentUser == null) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite_border),
                SizedBox(width: 8),
                Text('0'),
              ],
            ),
          );
        }

        final likesCount = snapshot.data!.docs.length;
        final isLiked = snapshot.data!.docs.any((doc) => doc.id == currentUser!.uid);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked ? Colors.red : Colors.grey,
                ),
                onPressed: _toggleLike,
              ),
              Text('$likesCount'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCommentsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _sampleRef.collection('comments').orderBy('timestamp', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("Be the first to comment!"));
        }

        return ListView( 
          children: snapshot.data!.docs.map((doc) {
            final commentData = doc.data() as Map<String, dynamic>;
            return ListTile(
              title: Text(commentData['text']),
              subtitle: Text("by ${commentData['anon_id'] ?? 'anon'}"),
              trailing: Text(
                (commentData['timestamp'] as Timestamp).toDate().toString(),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildCommentInputField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: const InputDecoration(
                hintText: 'Add a comment...',
                border: OutlineInputBorder(),
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

  void _postComment() async {
    if (currentUser == null || _commentController.text.trim().isEmpty) return;
    
    // In a real app, you would fetch the user's anon_id from their user profile
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).get();
    final anonId = userDoc.data()?['anon_id'] ?? 'anonymous';

    await _sampleRef.collection('comments').add({
      'text': _commentController.text.trim(),
      'anon_id': anonId,
      'user_id': currentUser!.uid, // Store real UID for potential future use (e.g., moderation)
      'timestamp': Timestamp.now(),
    });

    _commentController.clear();
  }

  void _toggleLike() async {
    if (currentUser == null) return;

    final likeRef = _sampleRef.collection('likes').doc(currentUser!.uid);
    final likeDoc = await likeRef.get();

    if (likeDoc.exists) {
      await likeRef.delete();
    } else {
      await likeRef.set({'liked_at': Timestamp.now()});
    }
  }
}
