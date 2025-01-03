import 'package:flutter/material.dart';
import 'package:jobfinder/screens/LoginScreen/login_screen.dart';
 // Màn hình tiếp theo

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() async {
    // Thời gian chờ (3 giây)
    await Future.delayed(const Duration(seconds: 3));
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()), // Chuyển tới màn hình Login
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent, // Màu nền xanh nước biển
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo hoặc Tên ứng dụng
            Text(
              "JobSphere", // Tên ứng dụng
              style: TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.bold,
                fontFamily: 'Roboto', // Font hiện đại
              ),
            ),
            const SizedBox(height: 20),
            // Hiệu ứng tải (Progress Indicator)
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}