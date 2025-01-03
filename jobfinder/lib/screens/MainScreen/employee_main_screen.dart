import 'package:flutter/material.dart';
import 'package:jobfinder/screens/ApplicatedScreen/employee_applicated_screen.dart';

import 'package:jobfinder/screens/HomeScreen/employee_home_screen.dart';

import 'package:jobfinder/screens/ProfileScreen/employee_profile_screen.dart';
import 'package:jobfinder/screens/SaveJobScreen/employee_save_job_screen.dart';

class MainScreen extends StatefulWidget {
  final String userId; // Thêm tham số userId

  MainScreen({required this.userId}); // Yêu cầu tham số userId

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _screens = [
      EmployeeHomeScreen(userId: widget.userId),
      UserApplicationsScreen(userId: widget.userId), // Màn hình ứng tuyển
      BookmarkedJobsScreen(userId: widget.userId), // Màn hình công việc đã lưu
      // MessageListScreen(userId: widget.userId), // Màn hình nhắn tin
      EmployeeProfileScreen(userId: widget.userId), // Màn hình hồ sơ
    ];

    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          currentIndex: _currentIndex,
          onTap: (index) {
            _pageController.animateToPage(
              index,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
          selectedFontSize: 12,
          unselectedFontSize: 12,
          selectedItemColor: Colors.blueAccent,
          unselectedItemColor: Colors.grey,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          items: [
            _buildNavigationBarItem(
              icon: Icons.home,
              label: "Trang chủ",
              isSelected: _currentIndex == 0,
            ),
            _buildNavigationBarItem(
              icon: Icons.work_outline,
              label: "Ứng tuyển",
              isSelected: _currentIndex == 1,
            ),
            _buildNavigationBarItem(
              icon: Icons.bookmark,
              label: "Đã lưu",
              isSelected: _currentIndex == 2,
            ),
            // _buildNavigationBarItem(
            //   icon: Icons.message,
            //   label: "Tin nhắn",
            //   isSelected: _currentIndex == 3,
            // ),
            _buildNavigationBarItem(
              icon: Icons.account_circle,
              label: "Hồ sơ",
              isSelected: _currentIndex == 4,
            ),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavigationBarItem({
    required IconData icon,
    required String label,
    required bool isSelected,
  }) {
    return BottomNavigationBarItem(
      icon: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.blueAccent.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.blueAccent : Colors.grey,
          size: 24,
        ),
      ),
      label: label,
    );
  }
}
