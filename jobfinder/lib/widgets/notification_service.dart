import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static void initialize() {
    const androidInitializationSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettings =
        InitializationSettings(android: androidInitializationSettings);

    _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        print("Thông báo được nhấn: ${response.payload}");
      },
    );

    // Lắng nghe thông báo foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Thông báo foreground: ${message.notification?.title}");
      showNotification(
        title: message.notification?.title ?? 'Thông báo',
        body: message.notification?.body ?? '',
      );
    });
  }

  static void showNotification({required String title, required String body}) {
    const androidDetails = AndroidNotificationDetails(
      'default_channel', // ID của kênh thông báo
      'Thông báo chung', // Tên kênh
      channelDescription: 'Kênh thông báo chính',
      importance: Importance.max,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    _flutterLocalNotificationsPlugin.show(
      0, // ID của thông báo
      title,
      body,
      notificationDetails,
    );
  }
}
