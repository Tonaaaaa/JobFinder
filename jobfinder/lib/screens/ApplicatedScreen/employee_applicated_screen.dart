import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

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

                // Nhóm các ứng tuyển theo jobId
                final groupedApplications =
                    _groupApplicationsByJobId(applications);

                return ListView.builder(
                  itemCount: groupedApplications.length,
                  itemBuilder: (context, index) {
                    final applicationGroup = groupedApplications[index];
                    final jobId = applicationGroup.first['jobId'];

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

                        if (!jobSnapshot.hasData ||
                            jobSnapshot.data == null ||
                            !jobSnapshot.data!.exists) {
                          return _buildErrorCard(
                              'Công việc bạn đã ứng tuyển có thể đã bị xoá bài viết.');
                        }

                        final jobData =
                            jobSnapshot.data!.data() as Map<String, dynamic>;

                        // Lấy trạng thái gần nhất
                        final latestApplication = applicationGroup.first;
                        final latestStatus =
                            latestApplication['status'] ?? 'Không rõ';
                        final submittedAt =
                            (latestApplication['submittedAt'] as Timestamp)
                                .toDate();

                        // Kiểm tra tìm kiếm
                        if (_searchQuery.isNotEmpty &&
                            !_matchesSearchQuery(jobData, _searchQuery)) {
                          return SizedBox.shrink();
                        }

                        return _buildJobCard(
                          context: context,
                          jobData: jobData,
                          latestStatus: latestStatus,
                          submittedAt: submittedAt,
                          allApplications: applicationGroup,
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

  List<List<DocumentSnapshot>> _groupApplicationsByJobId(
      List<DocumentSnapshot> applications) {
    final Map<String, List<DocumentSnapshot>> groupedMap = {};

    for (var application in applications) {
      final jobId = application['jobId'];
      if (!groupedMap.containsKey(jobId)) {
        groupedMap[jobId] = [];
      }
      groupedMap[jobId]!.add(application);
    }

    return groupedMap.values.toList();
  }

  bool _matchesSearchQuery(Map<String, dynamic> jobData, String query) {
    final companyName =
        (jobData['companyName'] as String?)?.toLowerCase() ?? '';
    final title = (jobData['title'] as String?)?.toLowerCase() ?? '';
    return companyName.contains(query.toLowerCase()) ||
        title.contains(query.toLowerCase());
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 30,
            ),
            SizedBox(height: 8),
            Text(
              errorMessage,
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobCard({
    required BuildContext context,
    required Map<String, dynamic> jobData,
    required String latestStatus,
    required DateTime submittedAt,
    required List<DocumentSnapshot> allApplications,
  }) {
    final title = jobData['title'] ?? 'Không có tiêu đề';
    final companyName = jobData['companyName'] ?? 'Không rõ';
    final salaryRange = jobData['salaryRange'] ?? 'Thỏa thuận';
    final workLocation = jobData['workLocation'] ?? 'Không rõ';

    // Trạng thái chính
    String statusMessage = '';
    Color statusColor = Colors.orange;

    if (latestStatus == 'đã duyệt') {
      statusMessage = 'Chúc mừng! Hồ sơ của bạn đã được duyệt!';
      statusColor = Colors.green;
    } else if (latestStatus == 'từ chối') {
      statusMessage = 'Hồ sơ của bạn chưa phù hợp.';
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
            Text(
              statusMessage,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
            SizedBox(height: 8),
            // Hiển thị thêm nút xem lịch sử trạng thái
            ExpansionTile(
              title: Text(
                "Xem lịch sử ứng tuyển",
                style: TextStyle(fontSize: 14, color: Colors.blueAccent),
              ),
              children: allApplications.map((application) {
                final status = application['status'] ?? 'Không rõ';
                final appliedAt =
                    (application['submittedAt'] as Timestamp).toDate();

                // Xác định màu sắc cho từng trạng thái
                Color statusColor;
                switch (status.toLowerCase()) {
                  case 'đã duyệt':
                    statusColor = Colors.green; // Xanh lá cây
                    break;
                  case 'từ chối':
                    statusColor = Colors.red; // Đỏ
                    break;
                  case 'đang chờ':
                    statusColor = Colors.orange; // Cam
                    break;
                  case 'hết hạn':
                    statusColor = Colors.grey; // Xám
                    break;
                  default:
                    statusColor = Colors.blueAccent; // Màu xanh dương
                }

                return ListTile(
                  title: Text(
                    'Ngày ứng tuyển: ${DateFormat('dd/MM/yyyy').format(appliedAt)}',
                  ),
                  subtitle: Text(
                    'Trạng thái: $status',
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
