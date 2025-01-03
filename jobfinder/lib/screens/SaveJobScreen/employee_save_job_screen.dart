import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jobfinder/screens/DetailScreen/detail_job_screen.dart';

class BookmarkedJobsScreen extends StatefulWidget {
  final String userId;

  BookmarkedJobsScreen({required this.userId});

  @override
  _BookmarkedJobsScreenState createState() => _BookmarkedJobsScreenState();
}

class _BookmarkedJobsScreenState extends State<BookmarkedJobsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Công việc đã lưu',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookmarks')
            .doc(widget.userId)
            .collection('jobs')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bookmark_border,
                    size: 120,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Không có công việc nào đã lưu!',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          final bookmarkedJobs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: bookmarkedJobs.length,
            padding: EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final jobDoc = bookmarkedJobs[index];
              final jobData = jobDoc.data() as Map<String, dynamic>;
              final jobId = jobDoc.id;

              return GestureDetector(
                onTap: () async {
                  // Truy vấn dữ liệu đầy đủ từ jobPosts
                  final jobDoc = await FirebaseFirestore.instance
                      .collection('jobPosts')
                      .doc(jobId)
                      .get();

                  if (jobDoc.exists) {
                    final fullJobData = jobDoc.data() as Map<String, dynamic>;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => JobDetailsScreen(
                          jobData: fullJobData,
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Công việc không tồn tại.')),
                    );
                  }
                },
                child: _buildEnhancedJobCard(
                  jobId: jobId,
                  title: jobData['title'] ?? 'Không có tiêu đề',
                  companyName: jobData['companyName'] ?? 'Không rõ công ty',
                  workLocation: jobData['workLocation'] ?? 'Không xác định',
                  employmentType: jobData['employmentType'] ?? 'Không xác định',
                  salaryRange: jobData['salaryRange'] ?? 'Không xác định',
                  applicationDeadline:
                      jobData['applicationDeadline'] ?? 'Không xác định',
                  logoUrl:
                      jobData['logoUrl'], // Đảm bảo sử dụng đúng trường logoUrl
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEnhancedJobCard({
    required String jobId,
    required String title,
    required String companyName,
    required String workLocation,
    required String employmentType,
    required String salaryRange,
    required String applicationDeadline,
    String? logoUrl,
  }) {
    return Card(
      color: Colors.white,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.blueAccent),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                logoUrl != null && logoUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          logoUrl,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            print('Error loading image: $error');
                            return Icon(Icons.broken_image, color: Colors.grey);
                          },
                        ),
                      )
                    : CircleAvatar(
                        backgroundColor: Colors.blueAccent.withOpacity(0.2),
                        radius: 30,
                        child: Icon(Icons.business,
                            size: 30, color: Colors.blueAccent),
                      ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 6),
                      Text(
                        companyName,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    // Xóa bookmark
                    await FirebaseFirestore.instance
                        .collection('bookmarks')
                        .doc(widget.userId)
                        .collection('jobs')
                        .doc(jobId)
                        .delete();
                  },
                  child: Icon(
                    Icons.bookmark,
                    color: Colors.yellow,
                    size: 30,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.location_on, size: 20, color: Colors.blueAccent),
                SizedBox(width: 4),
                Text(
                  workLocation,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
                SizedBox(width: 16),
                Icon(Icons.access_time, size: 20, color: Colors.blueAccent),
                SizedBox(width: 4),
                Text(
                  employmentType,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  salaryRange,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                Text(
                  applicationDeadline,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.redAccent,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
