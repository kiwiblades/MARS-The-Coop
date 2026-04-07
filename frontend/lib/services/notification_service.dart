import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:frontend/services/api_client.dart';

// handles background messages
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('[NotificationService] background message: ${message.messageId}');
}

class NotificationService {
  static final NotificationService instance = NotificationService._internal();
  NotificationService._internal();

  final _messaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize(ApiClient api) async {
    // register background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // request permission to send notifs
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    print('[NotificationService] permission: ${settings.authorizationStatus}');

    // set up local notifs for foreground display
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _localNotifications.initialize(
      settings: const InitializationSettings(android: androidSettings),
    );

    // create notifications channel
    const channel = AndroidNotificationChannel(
      'default_channel',
      'General Notifications',
      importance: Importance.high,
    );
    await _localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

    // get token and save to server
    await _saveToken(api);
    
    // listen for token refresh
    _messaging.onTokenRefresh.listen((token) {
      _sendTokenToServer(api, token);
    });

    // foreground msgs don't show by default on android, so it must be handled manually
    FirebaseMessaging.onMessage.listen((message) {
      _showLocalNotification(message);
    });
  }

  Future<void> _saveToken(ApiClient api) async {
    final token = await _messaging.getToken();
    if (token != null) {
      await _sendTokenToServer(api, token);
    }
  }

  Future<void> _sendTokenToServer(ApiClient api, String token) async {
    try {
      await api.postJson('users/fcm-token', {'fcmToken' : token});
      print('[NotificationService] token saved to server');
    } catch(e) {
      print('[NotificationService] failed to save token: $e');
    }
  }

  void _showLocalNotification(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _localNotifications.show(
      id: notification.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails:  NotificationDetails(
        android: AndroidNotificationDetails(
          'default_channel',
          'General Notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }
}