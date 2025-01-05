import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

              // Kiểm tra trạng thái hết hạn
              final deadline = jobData['applicationDeadline'];
              bool isExpired = false;
              if (deadline != null) {
                DateTime? parsedDeadline;
                if (deadline is Timestamp) {
                  parsedDeadline = deadline.toDate();
                } else if (deadline is String) {
                  try {
                    parsedDeadline = DateFormat('dd/MM/yyyy').parse(deadline);
                  } catch (_) {
                    parsedDeadline = null;
                  }
                }

                if (parsedDeadline != null &&
                    parsedDeadline.isBefore(DateTime.now())) {
                  isExpired = true;
                }
              }

              return GestureDetector(
                onTap: isExpired
                    ? null
                    : () async {
                        // Truy vấn dữ liệu đầy đủ từ jobPosts
                        final jobDoc = await FirebaseFirestore.instance
                            .collection('jobPosts')
                            .doc(jobId)
                            .get();

                        if (jobDoc.exists) {
                          final fullJobData =
                              jobDoc.data() as Map<String, dynamic>;
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
                child: _EnhancedJobCard(
                  jobId: jobId,
                  title: jobData['title'] ?? 'Không có tiêu đề',
                  companyName: jobData['companyName'] ?? 'Không rõ công ty',
                  workLocation: jobData['workLocation'] ?? 'Không xác định',
                  employmentType: jobData['employmentType'] ?? 'Không xác định',
                  salaryRange: jobData['salaryRange'] ?? 'Không xác định',
                  applicationDeadline:
                      jobData['applicationDeadline'] ?? 'Không xác định',
                  logoUrl: jobData['logoUrl'], // Sử dụng logoUrl để load ảnh
                  isExpired: isExpired,
                  userId: widget.userId,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _EnhancedJobCard extends StatefulWidget {
  final String jobId;
  final String title;
  final String companyName;
  final String workLocation;
  final String employmentType;
  final String salaryRange;
  final String applicationDeadline;
  final String? logoUrl;
  final bool isExpired;
  final String userId;

  _EnhancedJobCard({
    required this.jobId,
    required this.title,
    required this.companyName,
    required this.workLocation,
    required this.employmentType,
    required this.salaryRange,
    required this.applicationDeadline,
    this.logoUrl,
    required this.isExpired,
    required this.userId,
  });

  @override
  __EnhancedJobCardState createState() => __EnhancedJobCardState();
}

class __EnhancedJobCardState extends State<_EnhancedJobCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: widget.isExpired ? Colors.grey[200] : Colors.white,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
            color: widget.isExpired ? Colors.red : Colors.blueAccent),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                widget.logoUrl != null && widget.logoUrl!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          widget.logoUrl!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Icon(Icons.broken_image, color: Colors.grey),
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
                        widget.title,
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
                        widget.companyName,
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
                if (widget.isExpired)
                  Text(
                    'Hết hạn',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                if (!widget.isExpired)
                  GestureDetector(
                    onTap: () async {
                      await FirebaseFirestore.instance
                          .collection('bookmarks')
                          .doc(widget.userId)
                          .collection('jobs')
                          .doc(widget.jobId)
                          .delete();

                      if (mounted) {
                        setState(
                            () {}); // Chỉ gọi setState khi widget còn tồn tại
                      }
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
                  widget.workLocation,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
                SizedBox(width: 16),
                Icon(Icons.access_time, size: 20, color: Colors.blueAccent),
                SizedBox(width: 4),
                Text(
                  widget.employmentType,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.salaryRange,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                Text(
                  widget.applicationDeadline,
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
