
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> initialize() async {
    // 1. Request Permission (iOS & Android 13+)
    await _firebaseMessaging.requestPermission();

    // 2. Get FCM Token
    final fcmToken = await _firebaseMessaging.getToken();
    debugPrint("FCM Token: $fcmToken");

    // 3. Save FCM Token to Database
    if (fcmToken != null) {
      await saveTokenToDatabase(fcmToken);
    }

    // 4. Listen for token refresh
    _firebaseMessaging.onTokenRefresh.listen(saveTokenToDatabase);

    // 5. Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground!');
      debugPrint('Message data: ${message.data}');

      if (message.notification != null) {
        debugPrint('Message also contained a notification: ${message.notification}');
        // Here, you could display a local notification using a package like flutter_local_notifications
      }
    });
  }

  Future<void> saveTokenToDatabase(String token) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      await _supabase
          .from('users')
          .update({'fcm_token': token})
          .eq('id', user.id);
    } catch (e) {
      debugPrint('Error saving FCM token: $e');
    }
  }
}
