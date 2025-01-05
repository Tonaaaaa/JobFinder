import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jobfinder/screens/DetailScreen/detail_job_screen.dart';

class FullJobListScreen extends StatelessWidget {
  final String userId;
  final String searchKeyword;

  FullJobListScreen({required this.userId, required this.searchKeyword});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Danh sách công việc"),
        backgroundColor: Colors.blueAccent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('jobPosts').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("Không có công việc nào."));
          }

          final now = DateTime.now();
          final jobPosts = snapshot.data!.docs.where((doc) {
            final jobData = doc.data() as Map<String, dynamic>;

            // Lọc bài đăng hết hạn
            final deadline = jobData['applicationDeadline'];
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

            // Kiểm tra nếu đã hết hạn
            if (parsedDeadline != null && parsedDeadline.isBefore(now)) {
              return false;
            }

            // Lọc theo từ khóa tìm kiếm
            final title = jobData['title']?.toLowerCase() ?? '';
            final companyName = jobData['companyName']?.toLowerCase() ?? '';
            final workLocation = jobData['workLocation']?.toLowerCase() ?? '';
            return title.contains(searchKeyword) ||
                companyName.contains(searchKeyword) ||
                workLocation.contains(searchKeyword);
          }).toList();

          return ListView.builder(
            itemCount: jobPosts.length,
            itemBuilder: (context, index) {
              final jobData = jobPosts[index].data() as Map<String, dynamic>;
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => JobDetailsScreen(
                        jobData: jobData,
                      ),
                    ),
                  );
                },
                child: _EnhancedJobCard(
                  jobId: jobPosts[index].id,
                  title: jobData['title'] ?? 'Không có tiêu đề',
                  companyName: jobData['companyName'] ?? 'Không có công ty',
                  workLocation: jobData['workLocation'] ?? 'Không xác định',
                  employmentType: jobData['employmentType'] ?? 'Không xác định',
                  salaryRange: jobData['salaryRange'] ?? 'Không xác định',
                  applicationDeadline: jobData['applicationDeadline'] ?? '',
                  companyLogo: jobData['logoUrl'] ?? null,
                  userId: userId,
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
  final String? companyLogo;
  final String userId;

  _EnhancedJobCard({
    required this.jobId,
    required this.title,
    required this.companyName,
    required this.workLocation,
    required this.employmentType,
    required this.salaryRange,
    required this.applicationDeadline,
    this.companyLogo,
    required this.userId,
  });

  @override
  __EnhancedJobCardState createState() => __EnhancedJobCardState();
}

class __EnhancedJobCardState extends State<_EnhancedJobCard> {
  bool _isBookmarked = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkBookmarkStatus();
  }

  Future<void> _checkBookmarkStatus() async {
    final bookmarkDoc = await FirebaseFirestore.instance
        .collection('bookmarks')
        .doc(widget.userId)
        .collection('jobs')
        .doc(widget.jobId)
        .get();

    setState(() {
      _isBookmarked = bookmarkDoc.exists;
      _isLoading = false;
    });
  }

  Future<void> _toggleBookmark() async {
    setState(() {
      _isLoading = true;
    });

    if (_isBookmarked) {
      await FirebaseFirestore.instance
          .collection('bookmarks')
          .doc(widget.userId)
          .collection('jobs')
          .doc(widget.jobId)
          .delete();
    } else {
      await FirebaseFirestore.instance
          .collection('bookmarks')
          .doc(widget.userId)
          .collection('jobs')
          .doc(widget.jobId)
          .set({
        'title': widget.title,
        'companyName': widget.companyName,
        'workLocation': widget.workLocation,
        'employmentType': widget.employmentType,
        'salaryRange': widget.salaryRange,
        'applicationDeadline': widget.applicationDeadline,
        'logoUrl': widget.companyLogo,
      });
    }

    setState(() {
      _isBookmarked = !_isBookmarked;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                widget.companyLogo != null && widget.companyLogo!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          widget.companyLogo!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.contain,
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
                GestureDetector(
                  onTap: _toggleBookmark,
                  child: _isLoading
                      ? SizedBox(
                          height: 30,
                          width: 30,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.blueAccent,
                          ),
                        )
                      : AnimatedSwitcher(
                          duration: Duration(milliseconds: 300),
                          transitionBuilder: (child, animation) =>
                              ScaleTransition(scale: animation, child: child),
                          child: Icon(
                            _isBookmarked
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            key: ValueKey(_isBookmarked),
                            color: _isBookmarked
                                ? Colors.yellow
                                : Colors.blueAccent,
                            size: 30,
                          ),
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
