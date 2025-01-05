import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jobfinder/screens/ApplyCVScreen/upload_cv_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jobfinder/screens/LoginScreen/login_screen.dart';

class JobDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> jobData;

  JobDetailsScreen({required this.jobData});

  @override
  Widget build(BuildContext context) {
    print('Dữ liệu công việc được truyền vào: $jobData');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          jobData['title'] ?? 'Chi tiết công việc',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderSection(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader("Thông tin công việc"),
                  _buildInfoRow(FontAwesomeIcons.suitcase, "Cấp bậc",
                      jobData['jobLevel'] ?? 'Không xác định'),
                  _buildInfoRow(FontAwesomeIcons.users, "Số lượng tuyển dụng",
                      jobData['vacancies']?.toString() ?? 'Không xác định'),
                  _buildInfoRow(FontAwesomeIcons.venusMars, "Yêu cầu giới tính",
                      jobData['genderRequirement'] ?? 'Không yêu cầu'),
                  Divider(color: Colors.grey),
                  _buildSectionHeader("Mô tả công việc"),
                  Text(
                    jobData['jobDescription'] ?? 'Không có mô tả',
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  SizedBox(height: 16),
                  _buildSectionHeader("Yêu cầu ứng viên"),
                  ..._buildCandidateRequirements(),
                  SizedBox(height: 16),
                  _buildSectionHeader("Quyền lợi"),
                  ..._buildBenefits(),
                  SizedBox(height: 16),
                  _buildSectionHeader("Hạn nộp hồ sơ"),
                  _buildInfoRow(
                    FontAwesomeIcons.calendarDay,
                    "Hạn nộp",
                    _getFormattedDeadline(jobData['applicationDeadline']),
                  ),
                  _buildInfoRow(
                    FontAwesomeIcons.mapMarkerAlt,
                    "Địa chỉ chi tiết",
                    jobData['detailedAddress'] ?? 'Không xác định',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      color: Colors.blueAccent,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        children: [
          if (jobData['logoUrl'] != null && jobData['logoUrl'].isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                jobData['logoUrl'],
                width: 150,
                height: 150,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    FontAwesomeIcons.circleExclamation,
                    size: 50,
                    color: Colors.grey,
                  ),
                ),
              ),
            )
          else
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  'No Logo',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          SizedBox(height: 16),
          Text(
            jobData['title'] ?? 'Không có tiêu đề',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            jobData['companyName'] ?? 'Không có công ty',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildIconInfoWithDetails(
                icon: FontAwesomeIcons.dollarSign,
                title: "Mức lương",
                value: jobData['salaryRange'] ?? 'Không xác định',
              ),
              _buildIconInfoWithDetails(
                icon: FontAwesomeIcons.locationDot,
                title: "Địa điểm",
                value: jobData['workLocation'] ?? 'Không xác định',
              ),
              _buildIconInfoWithDetails(
                icon: FontAwesomeIcons.briefcase,
                title: "Kinh nghiệm",
                value: jobData['requiredExperience'] ?? 'Không xác định',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              // Thực hiện chức năng lưu công việc
            },
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blueAccent, width: 2),
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                FontAwesomeIcons.bookmark,
                color: Colors.blueAccent,
                size: 28,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              // Kiểm tra nếu jobId không tồn tại hoặc trống
              if (jobData['jobId'] == null || jobData['jobId'].isEmpty) {
                print(
                    'Lỗi: jobId không tồn tại hoặc trống. jobData = $jobData');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Dữ liệu công việc không hợp lệ. Vui lòng thử lại.'),
                  ),
                );
                Navigator.pop(context); // Quay lại màn hình trước đó
                return;
              }

              final user = FirebaseAuth.instance.currentUser;
              if (user == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Vui lòng đăng nhập để ứng tuyển.')),
                );
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
                return;
              }

              final userDoc = await FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .get();
              final userRole = userDoc.data()?['role'] ?? 'guest';

              if (userRole == 'guest') {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Vui lòng đăng nhập bằng tài khoản hợp lệ để ứng tuyển.',
                    ),
                  ),
                );
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
                return;
              }

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UploadCVScreen(
                    jobId: jobData['jobId'],
                    userId: user.uid,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 100),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              "Ứng tuyển ngay",
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconInfoWithDetails({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Colors.white),
        SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.blueAccent),
          SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87),
          ),
          SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              overflow: TextOverflow.visible,
              maxLines: null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.blueAccent,
        ),
      ),
    );
  }

  List<Widget> _buildCandidateRequirements() {
    final requirements = jobData['candidateRequirements'] as List<dynamic>?;
    if (requirements == null || requirements.isEmpty) {
      return [
        Text(
          'Không có yêu cầu nào.',
          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
        ),
      ];
    }
    return requirements.map((e) {
      if (e is String) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Icon(FontAwesomeIcons.checkCircle, size: 16, color: Colors.green),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  e,
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ),
            ],
          ),
        );
      }
      return SizedBox();
    }).toList();
  }

  List<Widget> _buildBenefits() {
    final benefits = jobData['benefits'] as List<dynamic>?;
    if (benefits == null || benefits.isEmpty) {
      return [
        Text(
          'Không có quyền lợi nào.',
          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
        ),
      ];
    }
    return benefits.map((e) {
      if (e is String) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Icon(FontAwesomeIcons.gift, size: 16, color: Colors.orange),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  e,
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ),
            ],
          ),
        );
      }
      return SizedBox();
    }).toList();
  }

  String _getFormattedDeadline(dynamic deadline) {
    DateTime? parsedDeadline;
    if (deadline is Timestamp) {
      parsedDeadline = deadline.toDate();
    } else if (deadline is String) {
      try {
        parsedDeadline = DateFormat('dd/MM/yyyy').parse(deadline);
      } catch (e) {
        parsedDeadline = null;
      }
    }
    return parsedDeadline != null
        ? DateFormat('dd/MM/yyyy').format(parsedDeadline)
        : 'Không xác định';
  }
}
