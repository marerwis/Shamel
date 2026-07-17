import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  RealtimeChannel? _requestsChannel;

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    
    // Request permission for Android 13+
    await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
  }

  void startListeningToRequests(String providerCategoryId) {
    _requestsChannel?.unsubscribe();

    _requestsChannel = Supabase.instance.client
        .channel('public:requests')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'requests',
          callback: (payload) {
            final newRecord = payload.newRecord;
            final status = newRecord['status'];
            final categoryId = newRecord['category_id'];
            
            // If it's a broadcast request and matches the provider's category
            if (status == 'Pending_Broadcast' && categoryId == providerCategoryId) {
              _showNotification(
                title: 'طلب خدمة جديد!',
                body: newRecord['description'] ?? 'يوجد طلب جديد متاح في تخصصك.',
              );
            }
          },
        )
        .subscribe();
  }

  void stopListening() {
    _requestsChannel?.unsubscribe();
  }

  Future<void> _showNotification({required String title, required String body}) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'requests_channel',
      'إشعارات الطلبات',
      channelDescription: 'إشعارات الطلبات الجديدة في تخصصك',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    
    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecond,
      title,
      body,
      platformChannelSpecifics,
    );
  }
}
