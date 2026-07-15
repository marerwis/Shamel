import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FCMService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final SupabaseClient _supabase = Supabase.instance.client;

  static Future<void> initialize() async {
    // Request permission
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted FCM permission');
      
      // Get the token
      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        await saveTokenToDatabase(token);
      }

      // Listen for token refreshes
      _firebaseMessaging.onTokenRefresh.listen(saveTokenToDatabase);

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Got a message whilst in the foreground!');
        print('Message data: ${message.data}');

        if (message.notification != null) {
          print('Message also contained a notification: ${message.notification}');
          // In a real app, you would show a local notification here using flutter_local_notifications
        }
      });
    }
  }

  static Future<void> saveTokenToDatabase(String token) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId != null) {
      try {
        await _supabase.from('profiles').update({'fcm_token': token}).eq('id', userId);
        print('FCM Token saved to database');
      } catch (e) {
        print('Error saving FCM token: $e');
      }
    }
  }
}
