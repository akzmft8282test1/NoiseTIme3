
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> initialize() async {
    // 1. Request Permission (iOS & Android 13+)
    await _firebaseMessaging.requestPermission();

    // 2. Get FCM Token
    final fcmToken = await _firebaseMessaging.getToken();
    print("FCM Token: $fcmToken");

    // 3. Save FCM Token to Firestore
    if (fcmToken != null) {
      await saveTokenToFirestore(fcmToken);
    }

    // 4. Listen for token refresh
    _firebaseMessaging.onTokenRefresh.listen(saveTokenToFirestore);

    // 5. Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
        // Here, you could display a local notification using a package like flutter_local_notifications
      }
    });
  }

  Future<void> saveTokenToFirestore(String token) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final tokensRef = _firestore.collection('users').doc(user.uid);

    await tokensRef.update({
      'fcm_token': token,
    });
  }
}
