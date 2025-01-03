import 'package:flutter/material.dart';
import 'package:jobfinder/screens/ApplyCVScreen/recruiter_cv_screen.dart';
import 'package:jobfinder/screens/CreateJobScreen/create_job_post_screen.dart';
import 'package:jobfinder/screens/HomeScreen/recruiter_home_screen.dart';
import 'package:jobfinder/screens/ProfileScreen/recuiter_profile_screen.dart';

class RecruiterMainScreen extends StatefulWidget {
  final String userId;

  RecruiterMainScreen({required this.userId});

  @override
  _RecruiterMainScreenState createState() => _RecruiterMainScreenState();
}

class _RecruiterMainScreenState extends State<RecruiterMainScreen> {
  int _selectedIndex = 0;

  void _navigateToCreateJobPost(BuildContext context) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateJobPostScreen(
          onSaveJobPost: (jobPost) {
            setState(() {}); // Gọi setState để refresh giao diện
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _screens = [
      RecruiterHomeScreen(),
      CreateJobPostScreen(onSaveJobPost: (jobPost) {}),
      CvApprovalScreen(userId: widget.userId), // Màn hình duyệt CV
      RecruiterProfileScreen(userId: widget.userId),
    ];

    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Trang chủ"),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: "Đăng tin"),
          BottomNavigationBarItem(
              icon: Icon(Icons.assignment),
              label: "Duyệt CV"), // Thêm mục Duyệt CV
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Hồ sơ"),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
