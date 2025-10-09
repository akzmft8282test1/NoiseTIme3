
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:noisetime/models/noise_sample.dart';
import 'package:noisetime/screens/noise_detail_screen.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text("Please log in."));
    }

    return StreamBuilder<DocumentSnapshot>(
      // First, get the user's group_id
      stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
        final groupId = userData?['group_id'];

        if (groupId == null) {
          return const Center(child: Text("You are not in a group yet."));
        }

        // Now, get the noise samples for that group
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('noise_samples')
              .where('group_id', isEqualTo: groupId)
              .orderBy('timestamp', descending: true)
              .limit(50) // Show latest 50 samples
              .snapshots(),
          builder: (context, noiseSnapshot) {
            if (noiseSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!noiseSnapshot.hasData || noiseSnapshot.data!.docs.isEmpty) {
              return const Center(child: Text("No noise data recorded for this group yet."));
            }

            return ListView.builder(
              itemCount: noiseSnapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final doc = noiseSnapshot.data!.docs[index];
                final noiseSample = NoiseSample.fromFirestore(doc);

                return ListTile(
                  title: Text('${noiseSample.anonId} recorded ${noiseSample.decibel.toStringAsFixed(1)} dB'),
                  subtitle: Text(noiseSample.timestamp.toDate().toString()),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NoiseDetailScreen(noiseSample: noiseSample),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
