import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:jobfinder/screens/StartScreen/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Đảm bảo các plugin được khởi tạo
  await Firebase.initializeApp(); // Khởi tạo Firebase

  // Kiểm tra và bổ sung jobId vào Firestore nếu thiếu
  FirebaseFirestore.instance.collection('jobPosts').get().then((snapshot) {
    for (var doc in snapshot.docs) {
      if (!doc.data().containsKey('jobId')) {
        // Cập nhật jobId vào Firestore
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
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(), // Màn hình bắt đầu
    );
  }
}
