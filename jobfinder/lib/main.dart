import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Firebase
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore
import 'package:firebase_messaging/firebase_messaging.dart'; // Firebase Messaging
import 'package:jobfinder/screens/StartScreen/splash_screen.dart';
import 'package:jobfinder/widgets/notification_service.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Xử lý thông báo khi ứng dụng đang ở chế độ nền
  print("Thông báo nền: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Khởi tạo plugin Flutter
  await Firebase.initializeApp(); // Khởi tạo Firebase
  NotificationService.initialize();

  // Xử lý thông báo trong nền
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Kiểm tra và bổ sung jobId vào Firestore nếu thiếu
  FirebaseFirestore.instance.collection('jobPosts').get().then((snapshot) {
    for (var doc in snapshot.docs) {
      if (!doc.data().containsKey('jobId')) {
        FirebaseFirestore.instance
            .collection('jobPosts')
            .doc(doc.id)
            .update({'jobId': doc.id});
      }
    }
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'JobSphere',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SplashScreen(),
    );
  }
}
