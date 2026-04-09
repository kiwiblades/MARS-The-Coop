import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:frontend/services/api_client.dart';
import 'package:frontend/services/socket_client.dart';

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
  final _socket = SocketClient.instance;

  late ApiClient _api;

  bool _fcmInitialized = false;
  bool _socketInitialized = false;

  Future<void> initializeFcm(ApiClient api) async {
    if (_fcmInitialized) return;
    _fcmInitialized = true;
    _api = api;

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
    
    // listen for token refresh
    _messaging.onTokenRefresh.listen((token) {
      _sendTokenToServer(token);
    });

    // foreground msgs don't show by default on android, so it must be handled manually
    FirebaseMessaging.onMessage.listen((message) {
      _showLocalNotification(message);
    });
  }

  // called in _connectIfNeeded in main.dart after socket.connect() completes
  // socket is guaranteed to be connected at that point: just prevents use before ready
  void initializeSocket() {
    if (_socketInitialized) return;
    _socketInitialized = true;
    print('[NotificationService] socket listeners ready');
  }

  Future<void> saveToken() async {
    final token = await _messaging.getToken();
    if (token != null) {
      await _sendTokenToServer(token);
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

  // --- REST

  Future<void> _sendTokenToServer(String token) async {
    try {
      await _api.postJson('/notifications/fcm-token', {'fcmToken' : token});
      print('[NotificationService] token saved to server');
    } catch(e) {
      print('[NotificationService] failed to save token: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getNotificationSummary() async {
    try {
      final data = await _api.getJson('/notifications/summary');
      final summary = data['memberships'] as List<dynamic>;
      return summary.map((m) => m as Map<String, dynamic>).toList();
    } catch(e) {
      print('[NotificationService] getNotificationSummary failed: $e');
      return []; // return empty list
    }
  }

  // --- socket

  void markChatRead({required String chatId, required String userId}) {
    _socket.emit('mark_chat_read', {
      'chatId': chatId,
      'userId': userId,
    });
  }

  Stream<String> onChatMarkedRead() {
    return _socket.on('chat_marked_read').map((data) => data['chatId'] as String);
  }

  Stream<Map<String, dynamic>> onUnreadCountUpdate() {
    return _socket.on('unread_count_update');
  }

  Stream<Map<String, dynamic>> onPendingQuestionUpdate() {
    return _socket.on('pending_question_update');
  }

  Stream<Map<String, dynamic>> onChatUpdated() {
    return _socket.on('chat_updated');
  }

  Stream<String> onError() {
    return _socket.on('notification_error').map((data) => data['message'] as String);
  }
}