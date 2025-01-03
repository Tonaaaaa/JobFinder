import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:jobfinder/screens/DetailScreen/detail_job_screen.dart';

class UserApplicationsScreen extends StatefulWidget {
  final String userId;

  UserApplicationsScreen({required this.userId});

  @override
  _UserApplicationsScreenState createState() => _UserApplicationsScreenState();
}

class _UserApplicationsScreenState extends State<UserApplicationsScreen> {
  String _searchQuery = ''; // Biến tìm kiếm

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Công việc đã ứng tuyển',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('jobApplications')
                  .where('userId', isEqualTo: widget.userId)
                  .orderBy('submittedAt',
                      descending: true) // Hiển thị mới nhất trước
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Đã xảy ra lỗi khi tải dữ liệu.',
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      'Bạn chưa ứng tuyển công việc nào.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                final applications = snapshot.data!.docs.toList();

                if (applications.isEmpty) {
                  return Center(
                    child: Text(
                      'Không tìm thấy công việc nào khớp với tìm kiếm.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: applications.length,
                  itemBuilder: (context, index) {
                    final application = applications[index];
                    final jobId = application['jobId'];
                    final submittedAt =
                        (application['submittedAt'] as Timestamp).toDate();

                    if (jobId == null || jobId.isEmpty) {
                      return SizedBox.shrink();
                    }

                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('jobPosts')
                          .doc(jobId)
                          .get(),
                      builder: (context, jobSnapshot) {
                        if (jobSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return _buildLoadingCard();
                        }

                        if (jobSnapshot.hasError) {
                          return SizedBox.shrink();
                        }

                        if (!jobSnapshot.hasData ||
                            jobSnapshot.data == null ||
                            !jobSnapshot.data!.exists) {
                          return _buildErrorCard(
                              'Công việc không tồn tại: $jobId');
                        }

                        final jobData =
                            jobSnapshot.data!.data() as Map<String, dynamic>?;

                        if (jobData == null) {
                          return _buildErrorCard(
                              'Dữ liệu công việc không hợp lệ: $jobId');
                        }

                        final companyName =
                            jobData['companyName']?.toString().toLowerCase() ??
                                '';
                        final title =
                            jobData['title']?.toString().toLowerCase() ?? '';

                        // Kiểm tra tìm kiếm
                        if (_searchQuery.isNotEmpty &&
                            !companyName.contains(_searchQuery.toLowerCase()) &&
                            !title.contains(_searchQuery.toLowerCase())) {
                          return SizedBox
                              .shrink(); // Ẩn nếu không khớp với tìm kiếm
                        }

                        final status = application['status'] ?? 'Không rõ';

                        return _buildJobCard(
                          context: context,
                          jobData: jobData,
                          submittedAt: submittedAt,
                          status: status,
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.all(12.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Tìm kiếm công việc...',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorCard(String errorMessage) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          errorMessage,
          style: TextStyle(fontSize: 14, color: Colors.red),
        ),
      ),
    );
  }

  Widget _buildJobCard({
    required BuildContext context,
    required Map<String, dynamic> jobData,
    required DateTime submittedAt,
    required String status,
  }) {
    final title = jobData['title'] ?? 'Không có tiêu đề';
    final companyName = jobData['companyName'] ?? 'Không rõ';
    final salaryRange = jobData['salaryRange'] ?? 'Thỏa thuận';
    final workLocation = jobData['workLocation'] ?? 'Không rõ';

    // Nội dung trạng thái tùy chỉnh
    String statusMessage = '';
    Color statusColor = Colors.orange;

    if (status == 'đã duyệt') {
      statusMessage =
          'Chúc mừng! Hồ sơ của bạn đã được duyệt ! nhà tuyển dụng sẽ sớm liên hệ với bạn qua email!';
      statusColor = Colors.green;
    } else if (status == 'từ chối') {
      statusMessage = 'Cảm ơn bạn đã ứng tuyển. Hồ sơ của bạn chưa phù hợp.';
      statusColor = Colors.red;
    } else {
      statusMessage = 'Hồ sơ của bạn đang chờ duyệt.';
    }

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                jobData['logoUrl'] != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          jobData['logoUrl'],
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.error,
                            color: Colors.red,
                          ),
                        ),
                      )
                    : Icon(Icons.business, size: 60, color: Colors.grey),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text('Công ty: $companyName'),
                      Text('Mức lương: $salaryRange'),
                      Text('Địa điểm: $workLocation'),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              'Ngày ứng tuyển: ${DateFormat('dd/MM/yyyy').format(submittedAt)}',
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            SizedBox(height: 8),
            Text(
              statusMessage,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
